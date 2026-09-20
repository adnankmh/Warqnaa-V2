#!/usr/bin/env python3
"""Exercise a real, isolated Laravel HTTP server; optionally render Flutter UI.

The runner creates its own database and random synthetic credentials. It does not
accept a remote URL, use a developer's .env, or publish requests/server logs.
"""
from __future__ import annotations

import argparse
import base64
import http.cookiejar
import json
import os
from pathlib import Path
import re
import secrets
import signal
import socket
import subprocess
import tempfile
import time
import urllib.error
import urllib.parse
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
BACKEND = ROOT / 'backend-laravel'


def require(condition, message):
    if not condition:
        raise RuntimeError(message)


class Client:
    def __init__(self, base, build):
        self.base, self.build, self.token = base, build, None
        self.opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))

    def request(self, path, data=None, *, status=200, method=None, json_api=True):
        headers = {'Accept': 'application/json' if json_api else 'text/html', 'X-Warqna-Build': str(self.build), 'X-Warqna-Platform': 'web'}
        if self.token:
            headers['Authorization'] = 'Bearer ' + self.token
        body = None
        if data is not None:
            headers['Content-Type'] = 'application/json' if json_api else 'application/x-www-form-urlencoded'
            body = (json.dumps(data) if json_api else urllib.parse.urlencode(data)).encode()
        request = urllib.request.Request(self.base + path, data=body, headers=headers, method=method)
        try:
            response = self.opener.open(request, timeout=30)
        except urllib.error.HTTPError as error:
            response = error
        with response:
            raw = response.read().decode('utf-8')
            require(response.status == status, f'{request.get_method()} {path}: expected HTTP {status}, received {response.status}')
        return json.loads(raw) if json_api else raw

    def api(self, path, data=None, **kwargs):
        return self.request('/api/mobile/v1' + path, data, **kwargs)


def exercise(base, metadata, accounts):
    checks = []
    clients = {kind: Client(base, metadata['build']) for kind in accounts}
    clients['player'].api('/bootstrap', status=401)
    for kind, account in accounts.items():
        client = clients[kind]
        login = client.api('/login', {'login': account['login'], 'password': account['password']})
        client.token = login['token']
        bootstrap = client.api('/bootstrap')
        require(bootstrap['user']['id'] == account['id'], 'Server identity changed after login')
        require(bootstrap['user']['level'] == account['level'], 'Server level changed after bootstrap')
        require(bootstrap['features']['languages'] == ['ar', 'en'], 'Unexpected customer locales')
        require(client.api('/profile')['user']['id'] == account['id'], 'Profile identity mismatch')
        if kind == 'admin':
            require(bootstrap['user']['admin_role'] == 'primary_admin', 'Role must come from server')
            require(bootstrap['user']['pasha_days'] >= 36500, 'Primary Pasha entitlement lost')
            require(int(bootstrap['wallet']['gems']) >= 100000000, 'Primary gems entitlement lost')
            operations = client.api('/admin/operations')['operations']
            require(operations['checks']['database'] and operations['checks']['scheduler'], 'Runtime database/scheduler checks failed')
        else:
            client.api('/admin/operations', status=403)
    checks.append('login_bootstrap_profile_roles_scheduler')

    player, peer = clients['player'], clients['peer']
    catalog = player.api('/games/catalog')['games']
    require(not {'chess', 'domino', 'jackaroo', 'backgammon'} & {g['key'] for g in catalog}, 'Removed game returned')
    bootstrap = player.api('/bootstrap')
    free_tables = [i for i in bootstrap['store'] if i['category'] == 'table' and int(i['price']) == 0]
    require(len(free_tables) == 1, 'Expected exactly one free customer table')
    balance = player.api('/wallet')['wallet']['tokens']
    for key in ['v305_table_emerald_royal', 'v305_cardback_emerald_royal']:
        bought = player.api('/store/purchase', {'key': key, 'confirmed': True})
        require(bought['inventory_item']['active'], 'Starter cosmetic did not activate')
    restored = player.api('/bootstrap')
    owned = {i['store_item']['key'] for i in restored['inventory'] if i['active']}
    require({'v305_table_emerald_royal', 'v305_cardback_emerald_royal'} <= owned, 'Inventory activation not durable')
    require(player.api('/wallet')['wallet']['tokens'] == balance, 'Free cosmetics changed wallet balance')
    player.api('/profile', {'locale': 'de'}, method='PATCH', status=422)
    checks.append('catalog_wallet_inventory_activation_locale_guard')

    friendship = player.api(f"/social/friends/{accounts['peer']['id']}/request", {}, status=201)['friendship']
    peer.api(f"/social/friendships/{friendship['id']}/respond", {'status': 'accepted'})
    require(len(player.api('/social')['friends']) == 1, 'Friend acceptance not persisted')
    public_profile = player.api(f"/social/users/{accounts['peer']['id']}/profile")
    require('email' not in public_profile['user'], 'Public social profile exposed email')
    checks.append('two_account_social_privacy')

    room = player.api('/games/session', {'game': 'tarneeb', 'visibility': 'public', 'room_name': 'R7 Runtime Room', 'turn_seconds': 10}, status=201)['room']
    code = room['code']
    summary = next(r for r in peer.api('/bootstrap')['rooms'] if r['code'] == code)
    require('state' not in summary and 'password' not in summary, 'Bootstrap exposed private room data')
    peer_room = peer.api(f'/games/session/{code}/join', {})['room']
    seat = next(p['seat'] for p in peer_room['players'] if p['user_id'] == accounts['peer']['id'])
    require('hands' not in peer_room['state'] and 'hand' in peer_room['state'], 'Private game hands leaked')
    peer.api(f'/games/session/{code}/disconnect', {'reason': 'r7-test'})
    require(peer.api(f'/games/session/{code}/reconnect', {})['seat'] == seat, 'Reconnect changed the player seat')
    require(peer.api(f'/games/session/{code}')['room']['code'] == code, 'Room state unavailable after reconnect')
    peer.api(f'/games/session/{code}/leave', {})
    player.api(f'/games/session/{code}/leave', {})
    checks.append('two_account_room_private_state_reconnect')

    for kind in ['player', 'admin']:
        web = Client(base, metadata['build'])
        html = web.request('/login', json_api=False)
        match = re.search(r'name="_token"[^>]*value="([^"]+)"', html)
        require(match, 'Web login CSRF token missing')
        web.request('/login', {'_token': match.group(1), **{k: accounts[kind][k] for k in ['login', 'password']}}, json_api=False)
        for path in ['/games', '/offers'] + (['/admin', '/admin/operations'] if kind == 'admin' else []):
            html = web.request(path, json_api=False)
            require('name="password"' not in html, 'Web session fell back to login')
    for path in ['/manifest.webmanifest', '/offline.html', '/sw.js']:
        clients['player'].request(path, json_api=False)
    checks.append('web_login_offers_admin_pwa')
    return checks


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--report-dir', required=True, type=Path)
    parser.add_argument('--flutter-review', action='store_true')
    args = parser.parse_args()
    require(not any((BACKEND / name).exists() for name in ['.env', '.env.testing', 'bootstrap/cache/config.php']), 'Use a clean checkout without environment files or cached configuration')
    report_dir = args.report_dir.resolve()
    require(not report_dir.is_relative_to(ROOT), 'Reports must be outside the repository')
    report_dir.mkdir(parents=True, exist_ok=True)
    metadata = json.loads((ROOT / 'RELEASE_VERSION.json').read_text())
    report = {'release': metadata['full'], 'commit': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(), 'checks': [], 'passed': False}
    with tempfile.TemporaryDirectory(prefix='warqnaa-r7-') as directory:
        work = Path(directory)
        database = work / 'runtime.sqlite'
        database.touch()
        with socket.socket() as sock:
            sock.bind(('127.0.0.1', 0))
            port = sock.getsockname()[1]
        base = f'http://127.0.0.1:{port}'
        env = dict(os.environ, APP_ENV='testing', APP_DEBUG='false', APP_KEY='base64:' + base64.b64encode(secrets.token_bytes(32)).decode(), APP_URL=base, DB_CONNECTION='sqlite', DB_DATABASE=str(database), CACHE_STORE='file', CACHE_PREFIX='r7_' + secrets.token_hex(8), SESSION_DRIVER='file', QUEUE_CONNECTION='sync', MAIL_MAILER='array', WARQNA_R7_WORKSPACE=str(work))
        process = None
        try:
            with (work / 'setup.log').open('w') as output:
                for command in [['php', 'artisan', 'migrate', '--force', '--no-interaction'], ['php', 'tools/r7-runtime-fixture.php'], ['php', 'artisan', 'schedule:run', '--no-interaction']]:
                    subprocess.run(command, cwd=BACKEND, env=env, stdout=output, stderr=subprocess.STDOUT, check=True, timeout=180)
            with (work / 'server.log').open('w') as output:
                process = subprocess.Popen(['php', 'artisan', 'serve', '--host=127.0.0.1', f'--port={port}', '--no-reload'], cwd=BACKEND, env=env, stdout=output, stderr=subprocess.STDOUT, start_new_session=True)
                for _ in range(60):
                    try:
                        Client(base, metadata['build']).api('/health')
                        break
                    except (OSError, RuntimeError):
                        time.sleep(.25)
                else:
                    raise RuntimeError('Isolated Laravel server did not become ready')
                accounts = json.loads((work / 'accounts.json').read_text())
                report['checks'] = exercise(base, metadata, accounts)
                if args.flutter_review:
                    defines = {'R7_RUNTIME_URL': base + '/api/mobile/v1', 'R7_REVIEW_DIR': str(report_dir / 'screenshots'), 'R7_REVIEW_FONT': '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'}
                    for kind, account in accounts.items():
                        for key, value in account.items():
                            defines[f'R7_{kind.upper()}_{key.upper()}'] = str(value)
                    config = work / 'flutter-defines.json'
                    config.write_text(json.dumps(defines))
                    config.chmod(0o600)
                    subprocess.run(['flutter', 'test', 'test/r7_runtime_review_test.dart', '--dart-define-from-file=' + str(config)], cwd=ROOT / 'flutter_app', check=True, timeout=600)
                    report['checks'].append('flutter_live_identity_and_rendered_layouts')
                report['passed'] = True
        finally:
            if process is not None:
                try:
                    os.killpg(process.pid, signal.SIGTERM)
                except ProcessLookupError:
                    pass
                process.wait(timeout=15)
            (report_dir / 'runtime-verification.json').write_text(json.dumps(report, indent=2) + '\n')
    print('R7 isolated runtime verification: PASS')


if __name__ == '__main__':
    main()

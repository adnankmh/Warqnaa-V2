#!/usr/bin/env python3
"""Exercise the real launch script against deterministic adb responses."""
import hashlib
import json
import os
from pathlib import Path
import random
import struct
import subprocess
import tempfile
import unittest
import zlib

ROOT = Path(__file__).resolve().parents[1]

ADB = r'''#!/usr/bin/env python3
import os
from pathlib import Path
import sys

root = Path(os.environ['FAKE_ADB_ROOT'])
mode = os.environ['FAKE_ADB_MODE']
args = sys.argv[1:]
counter = root / 'captures'
count = int(counter.read_text()) if counter.exists() else 0
if args[:2] == ['exec-out', 'screencap']:
    counter.write_text(str(count + 1))
    if mode == 'capture_error' and count == 0:
        sys.exit(1)
    if mode == 'blank' or (mode == 'delayed' and count < 2) or (mode == 'exit' and count == 0):
        sys.stdout.buffer.write(b'\x89PNG\r\n\x1a\n')
    else:
        sys.stdout.buffer.write((root / 'screen.png').read_bytes())
elif args[:2] == ['shell', 'ps']:
    queries = root / 'queries'
    query = (int(queries.read_text()) if queries.exists() else 0) + 1
    queries.write_text(str(query))
    if mode == 'transient_query' and query == 3:
        print('adb: device offline', file=sys.stderr)
        sys.exit(1)
    print('PID NAME')
    print('4243 com.warqna.warqna_mobile:sandboxed_process')
    if not (mode == 'exit' and count > 0):
        pid = '5252' if mode == 'restart' and count > 0 else '4242'
        print(f'{pid} com.warqna.warqna_mobile')
elif args[:2] == ['shell', 'getprop']:
    print('32' if mode == 'api32' else '35')
elif args[:3] == ['shell', 'pm', 'grant']:
    (root / 'permission-grant').write_text(' '.join(args[3:]))
    if mode == 'permission_error':
        sys.exit(1)
elif args[:2] == ['shell', 'dumpsys']:
    if args[2] == 'meminfo' and mode == 'meminfo_error':
        sys.exit(255)
    if args[2:] == ['activity', 'activities']:
        focus_checks = root / 'focus-checks'
        focus_check = (int(focus_checks.read_text()) if focus_checks.exists() else 0) + 1
        focus_checks.write_text(str(focus_check))
        app = 'com.warqna.warqna_mobile/.MainActivity'
        focus = app
        if mode == 'splash_then_app' and focus_check <= 2:
            focus = 'Splash Screen com.warqna.warqna_mobile'
        if count > 0 and (mode == 'background' or (mode == 'transient_focus' and focus_check == 2)):
            focus = 'com.android.launcher/.MainActivity'
        print(f'topResumedActivity=ActivityRecord{{98a u0 {app} t8}}')
        print(f'mCurrentFocus=Window{{680ffdf u0 {focus}}}')
elif args and args[0] == 'logcat':
    if '--pid=4242' in args and mode in ('log_retry', 'log_unavailable'):
        probe = root / 'log-attempt'
        n = (int(probe.read_text()) if probe.exists() else 0) + 1
        probe.write_text(str(n))
        if n == 1 or mode == 'log_unavailable':
            print('incomplete diagnostic')
            sys.exit(255)
    if 'ActivityTaskManager:I' in args:
        draw_checks = root / 'draw-checks'
        draw_check = (int(draw_checks.read_text()) if draw_checks.exists() else 0) + 1
        draw_checks.write_text(str(draw_check))
        if (mode != 'focus_before_draw' or draw_check > 2) and (mode != 'main_buffer_draw' or '-b' in args and args[args.index('-b') + 1] == 'all'):
            print('I ActivityTaskManager: Displayed com.warqna.warqna_mobile/.MainActivity for user 0: +8s84ms')
    if mode == 'crash' and '--pid=4242' in args:
        print('FATAL EXCEPTION: main')
    if mode == 'anr' and '--pid=4242' not in args and '-c' not in args:
        print('ANR in com.warqna.warqna_mobile')
elif args and args[0] == 'install':
    print('Success')
'''


def fixture_png():
    def chunk(kind, payload):
        return (struct.pack('>I', len(payload)) + kind + payload
                + struct.pack('>I', zlib.crc32(kind + payload)))
    rng = random.Random(81)
    pixels = b''.join(b'\0' + rng.randbytes(300) for _ in range(120))
    return (b'\x89PNG\r\n\x1a\n'
            + chunk(b'IHDR', struct.pack('>IIBBBBB', 100, 120, 8, 2, 0, 0, 0))
            + chunk(b'IDAT', zlib.compress(pixels)) + chunk(b'IEND', b''))


class AndroidSmokeTest(unittest.TestCase):
    def run_smoke(self, mode, stale_evidence=False):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        root = Path(temp.name)
        bin_dir = root / 'bin'
        bin_dir.mkdir()
        for name, body in {
            'adb': ADB,
            'apkanalyzer': '#!/bin/sh\necho com.warqna.warqna_mobile\n',
            'sleep': '#!/bin/sh\nexit 0\n',
        }.items():
            script = bin_dir / name
            script.write_text(body)
            script.chmod(0o755)
        (root / 'screen.png').write_bytes(fixture_png())
        apk = root / 'test.apk'
        apk.write_bytes(b'fixture APK for checksum association')
        evidence = root / 'evidence'
        if stale_evidence:
            evidence.mkdir()
            for name in ('result.json', 'first-frame.png', 'frame-candidate.png', 'frame-attempts.txt'):
                (evidence / name).write_text('stale previous run')
        env = dict(os.environ, PATH=f'{bin_dir}:{os.environ["PATH"]}',
                   FAKE_ADB_ROOT=str(root), FAKE_ADB_MODE=mode)
        result = subprocess.run(
            ['bash', str(ROOT / 'tools/android_emulator_smoke.sh'), str(apk), str(evidence)],
            env=env, capture_output=True, text=True, timeout=30,
        )
        return result, root, evidence

    def test_delayed_frame_is_retried_and_tied_to_apk(self):
        result, root, evidence = self.run_smoke('delayed')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        report = json.loads((evidence / 'result.json').read_text())
        self.assertEqual(report['frame_capture_attempts'], 3)
        self.assertEqual(report['apk_sha256'], hashlib.sha256((root / 'test.apk').read_bytes()).hexdigest())
        self.assertEqual((evidence / 'first-frame.png').read_bytes(), fixture_png())
        self.assertTrue((evidence / 'exit-frame.png').exists())
        self.assertEqual(report['notification_permission'], 'pregranted_on_test_device')
        self.assertEqual((root / 'permission-grant').read_text(),
                         'com.warqna.warqna_mobile android.permission.POST_NOTIFICATIONS')

    def test_previous_frame_evidence_is_cleared_before_new_run(self):
        result, _, evidence = self.run_smoke('api32', stale_evidence=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertFalse((evidence / 'frame-candidate.png').exists())
        self.assertEqual((evidence / 'frame-attempts.txt').read_text(),
                         'attempt=1 stage=accepted\n')
        self.assertEqual(json.loads((evidence / 'result.json').read_text())['status'], 'PASSED')

    def test_transient_log_failure_is_retried_without_partial_output(self):
        result, root, evidence = self.run_smoke('log_retry')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((root / 'log-attempt').read_text(), '2')
        self.assertNotIn('incomplete diagnostic', (evidence / 'app-logcat.txt').read_text())
        self.assertIn('adb_status=255', (evidence / 'adb-diagnostics.txt').read_text())

    def test_required_crash_log_failure_prevents_passing(self):
        result, root, evidence = self.run_smoke('log_unavailable')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual((root / 'log-attempt').read_text(), '3')
        self.assertIn('crash logs unavailable', result.stderr)
        self.assertFalse((evidence / 'result.json').exists())

    def test_optional_meminfo_failure_keeps_valid_crash_and_frame_checks(self):
        result, _, evidence = self.run_smoke('meminfo_error')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('Optional memory snapshot unavailable', result.stderr)
        self.assertTrue((evidence / 'app-logcat.txt').is_file())
        self.assertTrue((evidence / 'full-logcat.txt').is_file())
        self.assertEqual(json.loads((evidence / 'result.json').read_text())['status'], 'PASSED')

    def test_old_android_does_not_receive_unsupported_permission(self):
        result, root, evidence = self.run_smoke('api32')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertFalse((root / 'permission-grant').exists())
        self.assertEqual(json.loads((evidence / 'result.json').read_text())['notification_permission'], 'not_required')

    def test_permission_setup_failure_stops_the_check(self):
        result, _, evidence = self.run_smoke('permission_error')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((evidence / 'result.json').exists())

    def test_capture_transport_error_is_retried(self):
        result, _, evidence = self.run_smoke('capture_error')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(json.loads((evidence / 'result.json').read_text())['frame_capture_attempts'], 2)

    def test_blank_screen_fails_after_bounded_attempts(self):
        result, root, evidence = self.run_smoke('blank')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('after 30 capture attempts', result.stderr)
        self.assertEqual(int((root / 'captures').read_text()), 31)  # includes exit evidence
        self.assertFalse((evidence / 'result.json').exists())

    def test_app_exit_during_frame_wait_fails(self):
        # Keep the first frame below the gate, then simulate process death.
        result, _, evidence = self.run_smoke('exit')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((evidence / 'result.json').exists())

    def test_fatal_crash_is_not_hidden_by_valid_image(self):
        result, _, evidence = self.run_smoke('crash')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('fatal exception', result.stderr)
        self.assertFalse((evidence / 'result.json').exists())

    def test_background_app_is_not_accepted(self):
        result, _, evidence = self.run_smoke('background')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('lost its foreground activity', result.stderr)
        self.assertFalse((evidence / 'result.json').exists())

    def test_splash_window_is_not_captured_as_the_app_frame(self):
        result, root, evidence = self.run_smoke('splash_then_app')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        report = json.loads((evidence / 'result.json').read_text())
        self.assertEqual(report['frame_capture_attempts'], 2)
        self.assertEqual((evidence / 'frame-attempts.txt').read_text(),
                         'attempt=1 stage=foreground_missing\nattempt=2 stage=accepted\n')
        self.assertTrue((evidence / 'first-foreground-failure.txt').exists())
        self.assertEqual(int((root / 'captures').read_text()), 2)  # app frame and exit evidence

    def test_focus_alone_is_insufficient_while_android_splash_is_drawn(self):
        result, root, evidence = self.run_smoke('focus_before_draw')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(json.loads((evidence / 'result.json').read_text())['frame_capture_attempts'], 2)
        self.assertEqual((evidence / 'frame-attempts.txt').read_text(),
                         'attempt=1 stage=display_event_missing\nattempt=2 stage=accepted\n')
        self.assertTrue((evidence / 'first-display-failure.txt').exists())
        self.assertEqual(int((root / 'captures').read_text()), 2)

    def test_draw_event_in_main_logcat_buffer_is_accepted(self):
        result, _, evidence = self.run_smoke('main_buffer_draw')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(json.loads((evidence / 'result.json').read_text())['frame_capture_attempts'], 1)

    def test_transient_focus_gap_after_first_frame_is_retried(self):
        result, root, evidence = self.run_smoke('transient_focus')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(int((root / 'focus-checks').read_text()), 4)  # includes exit evidence
        self.assertEqual(json.loads((evidence / 'result.json').read_text())['pid'], 4242)

    def test_transient_adb_query_is_retried_with_evidence(self):
        result, _, evidence = self.run_smoke('transient_query')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(json.loads((evidence / 'result.json').read_text())['pid'], 4242)
        self.assertIn('adb: device offline', (evidence / 'process-queries.txt').read_text())

    def test_real_process_restart_is_rejected(self):
        result, _, evidence = self.run_smoke('restart')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('exited or restarted', result.stderr)
        self.assertFalse((evidence / 'result.json').exists())

    def test_anr_is_not_hidden_by_valid_image(self):
        result, _, evidence = self.run_smoke('anr')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('ANR for', result.stderr)
        self.assertFalse((evidence / 'result.json').exists())


if __name__ == '__main__':
    unittest.main()

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
elif args[:2] == ['shell', 'pidof']:
    if not (mode == 'exit' and count > 0):
        print('4242')
elif args[:2] == ['shell', 'getprop']:
    print('32' if mode == 'api32' else '35')
elif args[:3] == ['shell', 'pm', 'grant']:
    (root / 'permission-grant').write_text(' '.join(args[3:]))
    if mode == 'permission_error':
        sys.exit(1)
elif args[:2] == ['shell', 'dumpsys']:
    package = 'com.android.launcher' if mode == 'background' and count > 0 else 'com.warqna.warqna_mobile'
    print(f'mResumedActivity: {package}/.MainActivity')
elif args and args[0] == 'logcat':
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
    pixels = b''.join(b'\0' + rng.randbytes(300) for _ in range(100))
    return (b'\x89PNG\r\n\x1a\n'
            + chunk(b'IHDR', struct.pack('>IIBBBBB', 100, 100, 8, 2, 0, 0, 0))
            + chunk(b'IDAT', zlib.compress(pixels)) + chunk(b'IEND', b''))


class AndroidSmokeTest(unittest.TestCase):
    def run_smoke(self, mode):
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

    def test_anr_is_not_hidden_by_valid_image(self):
        result, _, evidence = self.run_smoke('anr')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('ANR for', result.stderr)
        self.assertFalse((evidence / 'result.json').exists())


if __name__ == '__main__':
    unittest.main()

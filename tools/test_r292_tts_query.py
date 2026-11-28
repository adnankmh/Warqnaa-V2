import unittest
import xml.etree.ElementTree as ET
from configure_android_startup import ensure_tts_query, A

class TtsQueryTest(unittest.TestCase):
    def test_preserves_existing_queries_and_is_idempotent(self):
        root = ET.fromstring('<manifest><queries><intent><action /></intent></queries><application /></manifest>')
        original = root.find('queries/intent/action')
        original.set(A+'name', 'android.intent.action.PROCESS_TEXT')
        ensure_tts_query(root)
        ensure_tts_query(root)
        names = [node.get(A+'name') for node in root.findall('queries/intent/action')]
        self.assertEqual(names, ['android.intent.action.PROCESS_TEXT', 'android.intent.action.TTS_SERVICE'])
        self.assertEqual(root.findall('uses-permission'), [])

    def test_missing_queries(self):
        root = ET.fromstring('<manifest><application /></manifest>')
        ensure_tts_query(root)
        self.assertEqual(root.find('queries/intent/action').get(A+'name'), 'android.intent.action.TTS_SERVICE')
        self.assertEqual(len(root.findall('queries')), 1)

if __name__ == '__main__':
    unittest.main()

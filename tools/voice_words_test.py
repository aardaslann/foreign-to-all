"""Offline contract for notebook pronunciation coverage, not a listening review."""
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class NotebookVoiceCoverage(unittest.TestCase):
    def test_eight_languages_and_first_discoveries(self):
        words = json.loads((ROOT / "docs/beta-language-review/key-words.json").read_text(encoding="utf-8"))["words"]
        keys = {f"{w['language']}|{w['word']}" for w in words}
        for key in ["german|geld", "german|brot", "german|apfel", "german|danke",
                    "russian|pochinit", "hindi|dheere", "japanese|daijoubu"]:
            with self.subTest(key=key):
                self.assertIn(key, keys)

    def test_shipped_clips_exist(self):
        words = json.loads((ROOT / "docs/beta-language-review/key-words.json").read_text(encoding="utf-8"))["words"]
        manifest = json.loads((ROOT / "audio/voice/manifest.json").read_text(encoding="utf-8"))["words"]
        for word in words:
            key = f"{word['language']}|{word['word']}"
            with self.subTest(key=key):
                self.assertIn(key, manifest)
                self.assertGreater((ROOT / manifest[key].removeprefix("res://")).stat().st_size, 1000)


if __name__ == "__main__":
    unittest.main()

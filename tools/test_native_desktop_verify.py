import os
from pathlib import Path
import unittest
from unittest.mock import patch

import native_desktop_verify as native


class NativeRunnerTests(unittest.TestCase):
    def test_complete_suite_result(self):
        self.assertEqual(native.suite_result("PACKAGE: 148 checks; 0 failures", "PACKAGE:", 148), 148)
        self.assertEqual(native.suite_result("QUEST: 51 checks, 0 failures", "QUEST:", 51), 51)

    def test_incomplete_or_failed_suite_rejected(self):
        for text in ("", "PACKAGE: 1 checks; 0 failures", "PACKAGE: 148 checks; 1 failures"):
            with self.subTest(text=text), self.assertRaises(RuntimeError):
                native.suite_result(text, "PACKAGE:", 148)

    def test_missing_shared_library_rejected(self):
        with self.assertRaises(RuntimeError):
            native.check_libraries("libGL.so => not found")
        native.check_libraries("libGL.so => /usr/lib/libGL.so (0x1234)")

    def test_profile_environment_does_not_mutate_parent(self):
        before = dict(os.environ)
        with patch.object(native.platform, "system", return_value="Linux"):
            env = native.profile_environment(Path("/tmp/test-profile"))
        self.assertEqual(env["XDG_DATA_HOME"], str(Path("/tmp/test-profile/data")))
        self.assertEqual(dict(os.environ), before)


if __name__ == "__main__":
    unittest.main()

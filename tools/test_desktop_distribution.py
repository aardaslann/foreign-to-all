import importlib.util
import configparser
from pathlib import Path
import stat
import struct
import tarfile
import tempfile
import unittest
import zipfile


MODULE = Path(__file__).with_name("desktop_distribution.py")


class DistributionTests(unittest.TestCase):
    def setUp(self):
        self.assertTrue(MODULE.exists(), "cross-platform distribution builder exists")
        spec = importlib.util.spec_from_file_location("distribution", MODULE)
        self.dist = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(self.dist)
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)

    def test_identity(self):
        path = self.root / "BuildInfo.gd"
        path.write_text('const VERSION := "0.2.1-beta.1"\nconst BUILD_ID := "20261004.5"\nconst SAVE_SCHEMA := 1\n')
        self.assertEqual(self.dist.build_identity(path), ("0.2.1-beta.1", "20261004.5", 1))

    def test_missing_identity_rejected(self):
        path = self.root / "BuildInfo.gd"
        path.write_text('const VERSION := ""')
        with self.assertRaises(ValueError):
            self.dist.build_identity(path)

    def test_unsafe_identity_rejected(self):
        path = self.root / "BuildInfo.gd"
        path.write_text('const VERSION := "../bad"\nconst BUILD_ID := "1"\nconst SAVE_SCHEMA := 1')
        with self.assertRaises(ValueError):
            self.dist.build_identity(path)

    def test_mac_uses_builtin_adhoc_signing(self):
        config = configparser.ConfigParser()
        config.read(MODULE.parents[1] / "export_presets.cfg")
        self.assertEqual(config["preset.2.options"]["codesign/codesign"], "1")
        self.assertEqual(config["preset.2.options"]["notarization/notarization"], "0")

    def test_apple_silicon_texture_import_enabled(self):
        config = configparser.ConfigParser()
        source = (MODULE.parents[1] / "project.godot").read_text(encoding="utf-8-sig")
        config.read_string("[godot_header]\n" + source)
        self.assertEqual(config["rendering"].get("textures/vram_compression/import_etc2_astc"), "true")

    def test_linux_archive_permissions(self):
        package = self.root / "Game"
        package.mkdir()
        (package / "ForeignToAll.x86_64").write_bytes(b"\x7fELF" + bytes(100))
        (package / "START-HERE.md").write_text("guide")
        archive = self.root / "game.tar.gz"
        self.dist.linux_archive(package, archive)
        with tarfile.open(archive) as tar:
            self.assertEqual(tar.getmember("Game/ForeignToAll.x86_64").mode, 0o755)
            self.assertEqual(tar.getmember("Game/START-HERE.md").mode, 0o644)
            self.assertEqual(tar.getmember("Game").mode, 0o755)

    def test_existing_archive_not_replaced(self):
        archive = self.root / "game.tar.gz"
        archive.write_bytes(b"old")
        with self.assertRaises(FileExistsError):
            self.dist.linux_archive(self.root, archive)
        self.assertEqual(archive.read_bytes(), b"old")

    def test_symlinks_not_packaged(self):
        package = self.root / "Game"
        package.mkdir()
        outside = self.root / "private.txt"
        outside.write_text("not game data")
        try:
            (package / "link").symlink_to(outside)
        except OSError:
            self.skipTest("host requires permission for symlinks")
        with self.assertRaises(ValueError):
            self.dist.linux_archive(package, self.root / "game.tar.gz")

    def test_mac_archive_preserves_executable_mode(self):
        raw = self.root / "raw.zip"
        info = zipfile.ZipInfo("ForeignToAll.app/Contents/MacOS/ForeignToAll")
        info.create_system = 3
        info.external_attr = (stat.S_IFREG | 0o755) << 16
        with zipfile.ZipFile(raw, "w") as z:
            z.writestr(info, b"native")
        notes = self.root / "notes"
        notes.mkdir()
        (notes / "START-HERE.md").write_text("guide")
        result = self.root / "final.zip"
        self.dist.mac_archive(raw, notes, result)
        with zipfile.ZipFile(result) as z:
            self.assertEqual(z.getinfo(info.filename).external_attr, info.external_attr)
            self.assertEqual(z.read("START-HERE.md"), b"guide")

    def test_mac_rejects_path_traversal(self):
        raw = self.root / "raw.zip"
        with zipfile.ZipFile(raw, "w") as z:
            z.writestr("../private", "bad")
        notes = self.root / "notes"
        notes.mkdir()
        with self.assertRaises(ValueError):
            self.dist.mac_archive(raw, notes, self.root / "final.zip")

    def test_macho_requires_both_architectures(self):
        header = struct.pack(">II", 0xCAFEBABE, 2)
        header += struct.pack(">IIIII", 0x01000007, 3, 100, 10, 0)
        header += struct.pack(">IIIII", 0x0100000C, 0, 110, 10, 0)
        self.assertEqual(self.dist.macho_architectures(header), {"x86_64", "arm64"})
        with self.assertRaises(ValueError):
            self.dist.macho_architectures(b"not a binary")

    def test_subprocess_script_error_fails_even_with_zero_exit(self):
        import sys
        with self.assertRaises(RuntimeError):
            self.dist.run([sys.executable, "-c", "print('SCRIPT ERROR: broken')"], self.root / "run.log")

    def test_subprocess_warning_does_not_fail(self):
        import sys
        self.dist.run([sys.executable, "-c", "print('WARNING: shutdown')"], self.root / "run.log")

    def test_unexpected_engine_error_fails_even_with_zero_exit(self):
        import sys
        with self.assertRaises(RuntimeError):
            self.dist.run([sys.executable, "-c", "print('ERROR: Cannot load texture')"], self.root / "run.log")

    def test_known_shutdown_resource_diagnostic_retained_but_nonfatal(self):
        import sys
        text = self.dist.run([sys.executable, "-c", "print('ERROR: 2 resources still in use at exit (run with --verbose for details).')"], self.root / "run.log")
        self.assertIn("resources still in use", text)

    def test_subprocess_nonzero_fails(self):
        import sys
        with self.assertRaises(RuntimeError):
            self.dist.run([sys.executable, "-c", "raise SystemExit(3)"], self.root / "run.log")


if __name__ == "__main__":
    unittest.main()

"""Build Linux and macOS beta archives without changing the Windows package."""

import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import plistlib
import re
import shutil
import stat
import struct
import subprocess
import tarfile
import zipfile


ENGINE = "4.7.2.stable"
ROOT = Path(__file__).resolve().parents[1]


def build_identity(path):
    source = path.read_text(encoding="utf-8-sig")
    values = []
    for key in ("VERSION", "BUILD_ID"):
        match = re.search(rf'^const {key} := "([A-Za-z0-9][A-Za-z0-9.-]*)"$', source, re.M)
        if not match:
            raise ValueError(f"Missing or unsafe {key}")
        values.append(match[1])
    schema = re.search(r"^const SAVE_SCHEMA := ([1-9][0-9]*)$", source, re.M)
    if not schema:
        raise ValueError("Missing save schema")
    return *values, int(schema[1])


def sha256(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def run(command, log, *, env=None, timeout=600):
    log.parent.mkdir(parents=True, exist_ok=True)
    with log.open("w", encoding="utf-8") as output:
        result = subprocess.run(command, stdout=output, stderr=subprocess.STDOUT,
                                env=env, timeout=timeout, check=False)
    text = log.read_text(encoding="utf-8", errors="replace")
    errors = re.findall(r"^ERROR: (.+)$", text, re.M)
    unexpected = [line for line in errors if not re.fullmatch(
        r"\d+ resources still in use at exit \(run with --verbose for details\)\.", line)]
    if result.returncode or unexpected or re.search(r"SCRIPT ERROR:|Parse Error:|Failed to export", text):
        raise RuntimeError(f"Command failed ({result.returncode}); see {log}\n{text[-3000:]}")
    return text


def linux_archive(package, archive):
    if archive.exists():
        raise FileExistsError(archive)
    paths = [package, *sorted(package.rglob("*"))]
    if any(path.is_symlink() for path in paths):
        raise ValueError("Package must not follow symbolic links")
    with tarfile.open(archive, "x:gz") as output:
        for path in paths:
            info = output.gettarinfo(str(path), path.relative_to(package.parent).as_posix())
            info.uid = info.gid = 0
            info.uname = info.gname = ""
            info.mode = 0o755 if path.is_dir() or path.name.endswith(".x86_64") else 0o644
            if path.is_file():
                with path.open("rb") as stream:
                    output.addfile(info, stream)
            else:
                output.addfile(info)


def safe_member(name):
    path = PurePosixPath(name)
    if path.is_absolute() or ".." in path.parts or "\\" in name or ":" in name:
        raise ValueError(f"Unsafe archive member: {name}")


def mac_archive(raw, notes, archive):
    if archive.exists():
        raise FileExistsError(archive)
    with zipfile.ZipFile(raw) as source:
        for info in source.infolist():
            safe_member(info.filename)
        with zipfile.ZipFile(archive, "x", compression=zipfile.ZIP_DEFLATED) as output:
            # Retain Godot's Unix modes and bundle structure, even on Windows.
            for info in source.infolist():
                with source.open(info) as inp, output.open(info, "w", force_zip64=True) as dest:
                    shutil.copyfileobj(inp, dest)
            for path in sorted(notes.iterdir()):
                if path.is_file():
                    info = zipfile.ZipInfo(path.name)
                    info.create_system = 3
                    info.external_attr = (stat.S_IFREG | 0o644) << 16
                    info.compress_type = zipfile.ZIP_DEFLATED
                    output.writestr(info, path.read_bytes())


def macho_architectures(header):
    if len(header) < 8:
        raise ValueError("Truncated Mach-O header")
    magic, count = struct.unpack_from(">II", header)
    if magic != 0xCAFEBABE or count > 8 or len(header) < 8 + 20 * count:
        raise ValueError("Expected universal Mach-O binary")
    types = {struct.unpack_from(">I", header, 8 + i * 20)[0] for i in range(count)}
    return {name for code, name in [(0x01000007, "x86_64"), (0x0100000C, "arm64")] if code in types}


def inspect_mac(raw):
    with zipfile.ZipFile(raw) as archive:
        plists = [name for name in archive.namelist() if name.endswith(".app/Contents/Info.plist")]
        if len(plists) != 1:
            raise ValueError("Expected exactly one application bundle")
        plist = plistlib.loads(archive.read(plists[0]))
        contents = plists[0].removesuffix("Info.plist")
        binary = contents + "MacOS/" + plist["CFBundleExecutable"]
        if not ((archive.getinfo(binary).external_attr >> 16) & 0o111):
            raise ValueError("Mac executable permission is missing")
        with archive.open(binary) as stream:
            architectures = macho_architectures(stream.read(4096))
        if architectures != {"arm64", "x86_64"}:
            raise ValueError("Mac export must include Apple Silicon and Intel")
        packs = [name for name in archive.namelist() if name.endswith(".pck")]
        if len(packs) != 1 or archive.getinfo(packs[0]).file_size < 1_000_000:
            raise ValueError("Mac game data is missing")
        return {"architectures": sorted(architectures), "bundle_identifier": plist["CFBundleIdentifier"],
                "binary": binary, "pack": packs[0], "archive_modes_verified": True}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", type=Path, required=True)
    parser.add_argument("--platform", choices=["linux", "macos"], required=True)
    args = parser.parse_args()
    godot = args.godot.resolve(strict=True)
    version, build, schema = build_identity(ROOT / "autoload/BuildInfo.gd")
    engine = subprocess.check_output([godot, "--version"], text=True).strip()
    if not engine.startswith(ENGINE + "."):
        raise ValueError(f"Expected {ENGINE}, found {engine}")
    name = f"ForeignToAll-{version}-{build}-{args.platform}"
    package = ROOT / "build" / name
    archive = package.with_name(name + (".tar.gz" if args.platform == "linux" else "-private-test.zip"))
    if package.exists() or archive.exists():
        raise FileExistsError(f"Never replace a candidate: {package}")
    package.mkdir(parents=True)
    logs = ROOT / ".build" / name
    logs.mkdir(parents=True, exist_ok=True)
    env = os.environ.copy()
    # Exports and release-note scripts never see the player's real profile.
    if os.name == "nt":
        templates = Path(env["APPDATA"]) / "Godot/export_templates" / ENGINE
        env["APPDATA"] = str(logs / "profile")
        isolated = Path(env["APPDATA"]) / "Godot/export_templates" / ENGINE
        isolated.mkdir(parents=True, exist_ok=True)
        required = ["version.txt", "icudt_godot.dat"]
        required += ["macos.zip"] if args.platform == "macos" else ["linux_release.x86_64", "linux_debug.x86_64"]
        for item in required:
            shutil.copy2(templates / item, isolated / item)
    else:
        raise RuntimeError("This export entry point uses the configured Windows template installation")
    output = package / "ForeignToAll.x86_64" if args.platform == "linux" else logs / "ForeignToAll.zip"
    preset = "Linux" if args.platform == "linux" else "macOS"
    text = run([godot, "--headless", "--path", ROOT, "--export-release", preset, output],
               logs / "export.log", env=env)
    if re.search(r"Storing File: res://(?:tools|trailer|docs|Foreign to All|\.build|build)/", text):
        raise ValueError("Export contains development-only files")
    if not output.is_file():
        raise ValueError("Export did not produce the executable/archive")
    details = {}
    if args.platform == "linux":
        with output.open("rb") as stream:
            header = stream.read(20)
        if header[:6] != b"\x7fELF\x02\x01" or struct.unpack_from("<H", header, 18)[0] != 62:
            raise ValueError("Expected Linux x86_64 ELF executable")
        if not (package / "ForeignToAll.pck").is_file():
            raise ValueError("Linux game data is missing")
        details = {"architectures": ["x86_64"], "binary": output.name, "pack": "ForeignToAll.pck"}
    else:
        details = inspect_mac(output)
    run([godot, "--headless", "--path", ROOT, "--script", "res://tools/export_release_notes.gd", "--", package],
        logs / "notices.log", env=env)
    for required in ("CREDITS.txt", "THIRD-PARTY-NOTICES.txt"):
        if not (package / required).is_file():
            raise ValueError(f"Missing {required}")
    shutil.copy2(ROOT / "docs/beta-player-guide.md", package / "PLAYER-GUIDE.md")
    shutil.copy2(ROOT / f"docs/beta-{args.platform}.md", package / "START-HERE.md")
    commit = subprocess.check_output(["git", "-C", ROOT, "rev-parse", "HEAD"], text=True).strip()
    status = subprocess.check_output(["git", "-C", ROOT, "status", "--porcelain", "--untracked-files=all"], text=True)
    changed = [line[3:].strip('"') for line in status.splitlines()]
    dirty = [path for path in changed if not path.startswith(("tools/", "docs/", "Foreign to All/", "trailer/", ".build/", "build/"))]
    manifest = {"game": "Foreign to All", "version": version, "build_id": build, "save_schema": schema,
                "platform": args.platform, "engine": engine, "source_base_commit": commit,
                "source_uncommitted_files": dirty, "created_utc": datetime.now(timezone.utc).isoformat(),
                "native_testing": "pending", "signing": "ad-hoc; not notarized" if args.platform == "macos" else "not applicable",
                "export_sha256": sha256(output), **details}
    (package / "build-manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    if args.platform == "linux":
        linux_archive(package, archive)
    else:
        mac_archive(output, package, archive)
    checksum = sha256(archive)
    archive.with_name(archive.name + ".sha256").write_text(f"{checksum}  {archive.name}\n", encoding="ascii")
    print(json.dumps({"archive": str(archive), "sha256": checksum, "native_testing": "pending"}, indent=2))


if __name__ == "__main__":
    main()

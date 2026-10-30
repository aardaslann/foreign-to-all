"""Run native checks against an immutable, already-exported desktop package."""

import argparse
import json
import os
from pathlib import Path
import platform
import re
import subprocess
import tarfile
import urllib.request
import zipfile

from desktop_distribution import run, safe_member, sha256


EDITORS = {
    "Linux": ("Godot_v4.7.2-stable_linux.x86_64.zip", "cadd3204e728a35d3f13adb7fd0d7902636b79f6b95c40c265eb73b6c35329e4"),
    "Darwin": ("Godot_v4.7.2-stable_macos.universal.zip", "c58a24e31d720be9d62f60cb5627c4e695fb72f21b0cfe1bc9ccaa9a3b3ba63e"),
}
SUITES = [
    ("beta_journey_test.gd", False, "BETA JOURNEY:", 944),
    ("beta_mechanics_test.gd", False, "BETA MECHANICS:", 1075),
    ("quest_guidance_edge_test.gd", False, "QUEST GUIDANCE EDGES:", 51),
    ("player_feedback_test.gd", False, "PLAYER FEEDBACK:", 71),
    ("word_affordance_test.gd", True, "WORD AFFORDANCE:", 66),
    ("player_feedback_ui_review.gd", True, "FEEDBACK UI:", 102),
    ("packaged_smoke.gd", True, "PACKAGE:", 139),
]


def checked_download(url, destination, checksum):
    urllib.request.urlretrieve(url, destination)
    if sha256(destination) != checksum:
        raise ValueError(f"Download checksum mismatch: {destination.name}")


def suite_result(text, marker, minimum):
    match = re.search(re.escape(marker) + r"\s*(\d+) checks[;,]\s*(\d+) failures", text)
    if not match or int(match[1]) < minimum or int(match[2]):
        raise RuntimeError(f"Missing complete successful result for {marker}")
    return int(match[1])


def check_libraries(text):
    if "not found" in text:
        raise RuntimeError("A required native shared library is missing")


def profile_environment(profile):
    env = os.environ.copy()
    if platform.system() == "Linux":
        env["XDG_DATA_HOME"] = str(profile / "data")
        env["XDG_CONFIG_HOME"] = str(profile / "config")
        env["XDG_CACHE_HOME"] = str(profile / "cache")
    else:
        env["HOME"] = str(profile)
    return env


def execute(command, log, *, graphical=False, env=None):
    if graphical and platform.system() == "Linux":
        command = ["xvfb-run", "-a", "-s", "-screen 0 1920x1080x24", *command]
    return run(command, log, timeout=240, env=env)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--archive", required=True, type=Path)
    parser.add_argument("--sha256", required=True)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    archive = args.archive.resolve(strict=True)
    if sha256(archive) != args.sha256:
        raise ValueError("Candidate checksum mismatch")
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    profile = out / "test-profile"
    profile.mkdir()
    env = profile_environment(profile)
    report = {"system": platform.system(), "os_version": platform.platform(),
              "architecture": platform.machine(), "archive": archive.name,
              "archive_sha256": args.sha256, "suites": [], "complete": False,
              "limitations": ["No human audio/controller evaluation", "No Gatekeeper/notarization approval"]}
    try:
        extracted = out / "extracted"
        extracted.mkdir()
        if platform.system() == "Linux":
            with tarfile.open(archive) as tar:
                tar.extractall(extracted, filter="data")
            binary = next(extracted.glob("*/ForeignToAll.x86_64"))
            pack = binary.with_suffix(".pck")
            if not os.access(binary, os.X_OK):
                raise ValueError("Downloaded Linux binary lost executable permission")
            check_libraries(run(["ldd", binary], out / "native-libraries.log"))
        elif platform.system() == "Darwin":
            with zipfile.ZipFile(archive) as bundle:
                for info in bundle.infolist(): safe_member(info.filename)
            run(["ditto", "-x", "-k", archive, extracted], out / "extract.log")
            app = next(extracted.glob("*.app"))
            binary = next((app / "Contents/MacOS").iterdir())
            pack = next((app / "Contents/Resources").glob("*.pck"))
            run(["codesign", "--verify", "--deep", "--strict", "--verbose=2", app], out / "codesign.log")
            run(["lipo", "-archs", binary], out / "architectures.log")
            report["adhoc_signature_verified"] = True
        else:
            raise ValueError("Must run on native Linux or macOS")
        # A real release executable starts independently of the editor-host tests.
        execute([binary, "--headless", "--quit-after", "120"], out / "release-headless.log", env=env)
        execute([binary, "--audio-driver", "Dummy", "--quit-after", "180"],
                out / "release-graphical.log", graphical=True, env=env)
        report["release_startup"] = "headless and graphical passed"
        asset, checksum = EDITORS[platform.system()]
        editor_zip = out / asset
        checked_download("https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/" + asset,
                         editor_zip, checksum)
        editor_dir = out / "editor"
        editor_dir.mkdir()
        if platform.system() == "Darwin":
            run(["ditto", "-x", "-k", editor_zip, editor_dir], out / "editor-extract.log")
            editor = editor_dir / "Godot.app/Contents/MacOS/Godot"
        else:
            with zipfile.ZipFile(editor_zip) as source: source.extractall(editor_dir)
            editor = editor_dir / "Godot_v4.7.2-stable_linux.x86_64"
            editor.chmod(0o755)
        scripts = Path(__file__).resolve().parent
        for script, graphical, marker, minimum in SUITES:
            capture = out / Path(script).stem
            command = [editor, "--main-pack", pack, "--script", scripts / script,
                       "--audio-driver", "Dummy", "--quit-after", "30000"]
            if not graphical: command.append("--headless")
            command += ["--", capture, "--editor-host"]
            text = execute(command, out / (Path(script).stem + ".log"), graphical=graphical, env=env)
            checks = suite_result(text, marker, minimum)
            report["suites"].append({"script": script, "checks": checks, "failures": 0,
                                     "mode": "graphical editor host" if graphical else "headless editor host"})
            print(f"PASS {script}: {checks} checks", flush=True)
        report["complete"] = True
    finally:
        (out / "native-report.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()

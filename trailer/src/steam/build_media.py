"""Build the Steam page's raster and loop media from real game captures.

Inputs (all real renders of the game, never mock-ups):
  * graphical story-run captures, 1920x1080 PNG (BETA_CAPTURES, 2026-10-04)
  * Berlin discovery captures from tools/steam_discovery_capture.gd (.build/steam-capture/out)
  * movie-writer footage at 30 fps from tools/steam_film_capture.gd, transcoded
    to trailer/public/steam/film/*.mp4 (see trailer/src/steam/README.md)

Outputs go to trailer/out/steam-page/assets/ (gitignored, like every render):
  screenshots/ss_XX_*.jpg   12 gallery screenshots, 1920x1080
  about/*.gif               About-section loops for upload (each under 5 MB, ~14 MB total)
  about/*.webm              the same loops at 780 px, for editors that accept WebM
  about/*.mp4               1280 px masters the GIF and WebM are made from
  community_icon_184.jpg    from the TikTok glyph-Earth avatar
  ../index.html             the local preview, rendered from docs/steam/page/

    python trailer/src/steam/build_media.py
"""
from __future__ import annotations

import os
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FILM = ROOT / "trailer/public/steam/film"
OUT = ROOT / "trailer/out/steam-page/assets"
BETA_CAPTURES = Path("C:/Users/Arda/Documents/ForeignToAll/work/beta")
DISCOVERY = ROOT / ".build/steam-capture/out"
MB = 1024 * 1024
# Steam allows 5 MB per description image and asks for 15 MB in total, so
# every loop gets its own share (the hero banner is built in Remotion).
BUDGET = {"arrive": 3.0, "word": 1.2, "encounter": 2.4, "thought": 2.0, "cities": 4.0, "hero": 2.8}

# Gallery order matters: the first four appear when the game is hovered in lists.
SCREENSHOTS = [
    ("istanbul-tea", BETA_CAPTURES / "istanbul-story-review/2-dialog.png"),
    ("tokyo-ueno", BETA_CAPTURES / "tokyo-story-review/0-action.png"),
    ("word-to-keep", DISCOVERY / "discovery-1-1-meaning.png"),
    ("mumbai-bhuleshwar", BETA_CAPTURES / "mumbai-story-review/1-action.png"),
    ("berlin-first-words", DISCOVERY / "dialog-1-0.png"),
    ("berlin-a-seat", ("berlin", 89.0)),
    ("paris-marais", BETA_CAPTURES / "paris-story-review/0-carry.png"),
    ("field-notes", BETA_CAPTURES / "review/journal-Phrases.png"),
    ("mexico-coyoacan-night", BETA_CAPTURES / "mexico-story-review/0-action.png"),
    ("london-plain-english", BETA_CAPTURES / "london-story-review/1-dialog.png"),
    ("moscow-basmanny", BETA_CAPTURES / "moscow-story-review/0-carry.png"),
    ("istanbul-han", BETA_CAPTURES / "istanbul-story-review/0-carry.png"),
]

# (name, source film, start, end, crop "w:h:x:y" or None)
LOOPS = [
    ("arrive", "berlin", 1.2, 8.0, None),
    ("word", "berlin", 8.1, 14.7, "1120:630:400:225"),
    ("encounter", "london", 7.4, 11.7, "1020:574:0:506"),
    ("thought", "berlin", 87.3, 90.6, "1280:720:160:260"),
]
MONTAGE = ["tokyo", "mumbai", "istanbul", "paris", "mexico", "moscow", "london"]
MONTAGE_SPAN = (4.3, 5.5)


def run(*args: str) -> None:
    subprocess.run(["ffmpeg", "-loglevel", "error", "-y", *args], check=True)


def screenshots() -> None:
    dest = OUT / "screenshots"
    dest.mkdir(parents=True, exist_ok=True)
    for i, (name, src) in enumerate(SCREENSHOTS, 1):
        target = dest / f"ss_{i:02d}_{name}.jpg"
        if isinstance(src, tuple):
            film, at = src
            run("-ss", str(at), "-i", str(FILM / f"{film}.mp4"), "-frames:v", "1", "-q:v", "2", str(target))
        else:
            if not src.exists():
                sys.exit(f"missing capture: {src}")
            run("-i", str(src), "-q:v", "2", str(target))


def gif(mp4: Path, target: Path) -> None:
    """Palette GIF; steps frame rate, then width, down until it fits its budget."""
    limit = BUDGET[target.stem] * MB
    for width, fps in ((780, 15), (780, 12), (780, 10), (680, 10), (616, 9), (560, 8)):
        graph = (f"fps={fps},scale={width}:-1:flags=lanczos,split[a][b];"
                 "[a]palettegen=max_colors=160:stats_mode=diff[p];[b][p]paletteuse=dither=sierra2_4a:diff_mode=rectangle")
        run("-i", str(mp4), "-filter_complex", graph, "-loop", "0", str(target))
        if target.stat().st_size <= limit:
            print(f"{target.name}: {width}px {fps} fps")
            return
    print(f"warning: {target.name} is {target.stat().st_size / MB:.1f} MB", file=sys.stderr)


def webm(mp4: Path) -> None:
    """A sharper, smaller loop for editors that accept WebM, plus its first frame as the preview's poster."""
    run("-i", str(mp4), "-vf", "scale=780:-2:flags=lanczos", "-an", "-c:v", "libvpx-vp9", "-b:v", "0", "-crf", "34",
        "-row-mt", "1", "-deadline", "good", str(mp4.with_suffix(".webm")))
    # the poster is the frame most like the loop's point: late enough that bubbles and panels are open
    at = {"hero": 5.0, "word": 4.5}.get(mp4.stem, 0.0)
    run("-ss", str(at), "-i", str(mp4), "-vf", "scale=780:-2:flags=lanczos", "-frames:v", "1", "-q:v", "3", str(mp4.with_suffix(".jpg")))


def loops() -> None:
    dest = OUT / "about"
    dest.mkdir(parents=True, exist_ok=True)
    for name, film, start, end, crop in LOOPS:
        mp4 = dest / f"{name}.mp4"
        vf = (f"crop={crop}," if crop else "") + "scale=1280:-2:flags=lanczos"
        run("-ss", str(start), "-to", str(end), "-i", str(FILM / f"{film}.mp4"), "-vf", vf, "-an",
            "-c:v", "libx264", "-crf", "18", "-pix_fmt", "yuv420p", "-movflags", "+faststart", str(mp4))
        gif(mp4, dest / f"{name}.gif")
        webm(mp4)
    # Eight cities: hard cuts between real walks, one after another.
    a, b = MONTAGE_SPAN
    inputs: list[str] = []
    for city in MONTAGE:
        inputs += ["-ss", str(a), "-to", str(b), "-i", str(FILM / f"{city}.mp4")]
    graph = "".join(f"[{i}:v]scale=1280:720:flags=lanczos,setsar=1[v{i}];" for i in range(len(MONTAGE)))
    graph += "".join(f"[v{i}]" for i in range(len(MONTAGE))) + f"concat=n={len(MONTAGE)}:v=1:a=0[o]"
    mp4 = dest / "cities.mp4"
    run(*inputs, "-filter_complex", graph, "-map", "[o]", "-c:v", "libx264", "-crf", "18", "-pix_fmt", "yuv420p",
        "-movflags", "+faststart", str(mp4))
    gif(mp4, dest / "cities.gif")
    webm(mp4)


def hero() -> None:
    """The banner is rendered by Remotion first (npx remotion render SteamAboutHero ...)."""
    mp4 = OUT / "about/hero.mp4"
    if mp4.exists():
        gif(mp4, OUT / "about/hero.gif")
        webm(mp4)
    else:
        print("hero.mp4 not rendered yet; skipping its GIF", file=sys.stderr)


def master_trailer() -> None:
    """Bring Remotion's render up to store loudness (about -15 LUFS); the picture is copied untouched."""
    src = OUT / "trailer_gameplay_1080p.mp4"
    if not src.exists():
        print("trailer not rendered yet; skipping its master", file=sys.stderr)
        return
    tmp = src.with_name("trailer_gameplay_master.mp4")
    run("-i", str(src), "-c:v", "copy", "-af", "loudnorm=I=-15:TP=-1.5:LRA=11", "-ar", "48000", "-c:a", "aac", "-b:a", "320k",
        "-movflags", "+faststart", str(tmp))
    tmp.replace(src)


def preview() -> None:
    """Render the local preview from the same files that get pasted into Steamworks."""
    import json
    import re
    docs = ROOT / "docs/steam/page"
    data = {
        "short": (docs / "short-description.txt").read_text(encoding="utf-8").strip(),
        "about": (docs / "about.bbcode").read_text(encoding="utf-8"),
        "fields": (docs / "store-fields.md").read_text(encoding="utf-8"),
    }
    blob = json.dumps(data, ensure_ascii=False).replace("</", "<\\/")
    template = (Path(__file__).parent / "preview.html").read_text(encoding="utf-8")
    page = re.sub(r"/\*__DATA__\*/.*?/\*__END__\*/", lambda _: blob, template, count=1, flags=re.S)
    (OUT.parent / "index.html").write_text(page, encoding="utf-8")


def icon() -> None:
    src = ROOT / "trailer/public/steam/glyph-earth.png"
    run("-i", str(src), "-vf", "scale=184:184:flags=lanczos", "-q:v", "2", str(OUT / "community_icon_184.jpg"))


if __name__ == "__main__":
    if shutil.which("ffmpeg") is None:
        sys.exit("ffmpeg is required")
    OUT.mkdir(parents=True, exist_ok=True)
    os.chdir(ROOT)
    screenshots()
    loops()
    hero()
    icon()
    master_trailer()
    preview()
    for path in sorted(OUT.rglob("*")):
        if path.is_file() and path.suffix in {".gif", ".jpg", ".mp4", ".webm"}:
            print(f"{path.relative_to(OUT)}  {path.stat().st_size / 1e6:.2f} MB")

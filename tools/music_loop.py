"""Turn a downloaded Suno track into a seamless in-game loop.

    python tools/music_loop.py <source.mp3|wav> <name> [--suno <song id>] [--dir <folder>]

A generated track has an intro and an ending and plays once; the game needs
music that runs under exploration for as long as the player stays. So this
finds the two moments in the body of the track that sound most alike - the
same beat, the same chord, the same instruments - and cuts between them, so
the end of the loop flows back into its start without a seam you can hear:

  1. decode, and describe every 23 ms by its energy in 32 log-spaced bands
  2. find where the intro has arrived and where the ending begins to leave
  3. compare every 3-second stretch near the start of the body with every one
     near its end, and take the most alike pair at least MIN_LOOP apart
  4. line the two up to the exact sample by cross-correlation, cross-fade the
     join, level the loudness, and encode Ogg Vorbis (which Godot loops
     gaplessly, unlike MP3)

It also measures what a listener would: tempo, how steady the energy is
(background music must not swell and drop), and how alike the join is. The
numbers go in music.json next to the loop. Takes being compared are cut into
.build/music-candidates (--dir); tools/music_promote.py puts the chosen one in
audio/music/, and tools/music_audition.py plays them side by side.
"""
from __future__ import annotations

import argparse
import datetime
import json
import subprocess
import sys
from pathlib import Path

import numpy as np

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "audio/music"
REPORT = OUT_DIR / "music.json"
SR = 44100
HOP = 1024                 # ~23 ms
BANDS = 32
WINDOW_S = 3.0             # how much must match either side of the join
MIN_LOOP = 45.0            # seconds; shorter loops get noticed
LOUDNESS = -20.0           # LUFS; under the voices at -18
XFADE_S = 0.03


def decode(path: Path) -> np.ndarray:
    raw = subprocess.run(["ffmpeg", "-v", "error", "-i", str(path), "-f", "f32le", "-ac", "2",
                          "-ar", str(SR), "pipe:1"], capture_output=True, check=True).stdout
    return np.frombuffer(raw, dtype=np.float32).reshape(-1, 2).copy()


def features(x: np.ndarray) -> np.ndarray:
    mono = x.mean(axis=1)
    win = np.hanning(2048).astype(np.float32)
    n = (mono.size - 2048) // HOP
    frames = np.lib.stride_tricks.sliding_window_view(mono, 2048)[::HOP][:n] * win
    mag = np.abs(np.fft.rfft(frames, axis=1))
    # Band edges by bin, so the narrow low bands (a bin is 21.5 Hz wide) are
    # never empty; ~40 Hz to ~16 kHz, log-spaced.
    edges = np.unique(np.geomspace(2, 743, BANDS + 1).astype(int))
    bands = np.stack([mag[:, lo:max(hi, lo + 1)].mean(axis=1)
                      for lo, hi in zip(edges[:-1], edges[1:])], axis=1)
    return np.log1p(bands * 10).astype(np.float32)


def tempo(F: np.ndarray) -> float:
    """The strongest beat period between 80 and 160 BPM in the onset envelope."""
    onset = np.maximum(np.diff(F, axis=0), 0).sum(axis=1)
    onset = onset - onset.mean()
    ac = np.correlate(onset, onset, "full")[onset.size - 1:]
    ac = ac / (onset.size - np.arange(ac.size))          # unbiased: no pull to short lags
    fps = SR / HOP
    lags = np.arange(int(np.ceil(fps * 60 / 160)), int(fps * 60 / 80) + 1)
    peaks = [l for l in lags if ac[l] >= ac[l - 1] and ac[l] >= ac[l + 1]]
    lag = max(peaks, key=lambda l: ac[l]) if peaks else lags[np.argmax(ac[lags])]
    return float(60 * fps / lag)


def body(x: np.ndarray) -> tuple[int, int, np.ndarray]:
    """First and last sample of the part of the track at full strength."""
    sec = SR
    rms = np.array([np.sqrt(np.mean(x[i:i + sec] ** 2)) for i in range(0, x.shape[0] - sec, sec // 2)])
    med = np.median(rms)
    start = next((i for i, r in enumerate(rms) if r >= 0.8 * med), 0)
    end = len(rms) - 1
    while end > start and rms[end] < 0.75 * med:
        end -= 1
    return start * sec // 2, min(x.shape[0], end * sec // 2 + sec // 2 - 3 * sec), rms


def find_loop(x: np.ndarray, F: np.ndarray, lo: int, hi: int) -> tuple[int, int, float]:
    fps = SR / HOP
    w = int(WINDOW_S * fps)
    f_lo, f_hi = lo // HOP, hi // HOP - w
    span = f_hi - f_lo
    min_gap = int(MIN_LOOP * fps)
    if span < min_gap + w:
        raise SystemExit(f"only {span / fps:.0f}s at full strength; need {MIN_LOOP + WINDOW_S:.0f}s")
    stride = 2

    def windows(starts):
        out = np.stack([F[s:s + w:stride].ravel() for s in starts])
        out -= out.mean(axis=1, keepdims=True)
        return out / (np.linalg.norm(out, axis=1, keepdims=True) + 1e-9)

    a_range = np.arange(f_lo, min(f_lo + int(35 * fps), f_hi - min_gap))
    b_range = np.arange(max(f_lo + min_gap, f_hi - int(60 * fps)), f_hi)
    S = windows(a_range) @ windows(b_range).T
    gap = b_range[None, :] - a_range[:, None]
    S[gap < min_gap] = -1
    # Among joins that are nearly as good, the longer loop: every extra second
    # is a second before the player hears it come round again.
    score = S + 0.04 * (gap / max(span, 1))
    score[gap < min_gap] = -1
    i, j = np.unravel_index(np.argmax(score), score.shape)
    a, b = int(a_range[i]) * HOP, int(b_range[j]) * HOP
    # To the sample: slide b within a hop so its waveform lines up with a's.
    mono = x.mean(axis=1)
    ref = mono[a:a + 4096]
    best, shift = -1e9, 0
    for d in range(-HOP, HOP + 1, 4):
        seg = mono[b + d:b + d + 4096]
        if seg.size < ref.size:
            continue
        c = float(np.dot(ref, seg) / (np.linalg.norm(ref) * np.linalg.norm(seg) + 1e-9))
        if c > best:
            best, shift = c, d
    return a, b + shift, float(S[i, j])


def loudness(audio: np.ndarray) -> float:
    proc = subprocess.run(["ffmpeg", "-hide_banner", "-f", "f32le", "-ar", str(SR), "-ac", "2", "-i", "pipe:0",
                           "-af", "ebur128=framelog=quiet", "-f", "null", "-"],
                          input=audio.astype(np.float32).tobytes(), capture_output=True, check=True)
    text = proc.stderr.decode("utf-8", "replace")
    tail = text[text.rfind("Integrated loudness"):]
    return float(tail.split("I:")[1].split("LUFS")[0].strip())


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("source")
    ap.add_argument("name")
    ap.add_argument("--suno", default="")
    ap.add_argument("--dir", default=str(OUT_DIR),
                    help="where the loop goes; candidates go to .build/music-candidates")
    a = ap.parse_args()
    out_dir = Path(a.dir)
    report_path = out_dir / "music.json"
    src = Path(a.source)
    x = decode(src)
    F = features(x)
    lo, hi, rms = body(x)
    start, end, seam = find_loop(x, F, lo, hi)
    loop = x[start:end].copy()
    n = int(XFADE_S * SR)
    ramp = np.linspace(0, 1, n, dtype=np.float32)[:, None]
    loop[-n:] = loop[-n:] * np.sqrt(1 - ramp) + x[start - n:start] * np.sqrt(ramp)
    gain = 10 ** ((LOUDNESS - loudness(loop)) / 20)
    loop = np.clip(loop * gain, -0.98, 0.98)
    out_dir.mkdir(parents=True, exist_ok=True)
    out = out_dir / f"{a.name}.ogg"
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-f", "f32le", "-ar", str(SR), "-ac", "2", "-i", "pipe:0",
                    "-c:a", "libvorbis", "-q:a", "6", str(out)], input=loop.tobytes(), check=True)
    body_rms = rms[lo // (SR // 2): hi // (SR // 2)]
    report = json.loads(report_path.read_text(encoding="utf-8")) if report_path.exists() else {}
    report[a.name] = {
        "file": f"res://audio/music/{out.name}", "source": src.name, "suno_id": a.suno,
        "track_seconds": round(x.shape[0] / SR, 1), "bpm": round(tempo(F), 1),
        "loop_start": round(start / SR, 3), "loop_seconds": round((end - start) / SR, 2),
        "seam_likeness": round(seam, 3),
        "steadiness": round(1 - float(np.std(body_rms) / (np.mean(body_rms) + 1e-9)), 3),
        "intro_seconds": round(lo / SR, 1), "outro_seconds": round((x.shape[0] - hi) / SR, 1),
        "lufs": LOUDNESS, "made": datetime.date.today().isoformat()}
    report_path.write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
    r = report[a.name]
    print(f"{a.name}: {r['bpm']} BPM, loop {r['loop_seconds']}s from {r['loop_start']}s, seam {r['seam_likeness']}, "
          f"steadiness {r['steadiness']}, intro {r['intro_seconds']}s, outro {r['outro_seconds']}s -> {out.name}")


if __name__ == "__main__":
    main()

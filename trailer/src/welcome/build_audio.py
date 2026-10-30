"""The soundtrack for "Welcome": the Suno track cut on its bar lines, the game's
own voices, and sound design synthesised on every cue in timeline.json.

    python trailer/src/welcome/build_audio.py

Writes public/welcome/mix.wav (music, voices, sound) and nomusic.wav (voices
and sound only, at the same gain, for laying a TikTok sound over the picture).
Python needs only numpy; FFmpeg must be on PATH.

The typed lines, pen strokes and pops below repeat a few timings from the
scenes (typing speeds, offsets from their cues); change both together.
"""
from __future__ import annotations

import json
import math
import subprocess
from pathlib import Path

import numpy as np

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
OUT = HERE.parents[1] / "public" / "welcome"
V7_SFX = HERE.parent / "understanding-v7" / "sfx"
SR = 48000
T = json.loads((HERE / "timeline.json").read_text(encoding="utf-8"))
COPY = T["copy"]
BEAT = T["beat"]
LENGTH = int(T["duration"] * SR)
TARGET_LUFS, TRUE_PEAK = -14.0, -1.0       # what TikTok, Reels and Shorts normalise towards
RNG = np.random.default_rng(1010)
FOREIGN_WORDS = {"fremd", "etranger", "chuzhoy", "yabanci", "pardesi", "gaijin", "extranjero"}


def bar(k: float, b: float = 0) -> float:
    return T["b0"] + (k * 4 + b) * BEAT


def at_spec(spec: str) -> float:
    k, b = spec.split(":")
    return bar(float(k), float(b))


def cue(name: str) -> float:
    return at_spec(T["cues"][name])


# ── I/O and small DSP (as revision 7's build_audio.py) ───────────────────────

def decode(path: Path, channels: int = 2) -> np.ndarray:
    raw = subprocess.run(["ffmpeg", "-v", "error", "-i", str(path), "-f", "f32le", "-ac", str(channels),
                          "-ar", str(SR), "pipe:1"], capture_output=True, check=True).stdout
    x = np.frombuffer(raw, dtype=np.float32).astype(np.float64)
    return x.reshape(-1, channels) if channels > 1 else x


def db(gain_db: float) -> float:
    return 10 ** (gain_db / 20)


def place(bus: np.ndarray, clip: np.ndarray, at: float, gain_db: float = 0.0, pan: float = 0.0) -> None:
    start = int(round(at * SR))
    if start < 0:
        clip, start = clip[-start:], 0
    if start >= len(bus):
        return
    if clip.ndim == 1:
        clip = np.stack([clip * math.sqrt((1 - pan) / 2), clip * math.sqrt((1 + pan) / 2)], axis=1) * 1.414
    clip = clip[: len(bus) - start] * db(gain_db)
    bus[start:start + len(clip)] += clip


def spectral(x: np.ndarray, keep) -> np.ndarray:
    spec = np.fft.rfft(x, axis=0)
    f = np.fft.rfftfreq(x.shape[0], 1 / SR)
    gain = keep(f)
    spec *= gain[:, None] if x.ndim == 2 else gain
    return np.fft.irfft(spec, x.shape[0], axis=0)


def lowpass(x: np.ndarray, hz: float) -> np.ndarray:
    return spectral(x, lambda f: 1 / np.sqrt(1 + (f / hz) ** 4))


def highpass(x: np.ndarray, hz: float) -> np.ndarray:
    return spectral(x, lambda f: 1 / np.sqrt(1 + (hz / np.maximum(f, 1e-3)) ** 4))


def bandpass(x: np.ndarray, lo: float, hi: float) -> np.ndarray:
    return highpass(lowpass(x, hi), lo)


def secs(seconds: float) -> np.ndarray:
    return np.arange(int(seconds * SR)) / SR


def noise(seconds: float) -> np.ndarray:
    return RNG.uniform(-1, 1, int(seconds * SR))


def fades(x: np.ndarray, a: float = 0.004, r: float = 0.02) -> np.ndarray:
    n = len(x)
    env = np.minimum(np.arange(n) / max(1, a * SR), 1) * np.minimum(np.arange(n)[::-1] / max(1, r * SR), 1)
    return x * (env[:, None] if x.ndim == 2 else env)


def norm(x: np.ndarray, peak: float = 1.0) -> np.ndarray:
    return x / max(float(np.max(np.abs(x))), 1e-9) * peak


def room(x: np.ndarray, wet: float, length: float = 1.4, decay: float = 0.32) -> np.ndarray:
    """A small synthetic room: decaying filtered noise, convolved by FFT."""
    rng = np.random.default_rng(77)
    t = secs(length)
    ir = lowpass(rng.normal(0, 1, len(t)) * np.exp(-t / decay), 4500)
    ir /= np.sqrt(np.sum(ir ** 2))
    size = 1 << (len(x) + len(ir) - 1).bit_length()
    tail = np.fft.irfft(np.fft.rfft(x, size) * np.fft.rfft(ir, size), size)[: len(x) + len(ir)]
    out = np.zeros(len(tail))
    out[: len(x)] += x
    return out + wet * tail


# ── Sounds ───────────────────────────────────────────────────────────────────

def whoosh(seconds: float, f0: float, f1: float, rise: float = 0.5, width: float = 0.9) -> np.ndarray:
    """Noise through a band that sweeps f0 → f1, swelling to `rise` of its length."""
    hop, size = 256, 1024
    n = int(seconds * SR)
    x = RNG.normal(0, 1, n + size)
    out = np.zeros(n + size)
    window = np.hanning(size)
    freqs = np.fft.rfftfreq(size, 1 / SR)
    frames = n // hop + 1
    for i in range(frames):
        s = i / max(1, frames - 1)
        centre = f0 * (f1 / f0) ** s
        mask = np.exp(-0.5 * (np.log2(np.maximum(freqs, 1) / centre) / width) ** 2)
        seg = x[i * hop:i * hop + size] * window
        out[i * hop:i * hop + size] += np.fft.irfft(np.fft.rfft(seg) * mask, size) * window
    out = out[:n]
    t = np.arange(n) / n
    env = np.where(t < rise, (t / rise) ** 2, ((1 - t) / (1 - rise)) ** 1.6)
    return norm(out * env, 0.5)


def thump(f0: float = 70, f1: float = 38, seconds: float = 0.5, click: float = 0.4) -> np.ndarray:
    t = secs(seconds)
    f = f1 + (f0 - f1) * np.exp(-t * 18)
    body = np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t * 7)
    tick = highpass(noise(seconds), 1800) * np.exp(-t * 160) * click
    return fades(norm(body + tick, 0.9), 0.0005, 0.02)


def blip(freq: float, seconds: float = 0.06) -> np.ndarray:
    t = secs(seconds)
    f = freq * (1 - 0.12 * t / seconds)
    square = np.sign(np.sin(2 * np.pi * np.cumsum(f) / SR))
    return fades(lowpass(square, 4200) * np.exp(-t * 38) * 0.35, 0.001, 0.01)


def pop(freq: float, seconds: float = 0.09) -> np.ndarray:
    t = secs(seconds)
    f = freq * (0.55 + 0.45 * np.exp(-t * 60))
    return fades(np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t * 34) * 0.6, 0.001, 0.01)


def pen(seconds: float, rough: float = 1.0) -> np.ndarray:
    """A pen on paper: band noise in strokes, faster when `rough`."""
    n = int(seconds * SR)
    rate = 14 + 10 * rough
    strokes = np.repeat(RNG.uniform(0.35, 1, int(seconds * rate) + 2), int(SR / rate) + 1)[:n]
    strokes = np.convolve(strokes, np.ones(400) / 400, mode="same")
    grit = bandpass(noise(seconds), 1400, 7000) * strokes + 0.4 * bandpass(noise(seconds), 5500, 11000) * strokes ** 2
    return fades(norm(grit, 0.35), 0.02, 0.04)


def shimmer(seconds: float = 1.3, low: float = 1800, high: float = 6200, count: int = 14) -> np.ndarray:
    t = secs(seconds)
    out = np.zeros(len(t))
    for _ in range(count):
        start = RNG.uniform(0, 0.35)
        env = np.where(t >= start, np.exp(-(t - start) * RNG.uniform(3, 6)), 0)
        out += np.sin(2 * np.pi * RNG.uniform(low, high) * t + RNG.uniform(0, 6)) * env
    return fades(norm(out, 0.3), 0.003, 0.2)


def riser(seconds: float) -> np.ndarray:
    x = whoosh(seconds, 250, 7000, rise=0.97, width=1.1)
    t = secs(seconds)[: len(x)]
    tone = np.sin(2 * np.pi * np.cumsum(180 * 2 ** (3 * t / seconds)) / SR) * (t / seconds) ** 3 * 0.25
    return x + tone


def crash(seconds: float = 1.6) -> np.ndarray:
    t = secs(seconds)
    return norm(highpass(noise(seconds), 2600) * np.exp(-t * 3.2), 0.4)


def splat() -> np.ndarray:
    t = secs(0.35)
    wet = lowpass(noise(0.35), 1600) * np.exp(-t * 22)
    return norm(wet + 0.6 * thump(120, 50, 0.35, 0.2)[: len(t)], 0.8)


def sample(name: str) -> np.ndarray:
    return decode(V7_SFX / name, 1)


def key_sample() -> np.ndarray:
    """One soft key from revision 7's keyboard recording (CC0)."""
    source = sample("keyboard-soft.wav")
    peak = int(np.argmax(np.abs(source)))
    key = source[max(0, peak - round(.013 * SR)):peak + round(.115 * SR)]
    return fades(norm(bandpass(key, 110, 3400), 0.5), 0.0015, 0.018)


def varied(x: np.ndarray, rate: float) -> np.ndarray:
    n = int(len(x) / rate)
    return np.interp(np.linspace(0, len(x) - 1, n), np.arange(len(x)), x)


# ── The music ────────────────────────────────────────────────────────────────

def music() -> np.ndarray:
    """The song cut on its bar lines, 30 ms equal-power crossfades, faded out at the end."""
    song = decode((HERE / T["music"]["file"]).resolve())
    bus = np.zeros((LENGTH, 2))
    xf = int(0.03 * SR)
    ramp = np.sin(np.linspace(0, np.pi / 2, xf)) ** 2
    for film, src, length in T["music"]["segments"]:
        a, n = int(src * SR), int(length * SR)
        lead = a - max(0, a - xf)
        clip = song[a - lead:a + n + xf].copy()
        if lead:
            clip[:lead] *= ramp[-lead:, None]
        clip[-xf:] *= ramp[::-1, None]
        start = int(film * SR) - lead
        end = min(LENGTH, start + len(clip))
        bus[max(0, start):end] += clip[max(0, -start):end - start]
    f0, f1 = T["music"]["fade_out"]
    t = np.arange(LENGTH) / SR
    return bus * (np.clip((f1 - t) / (f1 - f0), 0, 1) ** 1.5)[:, None]


# ── The voices ───────────────────────────────────────────────────────────────

def trim(clip: np.ndarray, floor_db: float = -45) -> np.ndarray:
    loud = np.where(np.abs(clip) > db(floor_db))[0]
    if len(loud) == 0:
        return clip
    return clip[max(0, loud[0] - int(0.01 * SR)):min(len(clip), loud[-1] + int(0.08 * SR))]


def phrases(clip: np.ndarray, gap: float = 0.12) -> list[np.ndarray]:
    """Split a line at its pauses of at least `gap` seconds."""
    env = np.convolve(np.abs(clip), np.ones(480) / 480, mode="same")
    quiet = env < db(-38)
    cuts, run = [], 0
    for i, q in enumerate(quiet):
        run = run + 1 if q else 0
        if run == int(gap * SR):
            cuts.append(i - run // 2)
    parts = np.split(clip, cuts) if cuts else [clip]
    return [trim(p) for p in parts if np.max(np.abs(p)) > db(-35)]


def voice(spec: dict, manifest: dict) -> np.ndarray:
    section, key = spec["line"].split(":", 1)
    entry = manifest[section][key]
    clip = trim(decode(ROOT / (entry[0] if isinstance(entry, list) else entry).replace("res://", ""), 1))
    if "phrase" in spec:
        clip = phrases(clip)[spec["phrase"]]
    clip = highpass(clip, 90)
    active = clip[np.abs(clip) > db(-40)]
    clip = clip * db(-21 - 20 * np.log10(np.sqrt(np.mean(active ** 2)) + 1e-9))
    wet = 0.5 if spec["id"] in FOREIGN_WORDS else 0.16
    return fades(room(clip, wet), 0.002, 0.15) * db(spec.get("gain", 0))


# ── Sound design on the cues ─────────────────────────────────────────────────

def keys(bus: np.ndarray, text: str, start: float, cps: float, gain: float = -14) -> None:
    key = key_sample()
    for i, ch in enumerate(text):
        if ch != " ":
            place(bus, varied(key, RNG.uniform(0.86, 1.18)), start + i / cps + RNG.uniform(-0.004, 0.004),
                  gain + RNG.uniform(-2.5, 1.5), RNG.uniform(-0.25, 0.25))


PENTATONIC = [523.25, 587.33, 659.25, 783.99, 880.0, 1046.5, 1174.7, 1318.5]


def decode_blips(bus: np.ndarray, text: str, start: float, per: float, gain: float = -22, falling: bool = False) -> None:
    letters = [ch for ch in text if ch != " "]
    for n in range(len(letters)):
        k = n % len(PENTATONIC)
        place(bus, blip(PENTATONIC[-1 - k] if falling else PENTATONIC[k]), start + n * per, gain, ((n % 5) - 2) * 0.15)


def sound_design() -> np.ndarray:
    bus = np.zeros((LENGTH, 2))
    click = sample("transition-click.wav")
    whip = 4 / 30

    # Act I — the slam, the steps along the glyphs, the box, the shrink, the welcome
    place(bus, thump(90, 40, 0.6), 0.0, -6)
    place(bus, crash(0.9), 0.0, -18)
    place(bus, blip(1600, 0.04), 0.48, -18)
    for step in ("track1", "track2", "track3"):
        place(bus, whoosh(0.28, 900, 2600, rise=0.25), cue(step) - 0.04, -15, 0.2)
        place(bus, thump(140, 70, 0.18, 0.6), cue(step), -16)
    place(bus, pen(0.37, 0.6), cue("track2") + 0.18, -14)
    place(bus, whoosh(0.45, 4000, 600, rise=0.8), cue("dissolve") - 0.05, -14)
    place(bus, click, cue("small"), -10)
    place(bus, pen(1.0, 0.2), cue("small") + 0.1, -20, -0.2)
    decode_blips(bus, COPY["glyphline"][:8], cue("decode"), 0.045)
    decode_blips(bus, COPY["glyphline"][9:], cue("decode") + 0.36, 0.045, -24)
    place(bus, pen(0.45, 0.8), cue("circle"), -12, 0.15)
    place(bus, thump(60, 34, 0.5, 0.1), cue("notyet"), -12)
    keys(bus, COPY["notyet"], cue("notyet") + 0.06, 24)

    # Act II — the question, the drop
    place(bus, whoosh(0.35, 500, 1800, rise=0.3), cue("question") - 0.05, -18)
    line1, line2 = COPY["question"]
    q = cue("question") + 0.05
    keys(bus, line1, q, 30, -15)
    keys(bus, line2, cue("question2"), 30, -15)
    place(bus, pen(0.35, 0.5), q + (line1.index("understand") + len("understand")) / 30 + 0.15, -15)
    burst = cue("burst")
    place(bus, riser(0.95), burst - 0.95, -9)
    place(bus, thump(80, 32, 1.1, 0.5), burst, -2)
    place(bus, crash(1.8), burst, -12)
    place(bus, shimmer(1.6), burst + 0.02, -14)
    place(bus, whoosh(0.5, 2500, 5500, rise=0.2), burst + 0.1, -17, 0.4)

    # the answer: words popping, the ring drawn, his words turning back into glyphs
    answer, orbit = cue("answer"), cue("orbit")
    place(bus, whoosh(0.6, 300, 900, rise=0.15), answer - 0.05, -14)
    for i, at in enumerate([answer + 0.05, answer + 0.26, answer + 0.5, orbit - 0.78, orbit - 0.52]):
        place(bus, pop(420 + i * 60), at, -14)
    place(bus, whoosh(0.7, 1800, 5200, rise=0.6, width=0.5), orbit, -19, -0.3)
    place(bus, shimmer(0.9, 2500, 5000, 6), orbit + 0.35, -24)
    decode_blips(bus, "words.", cue("unwords") - 0.55, 0.06, -22, falling=True)

    # the ring: things pop in, the ink ball knocks two out, it spins away
    place(bus, whoosh(0.3, 700, 2000, rise=0.3), cue("ring") - 0.03, -18)
    for i in range(10):
        place(bus, pop(380 + i * 55, 0.08), cue("ring") + i * 0.035, -17, ((i % 5) - 2) * 0.2)
    keys(bus, COPY["startwith"], cue("ring") + 0.1, 24)
    ink = cue("inkball")
    place(bus, whoosh(0.6, 300, 1400, rise=0.4), ink - 0.02, -10, -0.5)
    place(bus, splat(), ink + 0.16, -6, -0.3)
    place(bus, splat(), ink + 0.32, -6, 0.4)
    place(bus, whoosh(cue("listen") - cue("spin"), 400, 5000, rise=0.95), cue("spin"), -10)

    # listen. notice. try. — a whip, the thing landing, the word typed
    for i, name in enumerate(("listen", "notice", "try")):
        at = cue(name)
        place(bus, whoosh(0.16, 1500, 6000, rise=0.4), at - 0.02, -10, 0.5 - i * 0.5)
        place(bus, thump(110, 55, 0.3, 0.7), at + whip, -10)
        place(bus, pop(300 + i * 90, 0.12), at + whip + 0.02, -12)
        keys(bus, COPY["cards"][i], at + whip + 0.06, 16, -9)

    # Act III — the label swings on, the pen takes it, she lights up
    label, life = cue("label"), cue("life")
    place(bus, whoosh(0.45, 600, 2200, rise=0.5), label + 0.05, -16, -0.3)
    place(bus, thump(320, 180, 0.12, 1.0), label + 0.5, -16, -0.3)
    l1, l2 = COPY["label"]
    keys(bus, l1, label + 0.4, 26, -14)
    keys(bus, l2, label + 2 * BEAT, 20, -11)
    place(bus, pen(life - cue("scribble"), 1.6), cue("scribble"), -7, -0.2)
    place(bus, splat(), life, -5)
    place(bus, thump(65, 36, 1.0, 0.2), life, -6)
    place(bus, shimmer(1.8, 1500, 5200, 18), life + 0.03, -12)
    m1, m2 = COPY["life"]
    keys(bus, m1, life + 0.5 * BEAT, 28, -15)
    keys(bus, m2, life + 1.6 * BEAT, 22, -13)
    for i in range(7):
        place(bus, pop(500 + i * 70, 0.09), life + 0.5 + i * 0.06, -20, ((i % 3) - 1) * 0.4)
    for i in range(8):        # everyone: a shutter on every half beat
        place(bus, varied(click, 0.9 + 0.05 * (i % 4)), cue("strobe") + i * BEAT / 2, -12, ((i % 2) * 2 - 1) * 0.3)

    # Act IV — foreign, understand, the letters, the wordmark
    foreign = cue("foreign")
    f1, f2, f3 = COPY["foreign"]
    place(bus, whoosh(0.35, 500, 1800, rise=0.3), foreign - 0.05, -18)
    keys(bus, f1, foreign + 0.05, 26, -14)
    place(bus, pen(0.35, 0.5), foreign + 0.05 + len("you may still be ") / 26 + 0.45, -15)
    keys(bus, f2, cue("understand"), 26, -14)
    decode_blips(bus, f3, cue("understand") + 0.7, 0.05, -18)
    place(bus, pen(0.35, 0.9), cue("understand") + 1.4, -11)
    for i in range(7):
        at = cue("letters") + i * BEAT / 2
        place(bus, thump(150 - i * 8, 60, 0.25, 0.8), at, -12)
        place(bus, pop(260 + i * 40, 0.1), at + 0.01, -16)
    place(bus, whoosh(0.4, 3000, 700, rise=0.15), cue("scatter"), -14)
    for i in range(7):
        place(bus, pen(0.4, 0.4), cue("converge") + 0.1 + i * 0.13, -21, ((i % 3) - 1) * 0.5)
    snap = cue("snap")
    place(bus, riser(0.6), snap - 0.6, -12)
    place(bus, whoosh(0.32, 6000, 400, rise=0.9), snap - 0.32, -12)
    place(bus, thump(70, 30, 1.4, 0.3), snap, -3)
    place(bus, shimmer(2.4, 1400, 5600, 22), snap + 0.02, -10)
    place(bus, shimmer(1.6, 2000, 4800, 8), cue("tagline"), -20)
    return bus


# ── Mix and master ───────────────────────────────────────────────────────────

def duck(intervals: list[tuple[float, float]], depth_db: float = -3) -> np.ndarray:
    target = np.ones(LENGTH)
    for a, b in intervals:
        target[max(0, int((a - 0.08) * SR)):int((b + 0.25) * SR)] = db(depth_db)
    k = int(0.15 * SR)
    return np.convolve(target, np.ones(k) / k, mode="same")


def limit(x: np.ndarray, ceiling_db: float = TRUE_PEAK - 0.3) -> np.ndarray:
    """A plain look-ahead peak limiter: 2 ms ahead, 120 ms release."""
    need = np.minimum(1, db(ceiling_db) / np.maximum(np.abs(x).max(axis=1), 1e-9))
    for s in range(1, int(0.002 * SR)):
        need[:-s] = np.minimum(need[:-s], need[s:])
    gain = np.empty_like(need)
    g, release = 1.0, math.exp(-1 / (0.12 * SR))
    for i, n in enumerate(need):
        g = n if n < g else n + (g - n) * release
        gain[i] = g
    return x * gain[:, None]


def loudness(x: np.ndarray) -> float:
    raw = OUT / "measure.f32"
    x.astype(np.float32).tofile(raw)
    out = subprocess.run(["ffmpeg", "-hide_banner", "-f", "f32le", "-ar", str(SR), "-ac", "2", "-i", str(raw),
                          "-af", "loudnorm=print_format=json", "-f", "null", "-"], capture_output=True, text=True, check=True).stderr
    raw.unlink()
    return float(json.loads(out[out.rfind("{"):out.rfind("}") + 1])["input_i"])


def write(path: Path, x: np.ndarray) -> None:
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-f", "f32le", "-ar", str(SR), "-ac", "2", "-i", "pipe:0",
                    "-c:a", "pcm_s16le", str(path)], input=x.astype(np.float32).tobytes(), check=True)


def rms_db(x: np.ndarray) -> float:
    return 20 * np.log10(np.sqrt(np.mean(x ** 2)) + 1e-9)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    manifest = json.loads((ROOT / "audio/voice/manifest.json").read_text(encoding="utf-8"))
    song = music()
    voices = np.zeros((LENGTH, 2))
    spoken = []
    for spec in T["voices"]:
        clip = voice(spec, manifest)
        at = at_spec(spec["at"])
        # each line sits a little above the music playing under it, which is ducked a further 4 dB
        dry = clip[: max(int(0.3 * SR), len(clip) - int(1.4 * SR))]
        under = rms_db(song[int(at * SR):int(at * SR) + len(dry)])
        lift = 0 if spec["id"] in FOREIGN_WORDS else 2
        place(voices, clip, at, under + lift - rms_db(dry[np.abs(dry) > db(-40)]), spec.get("pan", 0))
        spoken.append((at, at + len(dry) / SR))
    sfx = sound_design() * db(2)
    mix = song * duck(spoken, -4)[:, None] + voices + sfx
    gain = TARGET_LUFS - loudness(mix)
    final = limit(mix * db(gain))
    write(OUT / "mix.wav", final)
    write(OUT / "nomusic.wav", limit((voices + sfx) * db(gain)))
    print(f"gain {gain:+.1f} dB -> mix at {loudness(final):.1f} LUFS")
    print("voices:", ", ".join(f"{s['id']} {a:.2f}-{b:.2f}" for s, (a, b) in zip(T["voices"], spoken)))


if __name__ == "__main__":
    main()

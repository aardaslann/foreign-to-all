"""Soundtrack for Foreign to All - Understanding, revision 7.

    python trailer/src/understanding-v7/build_audio.py      (from the repo root)

Reads timeline.json and writes:
  trailer/public/v7/mix.wav       the finished soundtrack, mastered to the timeline's target
  trailer/public/v7/score.wav     the score alone (for comparison and remixes)
  trailer/public/v7/plates/...    the game's retro scene art and title art, copied
  trailer/src/understanding-v7/generated.json   what the picture must match:
      each voice line's real length, the typed bubbles' keystrokes, the bursts

The opening is revision 5's: the same soft keystrokes on the same frames, the
same shutter click and its reflections, then two seconds of black with only a
reversed piano breath rising into the first picture. The score is revision
5's piano too - the instrument of src/connection/build_audio.py, ported to
numpy, its D minor to F major progression in 6/8 - re-scored bar by bar to
this cut and slowed to 80% exactly as revisions 4 and 5 were. Voices are the
game's own ElevenLabs recordings (audio/voice/manifest.json) and Nadia's three
trailer lines in her game voice.
"""
from __future__ import annotations

import json
import math
import subprocess
import sys
from pathlib import Path

import numpy as np

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
OUT = ROOT / "trailer/public/v7"
SR = 48000
T = json.loads((HERE / "timeline.json").read_text(encoding="utf-8"))
STORY_AT = T["story_at"]
SLOW = 0.8                      # revisions 4 and 5: atempo=0.80 on the original score
RNG = np.random.default_rng(712)


# ── I/O and small DSP ────────────────────────────────────────────────────────

def decode(path: Path) -> np.ndarray:
    raw = subprocess.run(["ffmpeg", "-v", "error", "-i", str(path), "-f", "f32le", "-ac", "2",
                          "-ar", str(SR), "pipe:1"], capture_output=True, check=True).stdout
    return np.frombuffer(raw, dtype=np.float32).reshape(-1, 2).copy()


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
        pan = 0.0
    clip = clip[: len(bus) - start] * db(gain_db)
    if pan:
        clip = clip * np.array([math.sqrt((1 - pan) / 2), math.sqrt((1 + pan) / 2)]) * 1.414
    bus[start:start + len(clip)] += clip


def spectral(x: np.ndarray, keep) -> np.ndarray:
    """Zero-phase filter by a frequency mask; good enough for these short sounds."""
    spec = np.fft.rfft(x, axis=0)
    f = np.fft.rfftfreq(x.shape[0], 1 / SR)
    gain = keep(f)
    spec *= gain[:, None] if x.ndim == 2 else gain
    return np.fft.irfft(spec, x.shape[0], axis=0)


def lowpass(x: np.ndarray, hz: float) -> np.ndarray:
    return spectral(x, lambda f: 1 / np.sqrt(1 + (f / hz) ** 4))           # 2nd-order Butterworth magnitude


def bandpass(x: np.ndarray, lo: float, hi: float) -> np.ndarray:
    return spectral(x, lambda f: 1 / np.sqrt(1 + (f / hi) ** 4) / np.sqrt(1 + (lo / np.maximum(f, 1e-3)) ** 4))


def trim(clip: np.ndarray, floor_db: float = -45) -> np.ndarray:
    env = np.abs(clip).max(axis=1)
    loud = np.where(env > db(floor_db))[0]
    if len(loud) == 0:
        return clip
    a, b = max(0, loud[0] - int(0.01 * SR)), min(len(clip), loud[-1] + int(0.08 * SR))
    return clip[a:b]


def last_word(clip: np.ndarray) -> np.ndarray:
    """From the last pause of at least 70 ms to the end: the line's final word."""
    env = np.convolve(np.abs(clip).max(axis=1), np.ones(480) / 480, mode="same")
    quiet = env < db(-38)
    gap, start = 0, 0
    for i in range(len(quiet) - int(0.15 * SR), 0, -1):
        gap = gap + 1 if quiet[i] else 0
        if gap > int(0.07 * SR):
            start = i + gap
            break
    return trim(clip[start:])


def level(clip: np.ndarray, target_db: float) -> np.ndarray:
    active = clip[np.abs(clip).max(axis=1) > db(-40)]
    rms = np.sqrt(np.mean(active ** 2)) if len(active) else 1e-6
    return clip * db(target_db - 20 * np.log10(rms + 1e-9))


def t_axis(seconds: float) -> np.ndarray:
    return np.arange(int(seconds * SR)) / SR


def noise(seconds: float) -> np.ndarray:
    return RNG.uniform(-1, 1, int(seconds * SR))


# ── Revision 5's piano (src/connection/build_audio.py, in numpy) ─────────────

def piano(midi: int, velocity: float = .5, length: float = 5.8) -> np.ndarray:
    f = 440 * 2 ** ((midi - 69) / 12)
    t = np.arange(int(length * SR)) / SR
    y = np.zeros_like(t)
    # Inharmonic decaying partials and detuned strings; no sampled music.
    for k in range(1, 11):
        decay = (3.2 / (1 + k * .42)) * (220 / f) ** .16
        amp = (1 / (k ** 1.65)) * np.exp(-t / decay)
        freq = f * k * math.sqrt(1 + .000045 * k * k)
        y += amp * (np.sin(2 * np.pi * freq * t) + .28 * np.sin(2 * np.pi * freq * 1.0009 * t + .07))
    hammer = lowpass(RNG.normal(0, 1, len(t)) * np.exp(-t * 90), 1800)
    y = (y + .1 * hammer) * (1 - np.exp(-t * 340)) * np.minimum(1, (length - t) / .12)
    return y * velocity * .13


def pad(midis: list[int], length: float = 6.7) -> np.ndarray:
    t = np.arange(int(length * SR)) / SR
    y = np.zeros_like(t)
    for m in midis:
        f = 440 * 2 ** ((m - 69) / 12)
        for det in [.997, 1, 1.003]:
            y += np.sin(2 * np.pi * f * det * t + 0.18 * np.sin(t * 1.3))
            y += .13 * np.sin(2 * np.pi * f * 2 * det * t)
    env = np.minimum(t / 1.6, 1) * np.minimum((length - t) / 2.3, 1)
    return y * env * .0028


def room(x: np.ndarray, wet: float = .23) -> np.ndarray:
    # Small early reflections, then an irregular diffuse tail.
    rng = np.random.default_rng(2809)
    impulse = np.zeros(int(3.7 * SR))
    for i in range(130):
        when = .049 + i * .025 + float(rng.uniform(-.006, .006))
        impulse[int(when * SR)] += float(rng.choice([-1, 1])) * np.exp(-when / 1.03) * .087
    out = x.copy()
    n = len(x) + len(impulse)
    size = 1 << (n - 1).bit_length()
    for c in range(2):
        tail = np.fft.irfft(np.fft.rfft(x[:, c], size) * np.fft.rfft(np.roll(impulse, int(c * .007 * SR)), size), size)[:len(x)]
        out[:, c] += wet * lowpass(tail, 3400)
    return out


CHORDS = {"Dm": [50, 57, 62, 65, 69], "Bb": [46, 53, 58, 62, 65], "F": [53, 60, 65, 69, 72],
          "C": [48, 55, 60, 64, 67], "Gm": [43, 50, 55, 58, 62]}


def atempo(x: np.ndarray, rate: float) -> np.ndarray:
    raw = subprocess.run(["ffmpeg", "-v", "error", "-f", "f32le", "-ar", str(SR), "-ac", "2", "-i", "pipe:0",
                          "-af", f"atempo={rate}", "-f", "f32le", "pipe:1"],
                         input=x.astype(np.float32).tobytes(), capture_output=True, check=True).stdout
    return np.frombuffer(raw, dtype=np.float32).reshape(-1, 2).copy()


def score(length: int) -> np.ndarray:
    """Composed at the original 5 s bar (v1 time), then slowed to 80%: v1 time m is film STORY_AT + m / SLOW."""
    s = T["score"]
    v1 = lambda film: (film - STORY_AT) * SLOW
    bars = len(s["chords"])
    content = np.zeros((int((bars * 5 + 9) * SR), 2), dtype=np.float32)
    for k, name in enumerate(s["chords"]):
        chord, at, vel = CHORDS[name], k * 5.0, s["velocity"][k]
        for beat, index in enumerate([0, 2, 3, 4, 2, 3]):
            if k < s["sparse_until_bar"] and beat in (2, 4):
                continue
            if k == 0 and beat == 0:
                continue                      # the arrival chord below is the first downbeat
            start = at + beat * 5 / 6 + float(RNG.uniform(-.016, .016))
            accent = 1.04 if beat == 0 else .75 + float(RNG.random()) * .17
            place(content, piano(chord[index], vel * accent), start, pan=(index - 2) * .13)
        if s["pad"][k]:
            place(content, pad([chord[0], chord[2], chord[3]]), at, 20 * math.log10(s["pad"][k]), pan=.05)
    last = (bars - 1) * 5.0
    place(content, piano(41, .5, 7), last)
    for i, m in enumerate([53, 60, 65, 69, 72]):
        place(content, piano(m, .3, 7), last + i * .047, pan=(i - 2) * .12)
    for phrase in s["melody"]:
        for i, m in enumerate(phrase["notes"]):
            place(content, piano(m, .31 if phrase["at"] < 80 else .37, 6), v1(phrase["at"]) + i * .93, pan=.22)
    content = room(content, wet=.54)
    music = np.zeros((length, 2), dtype=np.float32)
    place(music, atempo(content, SLOW), STORY_AT)

    # Revision 5's downbeat: a definite D minor on the first picture.
    arrival = np.zeros((6 * SR, 2), dtype=np.float32)
    for midi, velocity, delay, pan in [(50, .62, 0, -.12), (62, .29, .008, .02), (65, .22, .021, -.20), (69, .17, .032, .22)]:
        place(arrival, piano(midi, velocity, 5.8), delay, pan=pan)
    place(music, room(arrival, wet=.50), STORY_AT)

    # One beat at the slowed tempo: a reversed piano breath rises out of the black.
    beat = (5 / 6) / SLOW
    n = round(beat * SR)
    pickup = piano(62, .32, beat)[::-1][:n] + piano(69, .20, beat)[::-1][:n]
    pickup = lowpass(pickup, 2600) * np.linspace(0, 1, n) ** 1.8 * np.minimum(np.arange(n)[::-1] / (SR * .003), 1)
    pickup = pickup / max(np.max(np.abs(pickup)), 1e-9) * .024
    place(music, pickup, STORY_AT - beat, pan=.08)

    a, b = (int(x * SR) for x in s["fade"])
    music[a:b] *= np.linspace(1, 0, b - a)[:, None] ** 1.5
    music[b:] = 0
    return music


# ── Revision 5's opening: soft keys on the visible letters, the shutter ──────

def v5_intro() -> dict:
    text = (ROOT / "trailer/src/connection-v5/intro.ts").read_text(encoding="utf-8")
    return json.loads(text[text.index("{"):text.rindex("}") + 1])


def key_sample() -> np.ndarray:
    source = decode(HERE / "sfx/keyboard-soft.wav")[:, 0]
    peak = int(np.argmax(np.abs(source)))
    key = source[max(0, peak - round(.013 * SR)):peak + round(.115 * SR)]
    key = bandpass(key, 110, 2900)
    key *= np.minimum(np.arange(len(key)) / (SR * .0015), 1) * np.minimum(np.arange(len(key))[::-1] / (SR * .018), 1)
    return key / max(np.max(np.abs(key)), 1e-9) * .035


def stretch(x: np.ndarray, up: int, down: int) -> np.ndarray:
    n = int(len(x) * up / down)
    return np.interp(np.linspace(0, len(x) - 1, n), np.arange(len(x)), x)


def opening(length: int) -> np.ndarray:
    bus = np.zeros((length, 2), dtype=np.float32)
    intro = v5_intro()
    key = key_sample()
    rng = np.random.default_rng(942)
    for i, at in enumerate(intro["titleKeys"] + intro["bodyKeys"]):
        variant = stretch(key, 100, 98 + i % 5)
        gain = (.78 + float(rng.random()) * .22) * (1 if i < 6 else .5)
        place(bus, variant * gain, at, pan=(i % 3 - 1) * .07)
    click = decode(HERE / "sfx/transition-click.wav")
    place(bus, click * .94, intro["clickAt"])
    tail = lowpass(click, 2100)
    for delay, gain, pan in [(.082, .12, -.25), (.151, .07, .25), (.243, .025, -.12)]:
        place(bus, tail * gain, intro["clickAt"] + delay, pan=pan)
    return bus


def typing(length: int) -> tuple[np.ndarray, dict]:
    """The alien has no voice: his words type out, on the same soft keys as the opening."""
    bus = np.zeros((length, 2), dtype=np.float32)
    key = key_sample()
    times = {}
    for spec in T["typed"]:
        hits = []
        for i, ch in enumerate(spec["text"]):
            at = spec["at"] + (i + 1) / spec["cps"]
            if ch != " ":
                place(bus, stretch(key, 100, 97 + i % 6) * (.55 + float(RNG.random()) * .2), at, pan=float(RNG.uniform(-.1, .1)))
            hits.append(round(at, 4))
        times[spec["id"]] = hits
    return bus, times


# ── Small, quiet effects ─────────────────────────────────────────────────────

def bell(freqs: list[float], seconds: float, decay: float, attack: float = 0.004) -> np.ndarray:
    t = t_axis(seconds)
    env = np.minimum(t / attack, 1) * np.exp(-t / decay)
    return env * sum(np.sin(2 * np.pi * f * t) / (k + 1) for k, f in enumerate(freqs)) / len(freqs)


def sfx_landing() -> np.ndarray:
    t = t_axis(2.4)
    thump = np.sin(2 * np.pi * (52 * np.exp(-t * 3) + 34) * t) * np.exp(-t / 0.35) * np.minimum(t / 0.03, 1)
    dust = lowpass(noise(2.4), 900) * np.exp(-t / 0.9) * np.minimum(t / 0.2, 1) * 0.25
    return lowpass(thump + dust, 700)


def sfx_bicycle_bell() -> np.ndarray:
    one = bell([2093, 2794, 3951, 5274], 0.7, 0.28)
    out = np.zeros(int(1.0 * SR))
    for at in (0.0, 0.16):
        s = int(at * SR)
        out[s:s + len(one)] += one[: len(out) - s]
    return out


def sfx_decode() -> np.ndarray:
    out = np.zeros(int(1.4 * SR))
    for k, f in enumerate([1318.5, 1568.0, 1760.0, 2093.0, 2637.0]):
        s = int(k * 0.065 * SR)
        b = bell([f, f * 2.01], 0.9, 0.22)
        out[s:s + len(b)] += b[: len(out) - s] * (0.6 + 0.1 * k)
    return out


def sfx_chime() -> np.ndarray:
    out = np.zeros(int(2.2 * SR))
    for at, f in ((0.0, 1318.5), (0.12, 1975.5)):
        s = int(at * SR)
        b = bell([f, f * 2.0, f * 3.01], 2.0, 0.55, attack=0.01)
        out[s:s + len(b)] += b[: len(out) - s]
    return out


def sfx_page() -> np.ndarray:
    t = t_axis(0.4)
    return bandpass(noise(0.4), 400, 5000) * np.sin(np.pi * t / 0.4) ** 2


def sfx_paper() -> np.ndarray:
    t = t_axis(0.55)
    grain = noise(0.55) * (RNG.uniform(0, 1, len(t)) > 0.6)
    return bandpass(grain, 1500, 8000) * np.minimum(t / 0.03, 1) * np.exp(-t / 0.25)


def sfx_firework(big: bool, pan: float) -> np.ndarray:
    seconds = 2.4 if big else 1.4
    t = t_axis(seconds)
    pop = np.sin(2 * np.pi * (90 * np.exp(-t * 8) + 42) * t) * np.exp(-t / (0.2 if big else 0.11))
    crackle = np.zeros(len(t))
    if big:
        for _ in range(60):
            s = int(RNG.uniform(0.3, 2.0) * SR)
            n = int(0.004 * SR)
            crackle[s:s + n] += RNG.uniform(-1, 1, n) * np.exp(-np.arange(n) / (0.0012 * SR)) * RNG.uniform(0.05, 0.2)
    mono = lowpass(pop + bandpass(crackle, 1800, 7000), 2400)      # far off, over the rooftops
    return np.stack([mono * math.sqrt((1 - pan) / 2), mono * math.sqrt((1 + pan) / 2)], axis=1) * 1.414


def bursts() -> list[dict]:
    fw = T["fireworks"]
    rng = np.random.default_rng(fw["seed"])
    colours = ["#e8c25c", "#c3b2de", "#96c3b2", "#e8a0a8", "#f2c56e", "#a8b8f0"]
    out = []
    for t in fw["times"]:
        big = t in fw["big"]
        out.append({"t": t, "big": big, "x": round(float(rng.uniform(0.16, 0.84)), 3),
                    "y": round(float(rng.uniform(0.17, 0.30 if big else 0.40)), 3),
                    "r": round(float(rng.uniform(230, 290) if big else rng.uniform(120, 170)), 1),
                    "colour": colours[int(rng.integers(len(colours)))], "n": 56 if big else 36})
    return out


# ── Voices and mix ───────────────────────────────────────────────────────────

def voice_clip(spec: dict, manifest: dict) -> np.ndarray:
    if "file" in spec:
        path = (HERE / spec["file"]).resolve()
    else:
        section, key = spec["line"].split(":", 1)
        entry = manifest[section][key]
        path = ROOT / (entry[0] if isinstance(entry, list) else entry).replace("res://", "")
    clip = trim(decode(path))
    if spec.get("last_word"):
        clip = last_word(clip)
    return level(clip, T["master"]["voice_lufs"] - 3) * db(spec.get("gain", 0))


def duck_envelope(intervals: list[tuple[float, float]], length: int) -> np.ndarray:
    target = np.ones(length, dtype=np.float32)
    for a, b in intervals:
        target[max(0, int((a - 0.25) * SR)):int((b + 0.5) * SR)] = db(T["master"]["duck_db"])
    k = int(0.3 * SR)
    return np.convolve(target, np.ones(k) / k, mode="same").astype(np.float32)


def master(mix: np.ndarray, name: str = "mix.wav") -> None:
    raw = OUT / "mix-raw.f32"
    mix.astype(np.float32).tofile(raw)
    cfg = T["master"]
    common = ["ffmpeg", "-hide_banner", "-f", "f32le", "-ar", str(SR), "-ac", "2", "-i", str(raw)]
    first = subprocess.run(common + ["-af", f"loudnorm=I={cfg['lufs']}:TP={cfg['true_peak']}:LRA=18:print_format=json",
                                     "-f", "null", "-"], capture_output=True, text=True, check=True).stderr
    m = json.loads(first[first.rfind("{"):first.rfind("}") + 1])
    af = (f"loudnorm=I={cfg['lufs']}:TP={cfg['true_peak']}:LRA=18:measured_I={m['input_i']}:"
          f"measured_TP={m['input_tp']}:measured_LRA={m['input_lra']}:measured_thresh={m['input_thresh']}:"
          f"offset={m['target_offset']}:linear=true,aresample={SR}")
    subprocess.run(common + ["-af", af, "-c:a", "pcm_s24le", str(OUT / name), "-y", "-v", "error"], check=True)
    raw.unlink()
    print(f"mastered: input {m['input_i']} LUFS / {m['input_tp']} dBTP -> {cfg['lufs']} LUFS")


def write(path: Path, x: np.ndarray) -> None:
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-f", "f32le", "-ar", str(SR), "-ac", "2", "-i", "pipe:0",
                    "-c:a", "pcm_s24le", str(path)], input=x.astype(np.float32).tobytes(), check=True)


# The game's own art, copied (not committed twice) into public/v7. These are
# the -retro scene plates the game actually draws (art/environments/*-gameplay.json),
# the Kiez the opening cutscene uses, the opening's orbit and rooftops, and
# the title art. Cast strips come from tools/export_trailer_cast.gd.
PLATES = {
    "orbit": "art/cutscene/intro/orbit.png", "rooftops": "art/cutscene/intro/berlin-rooftops.png",
    "pod": "art/cutscene/intro/pod-flight.png", "title": "art/title/berlin-night.png",
    "kiez": "art/environments/scenes/Kiez-refined.png",
    "mitte": "art/environments/scenes/Mitte-retro.png",
    "london": "art/environments/scenes/LondonHighStreet-retro.png",
    "terrace": "art/environments/scenes/LondonTerrace-retro.png",
    "karakoy": "art/environments/scenes/IstanbulKarakoy-retro.png",
    "asakusa": "art/environments/scenes/TokyoAsakusa-retro.png",
    "berlin": "art/environments/scenes/BerlinPrenzlberg-retro.png",
    "brixton": "art/environments/scenes/LondonBrixton-retro.png",
    "paris": "art/environments/scenes/ParisMontmartre-retro.png",
    "moscow": "art/environments/scenes/MoscowArbat-retro.png",
    "istanbul": "art/environments/scenes/IstanbulCarsi-retro.png",
    "mumbai": "art/environments/scenes/MumbaiBhuleshwar-retro.png",
    "tokyo": "art/environments/scenes/TokyoYanaka-retro.png",
    "mexico": "art/environments/scenes/MexicoMerced-retro.png",
    "wordmark": "art/world/ui/wordmark.png",
}
FONTS = ["NotoSansJP", "NotoSansKR", "NotoSansDevanagari", "NotoSansGeorgian"]


def copy_art() -> None:
    (OUT / "plates").mkdir(parents=True, exist_ok=True)
    for name, src in PLATES.items():
        (OUT / "plates" / f"{name}.png").write_bytes((ROOT / src).read_bytes())
    (OUT / "fonts").mkdir(exist_ok=True)
    for name in FONTS:
        (OUT / "fonts" / f"{name}.ttf").write_bytes((ROOT / f"art/fonts/{name}.ttf").read_bytes())


def alternate_score(path: Path, skip: float, length: int) -> np.ndarray:
    """Another score under the same picture: `skip` seconds of it are cut so it
    enters on the first picture; it fades in over the black's last second and
    out with the film."""
    clip = decode(path)[int(skip * SR):]
    music = np.zeros((length, 2), dtype=np.float32)
    place(music, clip, STORY_AT - 1.0)
    a, b = int((STORY_AT - 1.0) * SR), int(STORY_AT * SR)
    music[a:b] *= np.linspace(0, 1, b - a)[:, None]
    a, b = (int(x * SR) for x in T["score"]["fade"])
    music[a:b] *= np.linspace(1, 0, b - a)[:, None] ** 1.5
    music[b:] = 0
    return music


def main() -> None:
    alt = sys.argv[sys.argv.index("--alt") + 1] if "--alt" in sys.argv else None
    skip = float(sys.argv[sys.argv.index("--skip") + 1]) if "--skip" in sys.argv else 0.0
    OUT.mkdir(parents=True, exist_ok=True)
    copy_art()
    length = int(T["duration"] * SR)
    manifest = json.loads((ROOT / "audio/voice/manifest.json").read_text(encoding="utf-8"))

    dialogue = np.zeros((length, 2), dtype=np.float32)
    voices, spoken = {}, []
    for spec in T["voices"]:
        clip = voice_clip(spec, manifest)
        place(dialogue, clip, spec["at"])
        dur = round(len(clip) / SR, 3)
        voices[spec["id"]] = {"at": spec["at"], "dur": dur}
        spoken.append((spec["at"], spec["at"] + dur))

    if alt:
        music = alternate_score(Path(alt), skip, length)
    else:
        music = score(length)
        write(OUT / "score.wav", music)
    active = music[np.abs(music).max(axis=1) > db(-50)]
    music *= db(-27 - 20 * np.log10(np.sqrt(np.mean(active ** 2)) + 1e-9))   # a bed under the voices
    music *= duck_envelope(spoken, length)[:, None]

    effects = opening(length)
    keys, typed = typing(length)
    effects += keys
    makers = {"landing": sfx_landing, "bell": sfx_bicycle_bell, "decode": sfx_decode, "chime": sfx_chime,
              "page": sfx_page, "paper": sfx_paper}
    for cue in T["sfx"]:
        place(effects, makers[cue["kind"]](), cue["at"], cue["gain"])
    fireworks = bursts()
    for b in fireworks:
        place(effects, sfx_firework(b["big"], (b["x"] - 0.5) * 1.1), b["t"], -24 if b["big"] else -29)

    if alt:
        master(music + dialogue + effects, f"mix-{Path(alt).stem}.wav")
        return
    master(music + dialogue + effects)
    generated = {"voices": voices, "typed": typed, "bursts": fireworks,
                 "note": "Written by build_audio.py from timeline.json. Do not edit by hand."}
    (HERE / "generated.json").write_text(json.dumps(generated, indent=1, ensure_ascii=False), encoding="utf-8")
    print("voices:", {k: v["dur"] for k, v in voices.items()})
    print("typed keys:", {k: len(v) for k, v in typed.items()}, "bursts:", len(fireworks))


if __name__ == "__main__":
    main()

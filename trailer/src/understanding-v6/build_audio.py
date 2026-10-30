"""Soundtrack for Foreign to All - Understanding, revision 6.

    python trailer/src/understanding-v6/build_audio.py      (from the repo root)

Reads timeline.json and writes:
  trailer/public/v6/mix.wav            the finished, mastered soundtrack
  trailer/src/understanding-v6/generated.json   what the picture must match:
      the typing schedule, each voice line's real length, the firework bursts

The score is the Suno take B-56ae (131.25 BPM), placed at frame 0 and ducked
under every spoken line. Voices are the game's own ElevenLabs recordings
(audio/voice/manifest.json) plus Nadia's three trailer lines in her game
voice. Effects are the two CC0 sources the earlier cuts credited (soft key,
camera shutter), the game's own crash, and small synthesised sounds.
Mastered to -14 LUFS integrated, -1 dBTP, for streaming.
"""
from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

import numpy as np

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
OUT = ROOT / "trailer/public/v6"
SR = 48000
T = json.loads((HERE / "timeline.json").read_text(encoding="utf-8"))
RNG = np.random.default_rng(612)


# ── I/O ──────────────────────────────────────────────────────────────────────

def decode(path: Path) -> np.ndarray:
    raw = subprocess.run(["ffmpeg", "-v", "error", "-i", str(path), "-f", "f32le", "-ac", "2",
                          "-ar", str(SR), "pipe:1"], capture_output=True, check=True).stdout
    return np.frombuffer(raw, dtype=np.float32).reshape(-1, 2).copy()


def db(gain_db: float) -> float:
    return 10 ** (gain_db / 20)


def place(bus: np.ndarray, clip: np.ndarray, at: float, gain_db: float = 0.0, pan: float = 0.0) -> None:
    start = int(round(at * SR))
    if start >= len(bus):
        return
    clip = clip[: len(bus) - start] * db(gain_db)
    if pan:
        clip = clip * np.array([np.sqrt(0.5 - pan / 2) * 1.414, np.sqrt(0.5 + pan / 2) * 1.414])
    bus[start:start + len(clip)] += clip


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


# ── Synthesised effects ──────────────────────────────────────────────────────

def t_axis(seconds: float) -> np.ndarray:
    return np.arange(int(seconds * SR)) / SR


def stereo(mono: np.ndarray) -> np.ndarray:
    return np.stack([mono, mono], axis=1).astype(np.float32)


def noise(seconds: float) -> np.ndarray:
    return RNG.uniform(-1, 1, int(seconds * SR))


def bandpass(x: np.ndarray, lo: float, hi: float) -> np.ndarray:
    spec = np.fft.rfft(x)
    f = np.fft.rfftfreq(len(x), 1 / SR)
    spec[(f < lo) | (f > hi)] = 0
    return np.fft.irfft(spec, len(x))


def bell(freqs: list[float], seconds: float, decay: float, attack: float = 0.004) -> np.ndarray:
    t = t_axis(seconds)
    env = np.minimum(t / attack, 1) * np.exp(-t / decay)
    tone = sum(np.sin(2 * np.pi * f * t) / (k + 1) for k, f in enumerate(freqs))
    return env * tone / len(freqs)


def sfx_descent(length: float) -> np.ndarray:
    t = t_axis(length)
    rise = (t / length) ** 2.2
    air = bandpass(noise(length), 300, 4200) * (0.15 + 0.85 * rise)
    rumble = np.sin(2 * np.pi * (38 + 30 * rise) * t) * rise * 0.6
    mono = (air * 0.5 + rumble) * np.minimum((length - t) / 0.05, 1)
    pan = np.linspace(-0.6, 0.6, len(t))
    return np.stack([mono * np.sqrt(0.5 - pan / 2) * 1.4, mono * np.sqrt(0.5 + pan / 2) * 1.4], axis=1).astype(np.float32)


def sfx_bicycle_bell() -> np.ndarray:
    one = bell([2093, 2794, 3951, 5274], 0.7, 0.28)
    out = np.zeros(int(1.0 * SR))
    for at in (0.0, 0.16):
        s = int(at * SR)
        out[s:s + len(one)] += one[: len(out) - s]
    return stereo(out)


def sfx_decode() -> np.ndarray:
    notes = [1318.5, 1568.0, 1760.0, 2093.0, 2637.0]
    out = np.zeros(int(1.4 * SR))
    for k, f in enumerate(notes):
        s = int(k * 0.065 * SR)
        b = bell([f, f * 2.01], 0.9, 0.22)
        out[s:s + len(b)] += b[: len(out) - s] * (0.6 + 0.1 * k)
    return stereo(out)


def sfx_chime() -> np.ndarray:
    out = np.zeros(int(2.2 * SR))
    for at, f in ((0.0, 1318.5), (0.12, 1975.5)):
        s = int(at * SR)
        b = bell([f, f * 2.0, f * 3.01], 2.0, 0.55, attack=0.01)
        out[s:s + len(b)] += b[: len(out) - s]
    return stereo(out)


def sfx_swish(seconds: float = 0.28, lo: float = 800, hi: float = 7000) -> np.ndarray:
    t = t_axis(seconds)
    env = np.sin(np.pi * t / seconds) ** 2
    return stereo(bandpass(noise(seconds), lo, hi) * env)


def sfx_tick() -> np.ndarray:
    t = t_axis(0.09)
    return stereo(np.sin(2 * np.pi * 1480 * t) * np.exp(-t / 0.018) + noise(0.09) * np.exp(-t / 0.004) * 0.3)


def sfx_stamp() -> np.ndarray:
    t = t_axis(0.5)
    thud = np.sin(2 * np.pi * (95 * np.exp(-t * 6) + 45) * t) * np.exp(-t / 0.12)
    click = bandpass(noise(0.5), 1500, 6000) * np.exp(-t / 0.01) * 0.5
    return stereo(thud + click)


def sfx_rip() -> np.ndarray:
    t = t_axis(0.42)
    grain = noise(0.42) * (RNG.uniform(0, 1, len(t)) > 0.55)
    return stereo(bandpass(grain, 1200, 9000) * np.minimum(t / 0.02, 1) * np.exp(-t / 0.22))


def sfx_bloom() -> np.ndarray:
    t = t_axis(3.2)
    boom = np.sin(2 * np.pi * 42 * t) * np.exp(-t / 0.7) * np.minimum(t / 0.02, 1)
    shimmer = bell([1567.98, 2349.3, 3135.96, 4698.6], 3.2, 1.4, attack=0.25) * 0.35
    return stereo(boom + shimmer)


def sfx_shutter() -> np.ndarray:
    src = decode(HERE / "sfx/shutter.wav")
    t = t_axis(0.6)
    low = np.sin(2 * np.pi * 55 * t) * np.exp(-t / 0.09) * 0.55
    out = np.zeros((int(0.9 * SR), 2), dtype=np.float32)
    out[: len(src)] += src
    out[: len(low)] += stereo(low)
    # a short decaying reflection, so the click has a room
    for d, g in ((0.031, 0.22), (0.067, 0.12), (0.11, 0.06)):
        s = int(d * SR)
        out[s:] += out[: len(out) - s] * g
    return out


def sfx_crash() -> np.ndarray:
    # The game's own crash: audio/intro/arrival.wav, 11.15-13.05 s. The user
    # likes it; it is the one opening sound that stays.
    whole = decode(ROOT / "audio/intro/arrival.wav")
    a, b = int(11.12 * SR), int(13.1 * SR)
    clip = whole[a:b].copy()
    clip[-int(0.2 * SR):] *= np.linspace(1, 0, int(0.2 * SR))[:, None]
    return clip


def sfx_firework(big: bool, pan: float) -> np.ndarray:
    seconds = 2.2 if big else 1.2
    t = t_axis(seconds)
    pop = np.sin(2 * np.pi * (110 * np.exp(-t * 9) + 50) * t) * np.exp(-t / (0.16 if big else 0.09))
    crack = bandpass(noise(seconds), 900, 6000) * np.exp(-t / 0.012) * 0.5
    crackle = np.zeros(len(t))
    if big:
        for _ in range(70):
            s = int(RNG.uniform(0.25, 1.9) * SR)
            n = int(0.004 * SR)
            crackle[s:s + n] += RNG.uniform(-1, 1, n) * np.exp(-np.arange(n) / (0.0012 * SR)) * RNG.uniform(0.1, 0.35)
        crackle = bandpass(crackle, 2000, 9000)
    mono = pop + crack + crackle
    return np.stack([mono * np.sqrt(0.5 - pan / 2) * 1.4, mono * np.sqrt(0.5 + pan / 2) * 1.4], axis=1).astype(np.float32)


# ── Typing ───────────────────────────────────────────────────────────────────

def typing_schedule() -> dict:
    """Frame-exact keystrokes: the picture types on the same times the keys sound."""
    s = T["sonder"]
    word = [s["word_at"] + i * 0.13 + RNG.uniform(-0.015, 0.015) for i in range(len(s["word"]))]
    text = s["lines"]
    total = sum(len(line) for line in text)
    span = s["definition_end"] - s["definition_at"]
    base = span / (total + 2 * len(text) + text_pauses(text))
    t = s["definition_at"]
    lines = []
    for line in text:
        times = []
        for ch in line:
            times.append(round(t, 4))
            t += base * RNG.uniform(0.75, 1.25) * (2.2 if ch in ",." else 1.35 if ch == " " else 1.0)
        lines.append(times)
        t += base * 2
    return {"word": [round(x, 4) for x in word], "lines": lines}


def text_pauses(text: list[str]) -> float:
    return sum(1.2 * line.count(",") + 0.35 * line.count(" ") for line in text)


def keys_bus(schedule: dict, length: int) -> np.ndarray:
    bus = np.zeros((length, 2), dtype=np.float32)
    key = trim(decode(HERE / "sfx/keyboard-soft.wav"), -50)
    all_times = schedule["word"] + [t for line in schedule["lines"] for t in line]
    chars = T["sonder"]["word"] + "".join(T["sonder"]["lines"])
    for t, ch in zip(all_times, chars):
        rate = RNG.uniform(0.94, 1.06) * (0.86 if ch == " " else 1.0)
        n = int(len(key) / rate)
        idx = np.clip((np.arange(n) * rate).astype(int), 0, len(key) - 1)
        place(bus, key[idx], t, RNG.uniform(-21, -17), RNG.uniform(-0.15, 0.15))
    return bus


# ── Voices ───────────────────────────────────────────────────────────────────

def voice_clip(spec: dict, manifest: dict) -> np.ndarray:
    if "file" in spec:
        path = HERE / spec["file"]
    else:
        section, key = spec["line"].split(":", 1)
        entry = manifest[section][key]
        res = entry[0] if isinstance(entry, list) else entry
        path = ROOT / res.replace("res://", "")
    clip = trim(decode(path))
    if spec.get("last_word"):
        clip = last_word(clip)
    return level(clip, T["master"]["voice_lufs"] - 3) * db(spec.get("gain", 0))


# ── Mix ──────────────────────────────────────────────────────────────────────

def duck_envelope(intervals: list[tuple[float, float]], length: int) -> np.ndarray:
    target = np.ones(length, dtype=np.float32)
    depth = db(T["master"]["duck_db"])
    for a, b in intervals:
        target[max(0, int((a - 0.12) * SR)):int((b + 0.35) * SR)] = depth
    k = int(0.18 * SR)
    smooth = np.convolve(target, np.ones(k) / k, mode="same")
    return smooth.astype(np.float32)


def bursts() -> list[dict]:
    fw = T["fireworks"]
    rng = np.random.default_rng(fw["seed"])
    hues = [44, 270, 336, 168, 205, 18]
    out = []
    for t in fw["times"]:
        big = t in fw["big"]
        out.append({"t": t, "big": big, "x": round(float(rng.uniform(0.12, 0.88)), 3),
                    "y": round(float(rng.uniform(0.10, 0.34 if big else 0.42)), 3),
                    "r": round(float(rng.uniform(250, 340) if big else rng.uniform(120, 190)), 1),
                    "hue": int(hues[int(rng.integers(len(hues)))]), "n": int(64 if big else 36)})
    return out


def master(mix: np.ndarray) -> np.ndarray:
    raw = OUT / "mix-raw.f32"
    mix.astype(np.float32).tofile(raw)
    cfg = T["master"]
    common = ["ffmpeg", "-hide_banner", "-f", "f32le", "-ar", str(SR), "-ac", "2", "-i", str(raw)]
    first = subprocess.run(common + ["-af", f"loudnorm=I={cfg['lufs']}:TP={cfg['true_peak']}:LRA=11:print_format=json",
                                     "-f", "null", "-"], capture_output=True, text=True, check=True).stderr
    m = json.loads(first[first.rfind("{"):first.rfind("}") + 1])
    af = (f"loudnorm=I={cfg['lufs']}:TP={cfg['true_peak']}:LRA=11:measured_I={m['input_i']}:"
          f"measured_TP={m['input_tp']}:measured_LRA={m['input_lra']}:measured_thresh={m['input_thresh']}:"
          f"offset={m['target_offset']}:linear=true,aresample={SR}")
    subprocess.run(common + ["-af", af, "-c:a", "pcm_s24le", str(OUT / "mix.wav"), "-y", "-v", "error"], check=True)
    raw.unlink()
    print(f"mastered: input {m['input_i']} LUFS / {m['input_tp']} dBTP -> {cfg['lufs']} LUFS")


# The game's own art, copied (not committed twice) into the trailer's public
# folder. The cast strips come from tools/export_trailer_cast.gd.
PLATES = {
    "orbit": "art/cutscene/intro/orbit.png", "rooftops": "art/cutscene/intro/berlin-rooftops.png",
    "pod": "art/cutscene/intro/pod-flight.png", "title": "art/title/berlin-night.png",
    "kiez": "art/environments/scenes/Kiez-refined.png", "mitte": "art/environments/scenes/Mitte.png",
    "london": "art/environments/scenes/LondonHighStreet.png",
    "terrace": "art/environments/scenes/LondonTerrace.png",
    "karakoy": "art/environments/scenes/IstanbulKarakoy.png",
    "asakusa": "art/environments/scenes/TokyoAsakusa.png",
    "berlin": "art/environments/scenes/BerlinPrenzlberg.png",
    "brixton": "art/environments/scenes/LondonBrixton.png",
    "paris": "art/environments/scenes/ParisMontmartre.png",
    "moscow": "art/environments/scenes/MoscowArbat.png",
    "istanbul": "art/environments/scenes/IstanbulCarsi.png",
    "mumbai": "art/environments/scenes/MumbaiBhuleshwar.png",
    "tokyo": "art/environments/scenes/TokyoYanaka.png",
    "mexico": "art/environments/scenes/MexicoMerced.png",
}
# The title's stranger word runs through scripts Open Sans lacks; these are
# the game's own fallbacks.
FONTS = ["NotoSansJP", "NotoSansKR", "NotoSansDevanagari", "NotoSansGeorgian"]


def copy_art() -> None:
    plates = OUT / "plates"
    plates.mkdir(parents=True, exist_ok=True)
    for name, src in PLATES.items():
        (plates / f"{name}.png").write_bytes((ROOT / src).read_bytes())
    fonts = OUT / "fonts"
    fonts.mkdir(exist_ok=True)
    for name in FONTS:
        (fonts / f"{name}.ttf").write_bytes((ROOT / f"art/fonts/{name}.ttf").read_bytes())


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    copy_art()
    length = int(T["duration"] * SR)
    manifest = json.loads((ROOT / "audio/voice/manifest.json").read_text(encoding="utf-8"))

    music = np.zeros((length, 2), dtype=np.float32)
    score = decode(HERE / "score/score.mp3")
    place(music, score, 0.0, -1.5)
    fade = int(1.4 * SR)
    music[length - fade:] *= np.linspace(1, 0, fade)[:, None]

    dialogue = np.zeros((length, 2), dtype=np.float32)
    voices, spoken = {}, []
    for spec in T["voices"]:
        clip = voice_clip(spec, manifest)
        place(dialogue, clip, spec["at"])
        dur = round(len(clip) / SR, 3)
        voices[spec["id"]] = {"at": spec["at"], "dur": dur}
        spoken.append((spec["at"], spec["at"] + dur))
    music *= duck_envelope(spoken, length)[:, None]

    effects = np.zeros((length, 2), dtype=np.float32)
    makers = {"shutter": sfx_shutter, "crash": sfx_crash, "bell": sfx_bicycle_bell, "decode": sfx_decode,
              "page": lambda: sfx_swish(0.32, 400, 5000), "chime": sfx_chime, "tick": sfx_tick,
              "stamp": sfx_stamp, "rip": sfx_rip, "bloom": sfx_bloom, "swish": sfx_swish}
    for cue in T["sfx"]:
        if cue["kind"] == "descent":
            place(effects, sfx_descent(cue["until"] - cue["at"]), cue["at"], cue["gain"])
        elif "every" in cue:
            for k in range(cue["count"]):
                place(effects, makers[cue["kind"]](), cue["from"] + k * cue["every"] - 0.12, cue["gain"])
        else:
            place(effects, makers[cue["kind"]](), cue["at"], cue["gain"])
    fireworks = bursts()
    for b in fireworks:
        place(effects, sfx_firework(b["big"], (b["x"] - 0.5) * 1.2), b["t"], -17 if b["big"] else -23)

    schedule = typing_schedule()
    keys = keys_bus(schedule, length)

    mix = music + dialogue + effects + keys
    master(mix)
    generated = {"keys": schedule, "voices": voices, "bursts": fireworks,
                 "note": "Written by build_audio.py from timeline.json. Do not edit by hand."}
    (HERE / "generated.json").write_text(json.dumps(generated, indent=1, ensure_ascii=False), encoding="utf-8")
    print("voices:", {k: v["dur"] for k, v in voices.items()})
    print("keys:", len(schedule["word"]) + sum(len(x) for x in schedule["lines"]), "bursts:", len(fireworks))


if __name__ == "__main__":
    main()

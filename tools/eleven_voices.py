"""Character voices from ElevenLabs, for every person in the game who speaks.

    python tools/eleven_voices.py status
    python tools/eleven_voices.py design  kerstin emil | --city berlin | --all
    python tools/eleven_voices.py record  kerstin emil | --city berlin | --all
    python tools/eleven_voices.py prune   --city berlin

design   turns each brief in tools/voice_cast.json into a voice: three candidates
         speaking the character's own lines, of which the one that says them
         most accurately, in the right language, at a pitch that fits the brief
         is saved to the account. Nobody listens between those steps, so they
         are measured instead: Scribe transcribes each candidate, and its pitch
         is estimated against the brief's age and gender.
record   records every line that speaker has (docs/beta-language-review/
         all-speech.json, from tools/export_all_speech.gd), and the crowd
         fragments and notebook words cast to them, with Eleven v4. Every clip
         is transcribed again and re-taken if it did not say its line; all of
         them are levelled to one loudness so no character is louder than the
         next. Lines are keyed exactly as the game looks them up.
prune    removes voices not marked `keep` once all their lines exist, because
         the plan holds 30 voices at a time.

The API key is read from ELEVENLABS_API_KEY or ~/.elevenlabs/api_key and is
never written anywhere in the project. Voice ids and choices are kept in
audio/voice/eleven-cast.json; clips whose transcripts disagree with their line
are listed in docs/beta-language-review/voice-qa.json for a native listener.
"""
from __future__ import annotations

import argparse
import base64
import datetime
import difflib
import hashlib
import json
import os
import subprocess
import sys
import threading
import time
import unicodedata
import urllib.error
import urllib.parse
import urllib.request
import uuid
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

import numpy as np

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

ROOT = Path(__file__).resolve().parents[1]
VOICE_DIR = ROOT / "audio/voice"
REVIEW = ROOT / "docs/beta-language-review"
CAST = ROOT / "tools/voice_cast.json"
READINGS = ROOT / "tools/voice_readings.json"
STATE = VOICE_DIR / "eleven-cast.json"
MANIFEST = VOICE_DIR / "manifest.json"
QA = REVIEW / "voice-qa.json"
PREVIEWS = ROOT / ".build/voice-design"
API = "https://api.elevenlabs.io"

LOUDNESS = -18.0   # LUFS; every clip, every character
SETTINGS = {"stability": 0.5, "similarity_boost": 0.8, "style": 0.0, "use_speaker_boost": True}
TAKES = 3

LANG = {"german": "de", "turkish": "tr", "english": "en", "french": "fr", "russian": "ru",
        "hindi": "hi", "japanese": "ja", "spanish_mx": "es", "spanish_bo": "es",
        "portuguese": "pt", "italian": "it", "vietnamese": "vi", "korean": "ko",
        "georgian": "ka", "wolof": "wo", "swissgerman": "de"}
ISO3 = {"deu": "de", "ger": "de", "tur": "tr", "eng": "en", "fra": "fr", "fre": "fr",
        "rus": "ru", "hin": "hi", "jpn": "ja", "spa": "es", "por": "pt", "ita": "it",
        "vie": "vi", "kor": "ko", "kat": "ka", "geo": "ka", "wol": "wo", "gsw": "de"}
# Languages a transcriber writes in a way that rarely matches the script
# character for character (kanji for kana, Hinglish in either script), or
# does not know at all; their bar is lower and a miss is a flag, not a fail.
LOOSE = {"ja", "ko", "hi", "ka", "wo", "vi"}

# Something for a character to say while a voice is designed, in their own
# language, when their own lines are too few to fill the hundred characters
# the designer asks for.
FILLER = {
    "german": "Na, wie läuft's? Ich steh hier jeden Tag, bei jedem Wetter, und ehrlich gesagt, ich würd's nicht anders wollen.",
    "turkish": "Hoş geldin. Otur biraz, acele etme. Burada herkes birbirini tanır, sen de yakında tanırsın.",
    "english": "Honestly, it's been one of those days. Kettle's on if you want one, just give it a minute.",
    "french": "Bon, écoutez, ce n'est pas compliqué. On prend le temps, on se dit bonjour, et après on voit.",
    "russian": "Ну, что тут скажешь. Работаем, как всегда. Если что-то нужно, говорите прямо, не стесняйтесь.",
    "hindi": "अरे, आराम से बैठो। यहाँ सब कुछ धीरे-धीरे होता है, लेकिन हो जाता है। चाय पियोगे?",
    "japanese": "そうですね。急がなくても大丈夫ですよ。ゆっくり見て、気に入ったら言ってください。",
    "spanish_mx": "Ándale, pásele. Aquí no hay prisa, joven. Con calma se hacen mejor las cosas.",
    "spanish_bo": "Ya, pues, así es aquí. Primero se saluda, después se pregunta, y todo sale bien.",
    "portuguese": "Ô, tudo bem? Fica à vontade, viu? Aqui a gente conversa pertinho, é assim mesmo.",
    "italian": "Allora, guarda, qui si fa così da quarant'anni. Tu dimmi cosa vuoi e io te lo preparo.",
    "vietnamese": "Không sao đâu, cứ từ từ. Nói lại một lần nữa, chậm thôi, là được rồi.",
    "korean": "괜찮아요, 천천히 하세요. 여기서는 다들 그렇게 배워요. 처음엔 다 어려워요.",
    "georgian": "მოდი, დაჯექი. აქ ყველაფერი მაგიდასთან წყდება. ჯერ ვჭამოთ, მერე ვილაპარაკოთ.",
    "wolof": "Jërëjëf. Tu es le bienvenu ici. Chez nous, on prend le temps de bien se saluer d'abord.",
    "swissgerman": "Grüezi mitenand. Mir händ's nöd so eilig da, gäll. Nimm dir Ziit, das chunnt scho guet.",
}
FILLER_BY_CITY = {
    "honolulu": "Eh, no worry, brah. Da waves stay small today, but still can. Come, we go check 'em out.",
    "newyork": "Look, I got a line out the door here, so what's it gonna be? Take your time, just not too much.",
    "toronto": "Oh, sorry, no, you're totally fine. It's a long ride, so you might as well get comfortable.",
    "sydney": "Yeah, nah, you're all good. Ferry'll be here in a sec, it's never on time anyway, mate.",
}

_lock = threading.Lock()


# ── API ──────────────────────────────────────────────────────────────────────

def _key() -> str:
    key = os.environ.get("ELEVENLABS_API_KEY", "").strip()
    if not key:
        path = Path.home() / ".elevenlabs/api_key"
        key = path.read_text(encoding="utf-8").strip() if path.exists() else ""
    if not key:
        raise SystemExit("No ElevenLabs key: set ELEVENLABS_API_KEY or ~/.elevenlabs/api_key")
    return key


KEY = None


def api(method: str, path: str, *, body=None, query=None, data=None, content_type=None, raw=False):
    global KEY
    KEY = KEY or _key()
    url = API + path + ("?" + urllib.parse.urlencode(query) if query else "")
    headers = {"xi-api-key": KEY}
    if body is not None:
        data = json.dumps(body).encode()
        headers["Content-Type"] = "application/json"
    elif content_type:
        headers["Content-Type"] = content_type
    for attempt in range(6):
        try:
            req = urllib.request.Request(url, data=data, headers=headers, method=method)
            with urllib.request.urlopen(req, timeout=180) as r:
                payload = r.read()
            return payload if raw else (json.loads(payload) if payload else {})
        except urllib.error.HTTPError as e:
            detail = e.read().decode("utf-8", "replace")[:400]
            if e.code in (429, 500, 502, 503, 504) and attempt < 5:
                time.sleep(2 ** attempt + 1)
                continue
            raise RuntimeError(f"{method} {path} -> {e.code}: {detail}") from None
        except (urllib.error.URLError, TimeoutError) as e:
            if attempt < 5:
                time.sleep(2 ** attempt + 1)
                continue
            raise RuntimeError(f"{method} {path} -> {e}") from None


def credits() -> tuple[int, int]:
    s = api("GET", "/v1/user/subscription")
    return int(s.get("character_count", 0)), int(s.get("character_limit", 0))


def transcribe(audio: bytes) -> tuple[str, float, str]:
    boundary = uuid.uuid4().hex
    parts = [
        f'--{boundary}\r\nContent-Disposition: form-data; name="model_id"\r\n\r\nscribe_v1\r\n'.encode(),
        (f'--{boundary}\r\nContent-Disposition: form-data; name="file"; filename="clip.mp3"\r\n'
         "Content-Type: audio/mpeg\r\n\r\n").encode() + audio + b"\r\n",
        f"--{boundary}--\r\n".encode(),
    ]
    r = api("POST", "/v1/speech-to-text", data=b"".join(parts),
            content_type=f"multipart/form-data; boundary={boundary}")
    lang = str(r.get("language_code", "")).lower()
    return ISO3.get(lang, lang[:2]), float(r.get("language_probability", 0.0)), str(r.get("text", ""))


# ── Measuring a clip ─────────────────────────────────────────────────────────

def pcm(audio: bytes, rate: int = 16000) -> np.ndarray:
    out = subprocess.run(["ffmpeg", "-v", "error", "-i", "pipe:0", "-ac", "1", "-ar", str(rate),
                          "-f", "s16le", "pipe:1"], input=audio, capture_output=True, check=True).stdout
    return np.frombuffer(out, dtype=np.int16).astype(np.float32) / 32768.0


def pitch(samples: np.ndarray, rate: int = 16000) -> float:
    """Median fundamental frequency over voiced frames, by YIN.

    Plain autocorrelation was used first and is prone to octave errors - a
    voice read at half or double its pitch - which is exactly the mistake a
    check on age and gender cannot afford. YIN takes the first dip of the
    cumulative-mean-normalised difference below a threshold, which keeps it on
    the fundamental rather than a multiple of it.
    """
    frame, hop = 800, 160                      # 50 ms windows, 10 ms apart
    tau_min, tau_max = rate // 420, rate // 60
    if samples.size < frame + tau_max + 1:
        return 0.0
    level_all = float(np.sqrt(np.mean(samples ** 2)))
    found = []
    for start in range(0, samples.size - frame - tau_max, hop):
        w = samples[start:start + frame]
        if np.sqrt(np.mean(w ** 2)) < max(0.02, level_all * 0.6):
            continue
        shifted = np.lib.stride_tricks.sliding_window_view(
            samples[start:start + frame + tau_max], frame)[:tau_max + 1]
        d = np.sum((shifted - w) ** 2, axis=1)
        cmnd = np.ones_like(d)
        running = np.cumsum(d[1:])
        cmnd[1:] = d[1:] * np.arange(1, tau_max + 1) / np.maximum(running, 1e-12)
        below = np.where(cmnd[tau_min:] < 0.12)[0]
        if below.size == 0:
            continue
        tau = int(below[0]) + tau_min
        while tau + 1 <= tau_max and cmnd[tau + 1] < cmnd[tau]:
            tau += 1
        found.append(rate / tau)
    return float(np.median(found)) if len(found) >= 5 else 0.0


def pitch_range(gender: str, age: int) -> tuple[float, float]:
    if age < 13:
        return (200.0, 360.0)
    if gender == "male":
        return (95.0, 200.0) if age < 18 else (80.0, 165.0)
    if gender == "female":
        return (170.0, 290.0) if age < 18 else ((150.0, 245.0) if age >= 60 else (160.0, 265.0))
    return (135.0, 210.0)


def fold(text: str) -> str:
    text = unicodedata.normalize("NFKC", text).lower()
    return "".join(ch for ch in text if unicodedata.category(ch)[0] in "LN")


def likeness(said: str, meant: str) -> float:
    a, b = fold(said), fold(meant)
    if not a or not b:
        return 0.0
    return difflib.SequenceMatcher(None, a, b).ratio()


def level(audio: bytes) -> bytes:
    """Two-pass EBU R128 loudness to LOUDNESS LUFS, mono, 44.1 kHz, 96 kb/s."""
    probe = subprocess.run(["ffmpeg", "-hide_banner", "-i", "pipe:0", "-af",
                            f"loudnorm=I={LOUDNESS}:TP=-1.5:LRA=11:print_format=json", "-f", "null", "-"],
                           input=audio, capture_output=True, check=True).stderr.decode("utf-8", "replace")
    m = json.loads(probe[probe.rfind("{"):probe.rfind("}") + 1])
    af = (f"loudnorm=I={LOUDNESS}:TP=-1.5:LRA=11:linear=true:"
          f"measured_I={m['input_i']}:measured_TP={m['input_tp']}:measured_LRA={m['input_lra']}:"
          f"measured_thresh={m['input_thresh']}:offset={m['target_offset']}")
    return subprocess.run(["ffmpeg", "-v", "error", "-i", "pipe:0", "-af", af, "-ac", "1", "-ar", "44100",
                           "-c:a", "libmp3lame", "-b:a", "96k", "-f", "mp3", "pipe:1"],
                          input=audio, capture_output=True, check=True).stdout


# ── Data ─────────────────────────────────────────────────────────────────────

def load(path: Path, default):
    return json.loads(path.read_text(encoding="utf-8")) if path.exists() else default


def save(path: Path, data) -> None:
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
    tmp.replace(path)


def norm(text: str) -> str:
    return " ".join(text.strip().split())


class Book:
    def __init__(self):
        self.cast = load(CAST, {})
        self.voices: dict = self.cast["voices"]
        self.readings: dict = load(READINGS, {"readings": {}})["readings"]
        self.speech = load(REVIEW / "all-speech.json", {"lines": []})["lines"]
        self.chatter = load(REVIEW / "chatter-lines.json", {"lines": []})["lines"]
        self.words = load(REVIEW / "key-words.json", {"words": []})["words"]
        self.state = load(STATE, {"voices": {}, "clips": {}})
        self.manifest = load(MANIFEST, {"lines": {}, "chatter": {}, "words": {}})
        self.qa = load(QA, {"flags": {}})

    def owner(self, speaker: str) -> str:
        entry = self.voices.get(speaker, {})
        return entry.get("share", speaker) if entry else speaker

    def lines_of(self, speaker: str) -> list[dict]:
        return [l for l in self.speech if self.owner(l["voice"]) == speaker]

    def crowd_of(self, speaker: str) -> list[tuple[str, dict]]:
        out = []
        for language, cast in self.cast.get("crowd", {}).items():
            if speaker in cast:
                out += [(language, row) for row in self.chatter if row["language"] == language]
        return out

    def words_of(self, speaker: str) -> list[dict]:
        langs = [l for l, s in self.cast.get("notebook", {}).items() if s == speaker]
        return [w for w in self.words if w["language"] in langs]

    def select(self, names: list[str], city: str | None, everyone: bool) -> list[str]:
        # `unvoiced` is a documented exception (the two children), not a to-do.
        own = [k for k, v in self.voices.items() if "share" not in v and "unvoiced" not in v]
        if everyone:
            return own
        if city:
            return [k for k in own if self.voices[k].get("city") == city]
        return names

    def persist(self) -> None:
        with _lock:
            save(STATE, self.state)
            save(MANIFEST, self.manifest)
            save(QA, self.qa)


# ── Design ───────────────────────────────────────────────────────────────────

def sample_text(book: Book, speaker: str) -> str:
    v = book.voices[speaker]
    said = []
    for line in book.lines_of(speaker):
        said.append(book.readings.get(line["voice"] + "|" + line["text"], line["text"]))
    text = " ".join(dict.fromkeys(said))
    language = book.lines_of(speaker)[0]["language"] if book.lines_of(speaker) else "english"
    filler = FILLER_BY_CITY.get(v.get("city", ""), FILLER.get(language, FILLER["english"]))
    while len(text) < 110:
        text = (text + " " + filler).strip()
    # A design costs a credit a character; twenty seconds of someone is plenty
    # to hear who they are.
    return text[:320].rsplit(" ", 1)[0] if len(text) > 320 else text


def design(book: Book, speaker: str) -> None:
    if book.state["voices"].get(speaker, {}).get("voice_id"):
        print(f"  {speaker}: already designed")
        return
    v = book.voices[speaker]
    text = sample_text(book, speaker)
    language = book.lines_of(speaker)[0]["language"] if book.lines_of(speaker) else "english"
    want = LANG.get(language, "")
    seed = int(hashlib.sha256(speaker.encode()).hexdigest()[:8], 16) & 0x7FFFFFFF
    brief = (v["design"] + " " + book.cast.get("style", "")).strip()
    lo, hi = pitch_range(v.get("gender", ""), int(v.get("age", 40)))
    folder = PREVIEWS / speaker
    folder.mkdir(parents=True, exist_ok=True)
    best, notes = None, []
    # Up to three rounds of three: a round where no candidate sits where the
    # brief's age and gender would put them (Omkar came back at 186-211 Hz as
    # a 22-year-old man) is thrown away and designed again. Unsaved candidates
    # cost credits but not one of the month's voice additions.
    for rnd in range(3):
        r = api("POST", "/v1/text-to-voice/design", body={
            "voice_description": brief[:1000], "model_id": book.cast.get("design_model", "eleven_ttv_v3"),
            "text": text, "seed": (seed + rnd * 7919) & 0x7FFFFFFF})
        previews = r.get("previews", [])
        audios = [base64.b64decode(p["audio_base_64"]) for p in previews]
        with ThreadPoolExecutor(3) as pool:
            heard_all = list(pool.map(transcribe, audios))
        for i, p in enumerate(previews):
            audio = audios[i]
            (folder / f"candidate-{rnd}-{i}.mp3").write_bytes(audio)
            f0 = pitch(pcm(audio))
            lang, _prob, heard = heard_all[i]
            sim = likeness(heard, text)
            off = 0.0 if lo <= f0 <= hi else min(abs(f0 - lo), abs(f0 - hi)) / 40.0
            lang_ok = (not want) or lang == want or want in LOOSE or (want == "de" and lang in ("de", "gsw"))
            score = (2.0 if lang_ok else 0.0) + 2.0 * sim - off
            notes.append({"candidate": f"{rnd}-{i}", "pitch": round(f0), "language": lang,
                          "likeness": round(sim, 2), "score": round(score, 2)})
            if best is None or score > best[0]:
                best = (score, p["generated_voice_id"], f"{rnd}-{i}", f0, lang, sim)
        if best is not None and lo <= best[3] <= hi:
            break
    if best is None:
        raise RuntimeError(f"{speaker}: the designer returned no candidates")
    saved = api("POST", "/v1/text-to-voice", body={
        "voice_name": f"FtA {speaker}", "voice_description": brief[:1000],
        "generated_voice_id": best[1]})
    book.state["voices"][speaker] = {
        "voice_id": saved["voice_id"], "candidate": best[2], "pitch": round(best[3]),
        "heard_language": best[4], "likeness": round(best[5], 2), "candidates": notes,
        "seed": seed, "design_model": book.cast.get("design_model"),
        "created": datetime.date.today().isoformat(), "keep": bool(v.get("keep", False))}
    book.persist()
    print(f"  {speaker}: chose candidate {best[2]} (pitch {best[3]:.0f} Hz, want {lo:.0f}-{hi:.0f}; "
          f"heard {best[4]}, likeness {best[5]:.2f})")


# ── Recording ────────────────────────────────────────────────────────────────

def take(book: Book, voice_id: str, text: str, want: str, seed: int) -> tuple[bytes, float]:
    best = (b"", -1.0)
    for attempt in range(TAKES):
        audio = api("POST", f"/v1/text-to-speech/{voice_id}", raw=True,
                    query={"output_format": "mp3_44100_128"},
                    body={"text": text, "model_id": book.cast.get("model", "eleven_v4"),
                          "voice_settings": SETTINGS, "seed": (seed + attempt) & 0x7FFFFFFF})
        _lang, _prob, heard = transcribe(audio)
        sim = likeness(heard, text)
        bar = 0.45 if want in LOOSE else 0.7
        if len(fold(text)) < 6:
            bar = 0.3   # "Na?" transcribes as anything; keep the take that is closest
        if sim > best[1]:
            best = (audio, sim)
        if sim >= bar:
            break
    return best


def clip_path(kind: str, key: str, voice_id: str, text: str) -> Path:
    digest = hashlib.sha256(f"eleven|{kind}|{key}|{voice_id}|{text}".encode()).hexdigest()[:24]
    return VOICE_DIR / f"el_{digest}.mp3"


def record_one(book: Book, kind: str, key: str, text: str, language: str, voice_id: str) -> str:
    dest = clip_path(kind, key, voice_id, text)
    res = "res://audio/voice/" + dest.name
    if not dest.exists():
        want = LANG.get(language, "")
        seed = int(hashlib.sha256(key.encode()).hexdigest()[:8], 16)
        audio, sim = take(book, voice_id, text, want, seed)
        dest.write_bytes(level(audio))
        bar = 0.45 if want in LOOSE else 0.7
        with _lock:
            if sim < bar and len(fold(text)) >= 6:
                book.qa["flags"][f"{kind}|{key}"] = {"likeness": round(sim, 2), "file": res}
            else:
                book.qa["flags"].pop(f"{kind}|{key}", None)
    return res


def record(book: Book, speaker: str) -> None:
    info = book.state["voices"].get(speaker)
    if not info or not info.get("voice_id") or info.get("pruned"):
        print(f"  {speaker}: no live voice - design it first")
        return
    vid = info["voice_id"]
    jobs = []
    for line in book.lines_of(speaker):
        key = line["voice"] + "|" + norm(line["text"])
        jobs.append(("lines", key, book.readings.get(key, line["text"]), line["language"]))
    for language, row in book.crowd_of(speaker):
        key = language + "|" + norm(row["text"])
        jobs.append(("chatter", key, book.readings.get(key, row["text"]), language))
    for w in book.words_of(speaker):
        jobs.append(("words", w["language"] + "|" + w["word"].strip().lower(), w["word"], w["language"]))

    def run(job):
        kind, key, text, language = job
        try:
            res = record_one(book, kind, key, text, language, vid)
        except Exception as exc:   # one bad line must not lose the rest
            print(f"    FAILED {key}: {exc}")
            return
        with _lock:
            if kind == "chatter":
                paths = [p for p in book.manifest.setdefault("chatter", {}).get(key, [])
                         if Path(p).name.startswith("el_")]
                if res not in paths:
                    paths.append(res)
                book.manifest["chatter"][key] = paths
            else:
                book.manifest.setdefault(kind, {})[key] = res
            book.state["clips"][f"{kind}|{key}|{speaker}"] = res
        book.persist()

    with ThreadPoolExecutor(5) as pool:
        list(pool.map(run, jobs))
    lines = sum(1 for j in jobs if j[0] == "lines")
    print(f"  {speaker}: {lines} lines, {len(jobs) - lines} crowd/notebook clips")
    info["recorded"] = datetime.date.today().isoformat()
    book.persist()


def prune(book: Book, speaker: str) -> None:
    info = book.state["voices"].get(speaker, {})
    if not info.get("voice_id") or info.get("pruned") or info.get("keep"):
        return
    if not info.get("recorded"):
        print(f"  {speaker}: not recorded yet - keeping the voice")
        return
    api("DELETE", f"/v1/voices/{info['voice_id']}")
    info["pruned"] = datetime.date.today().isoformat()
    book.persist()
    print(f"  {speaker}: voice removed (lines kept)")


# Everything, within the plan's slots: the voices that stay first, then the
# rest a few at a time - designed, recorded and removed before the next few.
def cast(book: Book, names: list[str]) -> None:
    def safely(step, name):
        try:
            step(book, name)
        except Exception as exc:   # one refused design must not stop the other ninety
            print(f"  {name}: {exc}")

    def make(name):
        safely(design, name)
        if not book.state["voices"].get(name, {}).get("recorded"):
            safely(record, name)

    keep = [n for n in names if book.voices[n].get("keep")]
    rest = [n for n in names if n not in keep]
    for name in keep:
        make(name)
    sub = api("GET", "/v1/user/subscription")
    room = max(1, int(sub.get("voice_limit", 30)) - int(sub.get("voice_slots_used", 0)))
    for start in range(0, len(rest), room):
        batch = rest[start:start + room]
        # The batch fits the free slots, so its voices can be designed at once.
        with ThreadPoolExecutor(len(batch)) as pool:
            list(pool.map(lambda n: safely(design, n), batch))
        for name in batch:
            if not book.state["voices"].get(name, {}).get("recorded"):
                safely(record, name)
        for name in batch:
            safely(prune, name)


# A saved voice that turned out wrong for its character: removed from the
# account, designed again from the (possibly revised) brief, and its lines
# recorded again. The new clips replace the old ones in the manifest; `tidy`
# then deletes the old files.
def redesign(book: Book, speaker: str) -> None:
    info = book.state["voices"].get(speaker, {})
    if info.get("voice_id") and not info.get("pruned"):
        try:
            api("DELETE", f"/v1/voices/{info['voice_id']}")
        except RuntimeError as exc:
            print(f"  {speaker}: could not remove the old voice ({exc}); designing anyway")
    # The old voice's crowd clips come out of the street; its lines and words
    # are simply overwritten when they are recorded again.
    old = {res for key, res in book.state["clips"].items() if key.endswith("|" + speaker)}
    for key in list(book.manifest.get("chatter", {})):
        book.manifest["chatter"][key] = [p for p in book.manifest["chatter"][key] if p not in old]
    book.state["clips"] = {k: r for k, r in book.state["clips"].items() if not k.endswith("|" + speaker)}
    book.state["voices"].pop(speaker, None)
    book.persist()
    design(book, speaker)
    record(book, speaker)
    if not book.voices[speaker].get("keep"):
        prune(book, speaker)


# Clips nothing points at any more - the edge-tts takes a character's own
# voice replaced, or a line since rewritten - with their import files.
def tidy(book: Book) -> None:
    used = set()
    for section in ("lines", "words"):
        used |= {Path(p).name for p in book.manifest.get(section, {}).values()}
    for paths in book.manifest.get("chatter", {}).values():
        used |= {Path(p).name for p in paths}
    gone = 0
    for clip in VOICE_DIR.glob("*.mp3"):
        if clip.name not in used:
            clip.unlink()
            imp = clip.with_name(clip.name + ".import")
            if imp.exists():
                imp.unlink()
            gone += 1
    said = {l["voice"] + "|" + norm(l["text"]) for l in book.speech}
    stale = [k for k in book.manifest.get("lines", {}) if k not in said]
    print(f"removed {gone} unused clips; {len(stale)} manifest lines no longer said in the game"
          + (": " + "; ".join(stale[:8]) if stale else ""))


def status(book: Book) -> None:
    used, limit = credits()
    sub = api("GET", "/v1/user/subscription")
    own = [k for k, v in book.voices.items() if "share" not in v]
    designed = [k for k in own if book.state["voices"].get(k, {}).get("voice_id")]
    recorded = [k for k in own if book.state["voices"].get(k, {}).get("recorded")]
    print(f"credits {used}/{limit}; voices {sub.get('voice_slots_used')}/{sub.get('voice_limit')} slots, "
          f"{sub.get('voice_add_edit_counter')}/{sub.get('max_voice_add_edits')} adds this month")
    print(f"cast {len(own)} voices: {len(designed)} designed, {len(recorded)} recorded; "
          f"{len(book.qa['flags'])} clips flagged for a listener")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("command", choices=["status", "design", "record", "prune", "cast", "tidy", "redesign"])
    ap.add_argument("speakers", nargs="*")
    ap.add_argument("--city")
    ap.add_argument("--all", action="store_true")
    a = ap.parse_args()
    book = Book()
    if a.command in ("status", "tidy"):
        {"status": status, "tidy": tidy}[a.command](book)
        return
    names = book.select(a.speakers, a.city, a.all)
    unknown = [n for n in names if n not in book.voices]
    if unknown:
        raise SystemExit("not in the cast: " + ", ".join(unknown))
    before = credits()[0]
    if a.command == "cast":
        cast(book, names)
        print(f"credits used this run: {credits()[0] - before}")
        return
    for name in names:
        try:
            {"design": design, "record": record, "prune": prune,
             "redesign": redesign}[a.command](book, name)
        except Exception as exc:
            print(f"  {name}: {exc}")
    print(f"credits used this run: {credits()[0] - before}")


if __name__ == "__main__":
    main()

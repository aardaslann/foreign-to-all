"""Build exact-line beta speech using the trailer's existing edge-tts pipeline.

Superseded for the game's characters by tools/eleven_voices.py (ElevenLabs,
one designed voice per character). This stays as a fallback for lines that
have no ElevenLabs recording yet, and it never replaces one: any manifest
entry that already points at an ElevenLabs clip (el_*.mp3) is left alone.

Run export_beta_speech.gd first. Only the authored spoken lines go to the speech
service. Generated voices are synthetic, provisional and pending local review.
Hash-addressed clips resume safely; the manifest replaces only completed entries.
"""
from pathlib import Path
import argparse
import asyncio
import hashlib
import json
import sys
import edge_tts

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

ROOT = Path(__file__).resolve().parents[1]
VOICE_DIR = ROOT / "audio/voice"


def eleven(entry) -> bool:
    """True when a manifest entry is already an ElevenLabs recording."""
    paths = entry if isinstance(entry, list) else [entry]
    return any(str(p).rsplit("/", 1)[-1].startswith("el_") for p in paths if p)
VOICES = {
    "german": "de-DE-KatjaNeural", "english": "en-GB-LibbyNeural",
    "french": "fr-FR-DeniseNeural", "russian": "ru-RU-SvetlanaNeural",
    "turkish": "tr-TR-EmelNeural", "hindi": "hi-IN-SwaraNeural",
    "japanese": "ja-JP-NanamiNeural", "spanish_mx": "es-MX-DaliaNeural",
}


async def main(limit: int = 0) -> None:
    rows = json.loads((ROOT / "docs/beta-language-review/spoken-lines.json").read_text(encoding="utf-8"))["lines"]
    if limit:
        rows = rows[:limit]
    VOICE_DIR.mkdir(parents=True, exist_ok=True)
    manifest_path = VOICE_DIR / "manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8")) if manifest_path.exists() else {"lines": {}, "chatter": {}}
    manifest["provenance"] = {"source": "edge-tts synthetic speech", "review": "pending native-speaker review"}
    sem = asyncio.Semaphore(2)
    failures = []

    def persist():
        temporary = manifest_path.with_suffix(".json.tmp")
        temporary.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
        temporary.replace(manifest_path)

    async def record(row):
        async with sem:
            voice_id, text = row["voice"], " ".join(row["text"].split())
            if eleven(manifest["lines"].get(voice_id + "|" + text)):
                return
            voice = VOICES[row["language"]]
            if voice_id == "emil":
                voice = "de-DE-ConradNeural"
            elif voice_id == "val":
                voice = "en-GB-SoniaNeural"
            elif voice_id == "ahmed":
                voice = "en-GB-RyanNeural"
            elif voice_id in ["arda", "hasan"]:
                voice = "tr-TR-AhmetNeural"
            elif voice_id == "marcel":
                voice = "fr-FR-HenriNeural"
            elif voice_id in ["viktor", "pavel"]:
                voice = "ru-RU-DmitryNeural"
            elif voice_id in ["omkar", "yusuf"]:
                voice = "hi-IN-MadhurNeural"
            elif voice_id == "mori":
                voice = "ja-JP-KeitaNeural"
            elif voice_id == "tomas":
                voice = "es-MX-JorgeNeural"
            digest = hashlib.sha256((voice_id + "|" + voice + "|" + text).encode()).hexdigest()[:24]
            destination = VOICE_DIR / (digest + ".mp3")
            if not destination.exists() or destination.stat().st_size < 500:
                temporary = destination.with_suffix(".mp3.tmp")
                try:
                    await asyncio.wait_for(edge_tts.Communicate(text, voice, rate="-7%").save(str(temporary)), timeout=45)
                    if temporary.stat().st_size < 500:
                        raise RuntimeError("empty audio")
                    temporary.replace(destination)
                except Exception as exc:
                    failures.append((voice_id, text, str(exc)))
                    print(f"FAILED {voice_id}: {type(exc).__name__}", flush=True)
                    return
            manifest["lines"][voice_id + "|" + text] = "res://audio/voice/" + destination.name
            persist()
            print(f"READY {len(manifest['lines'])}: {voice_id}: {text[:70]}", flush=True)

    await asyncio.gather(*(record(row) for row in rows))
    persist()
    print(f"Speech manifest: {len(manifest['lines'])} clips, {len(failures)} failures", flush=True)
    if failures:
        raise SystemExit(1)


# The crowd. Two street voices per language, neither of them anybody in a story,
# so a passer-by never sounds like Kerstin. Each fragment is recorded in both and
# AudioManager.murmur() picks one, which is most of what makes a street sound
# like more than one person. Run export_chatter.gd first.
CHATTER_VOICES = {
    "german": ["de-DE-KillianNeural", "de-DE-AmalaNeural"],
    "turkish": ["tr-TR-AhmetNeural", "tr-TR-EmelNeural"],
    "english": ["en-GB-ThomasNeural", "en-GB-SoniaNeural"],
    "french": ["fr-FR-RemyMultilingualNeural", "fr-FR-VivienneMultilingualNeural"],
    "spanish_mx": ["es-MX-JorgeNeural", "es-MX-DaliaNeural"],
}


async def chatter() -> None:
    rows = json.loads((ROOT / "docs/beta-language-review/chatter-lines.json").read_text(encoding="utf-8"))["lines"]
    manifest_path = VOICE_DIR / "manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8")) if manifest_path.exists() else {"lines": {}, "chatter": {}}
    manifest.setdefault("chatter", {})
    sem = asyncio.Semaphore(2)
    failures = []

    async def record(row, voice):
        async with sem:
            text = " ".join(row["text"].split())
            digest = hashlib.sha256(("chatter|" + voice + "|" + text).encode()).hexdigest()[:24]
            destination = VOICE_DIR / (digest + ".mp3")
            if not destination.exists() or destination.stat().st_size < 500:
                temporary = destination.with_suffix(".mp3.tmp")
                try:
                    await asyncio.wait_for(edge_tts.Communicate(text, voice).save(str(temporary)), timeout=45)
                    if temporary.stat().st_size < 500:
                        raise RuntimeError("empty audio")
                    temporary.replace(destination)
                except Exception as exc:
                    failures.append((voice, text, str(exc)))
                    print(f"FAILED {voice}: {type(exc).__name__}", flush=True)
                    return None
            return "res://audio/voice/" + destination.name

    for row in rows:
        if eleven(manifest["chatter"].get(row["language"] + "|" + " ".join(row["text"].split()))):
            continue
        voices = CHATTER_VOICES.get(row["language"], [])
        paths = [p for p in await asyncio.gather(*(record(row, v) for v in voices)) if p]
        if paths:
            manifest["chatter"][row["language"] + "|" + " ".join(row["text"].split())] = paths
    temporary = manifest_path.with_suffix(".json.tmp")
    temporary.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    temporary.replace(manifest_path)
    print(f"Chatter manifest: {len(manifest['chatter'])} fragments, {len(failures)} failures", flush=True)
    if failures:
        raise SystemExit(1)


# The notebook's words, one at a time, a little slower than speech, in a voice
# that is nobody in a story. Run export_key_words.gd first.
WORD_VOICES = {
    "german": "de-DE-SeraphinaMultilingualNeural", "turkish": "tr-TR-EmelNeural",
    "english": "en-GB-SoniaNeural", "french": "fr-FR-VivienneMultilingualNeural",
    "spanish_mx": "es-MX-DaliaNeural",
}


async def words() -> None:
    rows = json.loads((ROOT / "docs/beta-language-review/key-words.json").read_text(encoding="utf-8"))["words"]
    manifest_path = VOICE_DIR / "manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8")) if manifest_path.exists() else {"lines": {}, "chatter": {}}
    manifest.setdefault("words", {})
    sem = asyncio.Semaphore(2)
    failures = []

    async def record(row):
        async with sem:
            voice = WORD_VOICES.get(row["language"])
            if voice is None:
                return
            word = row["word"].strip().lower()
            if eleven(manifest["words"].get(row["language"] + "|" + word)):
                return
            digest = hashlib.sha256(("word|" + voice + "|" + word).encode()).hexdigest()[:24]
            destination = VOICE_DIR / (digest + ".mp3")
            if not destination.exists() or destination.stat().st_size < 500:
                temporary = destination.with_suffix(".mp3.tmp")
                try:
                    await asyncio.wait_for(edge_tts.Communicate(word, voice, rate="-15%").save(str(temporary)), timeout=45)
                    if temporary.stat().st_size < 500:
                        raise RuntimeError("empty audio")
                    temporary.replace(destination)
                except Exception as exc:
                    failures.append((voice, word, str(exc)))
                    print(f"FAILED {voice}: {type(exc).__name__}", flush=True)
                    return
            manifest["words"][row["language"] + "|" + word] = "res://audio/voice/" + destination.name

    await asyncio.gather(*(record(row) for row in rows))
    temporary = manifest_path.with_suffix(".json.tmp")
    temporary.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    temporary.replace(manifest_path)
    print(f"Word manifest: {len(manifest['words'])} words, {len(failures)} failures", flush=True)
    if failures:
        raise SystemExit(1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--limit", type=int, default=0)
    parser.add_argument("--chatter", action="store_true",
        help="record the crowd's fragments instead of the authored lines")
    parser.add_argument("--words", action="store_true",
        help="record the notebook's key words, one at a time")
    arguments = parser.parse_args()
    if arguments.chatter:
        asyncio.run(chatter())
    elif arguments.words:
        asyncio.run(words())
    else:
        asyncio.run(main(arguments.limit))

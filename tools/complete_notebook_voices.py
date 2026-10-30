"""Fill missing notebook/name clips with retained cast voices, without redoing existing audio.

Dry run by default. --record uses the configured ElevenLabs account, with a
5,000-character source-text ceiling and the existing three-take QA limit.
"""
import argparse
import json
from concurrent.futures import ThreadPoolExecutor

import eleven_voices as ev

SPEAKERS = {"german": "kerstin", "turkish": "arda", "english": "nadia",
            "french": "odile", "russian": "viktor", "hindi": "omkar",
            "japanese": "setsuko", "spanish_mx": "rocio"}
NAMES = {"german": ("Fremd", "Fremd."), "turkish": ("Yabanci", "Yabancı."),
         "english": ("Foreign", "Foreign."), "french": ("Etranger", "Étranger."),
         "russian": ("Chuzhoy", "Чужой."), "hindi": ("Pardesi", "परदेसी।"),
         "japanese": ("Gaijin", "外人。"), "spanish_mx": ("Extranjero", "Extranjero.")}


def jobs_for(book, readings):
    jobs = []
    for word in book.words:
        lang, word = word["language"], word["word"]
        key = lang + "|" + word
        existing = book.manifest.get("words", {}).get(key, "")
        if existing and (ev.ROOT / existing.removeprefix("res://")).is_file():
            continue
        if lang in ("russian", "hindi", "japanese") and word not in readings.get(lang, {}):
            raise ValueError(f"Missing native recording input: {key}")
        jobs.append(("words", key, readings.get(lang, {}).get(word, word), lang, SPEAKERS[lang]))
    for lang, (display, spoken) in NAMES.items():
        speaker = SPEAKERS[lang]
        key = speaker + "|" + ev.norm(display)
        existing = book.manifest.get("lines", {}).get(key, "")
        if not existing or not (ev.ROOT / existing.removeprefix("res://")).is_file():
            jobs.append(("lines", key, spoken, lang, speaker))
    return jobs


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--record", action="store_true")
    args = parser.parse_args()
    book = ev.Book()
    readings = json.loads((ev.ROOT / "tools/notebook_readings.json").read_text(encoding="utf-8"))
    jobs = jobs_for(book, readings)
    characters = sum(len(job[2]) for job in jobs)
    if characters > 5000:
        raise SystemExit(f"Refusing unbounded batch: {characters} characters")
    for speaker in {job[4] for job in jobs}:
        voice = book.state["voices"].get(speaker, {})
        if not voice.get("voice_id") or voice.get("pruned"):
            raise SystemExit(f"No retained voice for {speaker}; existing audio left untouched")
    print(f"Missing clips: {len(jobs)}; source characters: {characters}; max takes: {ev.TAKES}", flush=True)
    if not args.record:
        return
    failures = []

    def record(job):
        kind, key, text, lang, speaker = job
        try:
            path = ev.record_one(book, kind, key, text, lang, book.state["voices"][speaker]["voice_id"])
            with ev._lock:
                book.manifest.setdefault(kind, {})[key] = path
                book.state["clips"][f"{kind}|{key}|{speaker}"] = path
            book.persist()
            print(f"Recorded {kind}: {key}", flush=True)
        except Exception as exc:
            failures.append(key)
            print(f"FAILED {key}: {exc}", flush=True)

    with ThreadPoolExecutor(max_workers=3) as pool:
        list(pool.map(record, jobs))
    if failures:
        raise SystemExit(f"Incomplete: {len(failures)} clips failed; rerun resumes missing clips")
    print("Missing notebook and naming clips recorded. Native listening review remains pending.")


if __name__ == "__main__":
    main()

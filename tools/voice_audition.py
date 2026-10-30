"""A page to listen to the cast on: every voice, its brief, and a few of its
lines, grouped by city. Writes .build/voice-audition/index.html, which plays
the clips straight from audio/voice/ - open it in a browser.

    python tools/voice_audition.py
"""
from __future__ import annotations

import html
import json
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / ".build/voice-audition/index.html"
SAMPLES = 4


def load(path: str):
    return json.loads((ROOT / path).read_text(encoding="utf-8"))


def main() -> None:
    cast = load("tools/voice_cast.json")
    state = load("audio/voice/eleven-cast.json")["voices"]
    manifest = load("audio/voice/manifest.json")
    speech = load("docs/beta-language-review/all-speech.json")["lines"]
    flags = load("docs/beta-language-review/voice-qa.json")["flags"]
    voices = cast["voices"]

    def owner(s: str) -> str:
        return voices.get(s, {}).get("share", s)

    def rel(res: str) -> str:
        return "../../" + res.replace("res://", "")

    by_city: dict[str, list[str]] = {}
    for sid, v in voices.items():
        if "share" not in v:
            by_city.setdefault(v.get("city", "?"), []).append(sid)

    cards = []
    for city in sorted(by_city):
        rows = []
        for sid in by_city[city]:
            v, info = voices[sid], state.get(sid, {})
            lines = [l for l in speech if owner(l["voice"]) == sid]
            clips = []
            for l in lines[:SAMPLES]:
                key = l["voice"] + "|" + " ".join(l["text"].split())
                path = manifest.get("lines", {}).get(key, "")
                if path.rsplit("/", 1)[-1].startswith("el_"):
                    flag = " ⚑" if f"lines|{key}" in flags else ""
                    clips.append(f'<li><audio controls preload="none" src="{html.escape(rel(path))}"></audio>'
                                 f'<span>{html.escape(l["text"])}{flag}</span></li>')
            shared = [k for k, x in voices.items() if x.get("share") == sid]
            meta = []
            if info.get("pitch"):
                meta.append(f'{info["pitch"]} Hz')
            if info.get("heard_language"):
                meta.append(f'heard as {info["heard_language"]}')
            if v.get("gender_source"):
                meta.append("gender: " + v["gender_source"])
            if shared:
                meta.append("also voices " + ", ".join(shared))
            if not clips:
                meta.append("NOT RECORDED")
            rows.append(
                f'<article><h3>{html.escape(sid)} <small>{html.escape(str(v.get("gender", "")))}, '
                f'{html.escape(str(v.get("age", "")))}{" · kept" if v.get("keep") else ""}</small></h3>'
                f'<p class="brief">{html.escape(v.get("design", ""))}</p>'
                f'<p class="meta">{html.escape(" · ".join(meta))}</p><ul>{"".join(clips)}</ul></article>')
        cards.append(f'<section><h2>{html.escape(city.title())}</h2>{"".join(rows)}</section>')

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(f"""<!doctype html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Cast Audition</title>
<style>
:root {{ --bg:#15131f; --card:#1f1c2e; --ink:#ece8ff; --dim:#a39fc4; --gold:#f3d58a; }}
body {{ margin:0; padding:24px 16px 64px; background:var(--bg); color:var(--ink);
  font:15px/1.5 system-ui, sans-serif; }}
main {{ max-width:1100px; margin:0 auto; }}
h1 {{ font-weight:600; margin:0 0 4px; }} .lede {{ color:var(--dim); margin:0 0 24px; }}
h2 {{ color:var(--gold); border-bottom:1px solid #3a3552; padding-bottom:4px; margin-top:36px; }}
section {{ display:grid; grid-template-columns:repeat(auto-fill, minmax(320px, 1fr)); gap:14px; }}
section h2 {{ grid-column:1 / -1; }}
article {{ background:var(--card); border-radius:10px; padding:12px 14px; }}
h3 {{ margin:0; font-size:16px; }} small {{ color:var(--dim); font-weight:400; }}
.brief {{ color:var(--dim); font-size:13px; margin:6px 0; }} .meta {{ font-size:12px; color:var(--gold); margin:4px 0 8px; }}
ul {{ list-style:none; padding:0; margin:0; }} li {{ margin:6px 0; }}
audio {{ width:100%; height:32px; }} li span {{ display:block; font-size:13px; }}
</style></head><body><main>
<h1>Cast audition</h1>
<p class="lede">Every designed voice with its brief and up to {SAMPLES} of its lines. ⚑ marks a clip whose
transcript disagreed with its line; it needs a listener. Played from the game's own audio/voice folder.</p>
{"".join(cards)}
</main></body></html>""", encoding="utf-8")
    print(f"wrote {OUT}")


if __name__ == "__main__":
    main()

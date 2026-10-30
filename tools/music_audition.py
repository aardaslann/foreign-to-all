"""A page to listen to the music on: every track in the game, the takes it was
chosen over, the prompt behind it and the numbers the choice was made on.
Writes .build/music-audition/index.html, which plays straight from
audio/music/ and .build/music-candidates/ - open it in a browser.

    python tools/music_audition.py

"Hear the join" starts a loop five seconds before its end, so the seam is the
first thing you hear. To swap a pick: python tools/music_promote.py <track> <take>
"""
from __future__ import annotations

import html
import json
import subprocess
import sys
from pathlib import Path

import numpy as np

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / ".build/music-audition/index.html"
CANDIDATES = ROOT / ".build/music-candidates"
CORE = ["berlin", "london", "paris", "moscow", "istanbul", "mumbai", "tokyo", "mexico"]
NAMES = {"lapaz": "La Paz", "newyork": "New York", "saopaulo": "São Paulo", "mexico": "Mexico City",
         "travel": "Airports & departures", "title": "Title screen"}


def load(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8")) if path.exists() else {}


def swing_db(path: Path) -> float:
    """How far the level moves inside the loop (10th to 90th percentile, 1 s windows)."""
    raw = subprocess.run(["ffmpeg", "-v", "error", "-i", str(path), "-f", "f32le", "-ac", "1", "-ar", "22050",
                          "pipe:1"], capture_output=True, check=True).stdout
    x = np.frombuffer(raw, np.float32)
    rms = np.array([np.sqrt(np.mean(x[i:i + 22050] ** 2)) for i in range(0, x.size - 22050, 11025)])
    db = 20 * np.log10(rms + 1e-9)
    return float(np.percentile(db, 90) - np.percentile(db, 10))


def player(src: str, entry: dict, path: Path, label: str, chosen: bool) -> str:
    stats = (f'{entry.get("bpm", "?")} BPM · loops every {entry.get("loop_seconds", "?")} s · '
             f'join {entry.get("seam_likeness", "?")} · level moves {swing_db(path):.1f} dB')
    badge = '<b class="pick">in the game</b>' if chosen else ""
    return (f'<div class="track{" chosen" if chosen else ""}"><div class="row"><span class="take">'
            f'{html.escape(label)}</span>{badge}<button type="button" onclick="join(this)">Hear the join</button>'
            f'</div><audio controls preload="none" src="{html.escape(src)}"></audio>'
            f'<p class="stats">{html.escape(stats)}</p></div>')


def card(key: str, game: dict, cand: dict, prompts: dict) -> str:
    entry = game.get(key, {})
    if not entry:
        return ""
    chosen_from = entry.get("chosen_from", "")
    parts = [player(f"../../audio/music/{key}.ogg", entry, ROOT / f"audio/music/{key}.ogg",
                    chosen_from or "take A", True)]
    for take in sorted(t for t in cand if t.rsplit("_", 1)[0] == key and t != chosen_from):
        parts.append(player(f"../music-candidates/{take}.ogg", cand[take], CANDIDATES / f"{take}.ogg",
                            take, False))
    name = key.replace("festival_", "")
    title = NAMES.get(name, name.title()) + (" festival" if key.startswith("festival_") else "")
    prompt = prompts.get(key, {}).get("prompt", "")
    return (f'<article><h3>{html.escape(title)}</h3>{"".join(parts)}'
            f'<details><summary>Prompt</summary><p>{html.escape(prompt)}</p></details></article>')


def main() -> None:
    game = load(ROOT / "audio/music/music.json")
    cand = load(CANDIDATES / "music.json")
    prompts = load(ROOT / "tools/music_prompts.json")
    groups = [("Title and travel", ["title", "travel"]),
              ("The eight beta cities, each with its festival",
               [k for c in CORE for k in (c, "festival_" + c)]),
              ("The other twelve cities",
               sorted(k for k in game if k not in CORE and k not in ("title", "travel")
                      and not k.startswith("festival_")))]
    sections = [f'<section><h2>{html.escape(name)}</h2>{"".join(card(k, game, cand, prompts) for k in keys)}</section>'
                for name, keys in groups]
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(f"""<!doctype html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Music Audition</title>
<style>
:root {{ --bg:#15131f; --card:#1f1c2e; --ink:#ece8ff; --dim:#a39fc4; --gold:#f3d58a; --line:#3a3552; }}
body {{ margin:0; padding:24px 16px 64px; background:var(--bg); color:var(--ink);
  font:15px/1.5 system-ui, sans-serif; }}
main {{ max-width:1100px; margin:0 auto; }}
h1 {{ font-weight:600; margin:0 0 4px; }} .lede {{ color:var(--dim); margin:0 0 24px; max-width:70ch; }}
h2 {{ color:var(--gold); border-bottom:1px solid var(--line); padding-bottom:4px; margin-top:36px; }}
section {{ display:grid; grid-template-columns:repeat(auto-fill, minmax(320px, 1fr)); gap:14px; }}
section h2 {{ grid-column:1 / -1; }}
article {{ background:var(--card); border-radius:10px; padding:12px 14px; }}
h3 {{ margin:0 0 8px; font-size:16px; }}
.track {{ border-top:1px solid var(--line); padding:8px 0 4px; }} .track:first-of-type {{ border-top:0; }}
.track:not(.chosen) {{ opacity:.8; }}
.row {{ display:flex; gap:8px; align-items:center; }} .take {{ font-size:13px; color:var(--dim); }}
.pick {{ font-size:11px; font-weight:600; color:#15131f; background:var(--gold); border-radius:4px; padding:0 6px; }}
button {{ margin-left:auto; font:inherit; font-size:12px; color:var(--ink); background:#2c2842;
  border:1px solid var(--line); border-radius:6px; padding:2px 8px; cursor:pointer; }}
button:hover {{ border-color:var(--gold); }} button:focus-visible {{ outline:2px solid var(--gold); outline-offset:2px; }}
audio {{ width:100%; height:32px; margin-top:4px; }}
.stats {{ font-size:12px; color:var(--gold); margin:2px 0 0; }}
details {{ margin-top:8px; font-size:13px; color:var(--dim); }} summary {{ cursor:pointer; }}
code {{ color:var(--gold); }}
</style></head><body><main>
<h1>Music audition</h1>
<p class="lede">Every track in the game, cut into a seamless loop, above the takes it was chosen over.
<b>Hear the join</b> starts five seconds before the loop's end, so the seam is the first thing you hear
(the browser can leave a hair of a gap that the game does not). "Join" is how alike the two sides of the
cut sound, 1.0 being identical; "level moves" is how much it swells and dips, which background music
should barely do. To put a different take in the game: <code>python tools/music_promote.py seoul seoul_a</code>,
then import in Godot.</p>
{"".join(sections)}
</main>
<script>
function join(btn) {{
  const a = btn.closest('.track').querySelector('audio');
  const go = () => {{ a.loop = true; a.currentTime = Math.max(0, a.duration - 5); a.play(); }};
  if (isNaN(a.duration)) {{ a.preload = 'auto'; a.addEventListener('loadedmetadata', go, {{ once: true }}); a.load(); }}
  else go();
}}
// One track at a time.
document.addEventListener('play', e => document.querySelectorAll('audio').forEach(x => {{ if (x !== e.target) x.pause(); }}), true);
</script></body></html>""", encoding="utf-8")
    print(f"wrote {OUT}")


if __name__ == "__main__":
    main()

"""Put chosen loops into the game.

    python tools/music_promote.py <track> <candidate> [<track> <candidate> ...]

Candidates are cut into .build/music-candidates/ first, two takes per prompt:

    python tools/music_loop.py <download.mp3> berlin_b --suno <id> --dir .build/music-candidates

Listening and the numbers music_loop.py records (loop length, how alike the
join is, how steady the level is) decide which take becomes the track. This
copies it to audio/music/<track>.ogg and records it, with the take it came
from, in audio/music/music.json. The prompt behind every track is in
tools/music_prompts.json.
"""
from __future__ import annotations

import json
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CANDIDATES = ROOT / ".build/music-candidates"
GAME = ROOT / "audio/music"


def main(args: list[str]) -> None:
    if not args or len(args) % 2:
        raise SystemExit(__doc__)
    cand = json.loads((CANDIDATES / "music.json").read_text(encoding="utf-8"))
    game_path = GAME / "music.json"
    game = json.loads(game_path.read_text(encoding="utf-8"))
    for track, take in zip(args[::2], args[1::2]):
        if take not in cand:
            raise SystemExit(f"no candidate called {take} in {CANDIDATES}")
        shutil.copyfile(CANDIDATES / f"{take}.ogg", GAME / f"{track}.ogg")
        game[track] = {**cand[take], "file": f"res://audio/music/{track}.ogg", "chosen_from": take}
        print(f"{track} <- {take}")
    game_path.write_text(json.dumps(game, indent=2, ensure_ascii=False), encoding="utf-8")
    print("game tracks:", ", ".join(sorted(game)))


if __name__ == "__main__":
    main(sys.argv[1:])

# -*- coding: utf-8 -*-
"""Every door should have a way back through itself.

Entering a building puts the player at the door that leads back where they came
from -- GameState.place_at_return_door walks the destination's children looking
for one whose target_scene is the scene just left. When there isn't one, the
player lands on the destination's fixed `spawn` export instead, which is
usually nowhere near the door they just walked through.

So: for every exit A -> B, B must contain an exit back to A. This finds the
ones that do not, which is exactly the set of doors that spawn you in the wrong
place.

Three answers count as a way back:

  * a door that names the scene;
  * a door marked `is_return = true`, which goes wherever the player came in
    from -- a hub with one staircase serving four districts cannot name them
    all and should not try;
  * being a room with exactly one door, because then there is only one answer
    and place_at_return_door takes it.

A scene with no SceneExit children at all draws its doors in code (the hotel
corridor builds one per room), so it is out of scope here.
"""
import io
import os
import re
import sys

NL = chr(10)
W = "scenes/world/"
Q = chr(34)

NODE = re.compile(r'\[node name="([^"]+)"[^\]]*\]')
TARGET = re.compile(r'^target_scene = "([^"]+)"', re.M)


def exits_of(path):
    """[(node_name, target_scene)] for every SceneExit-ish child."""
    raw = io.open(path, encoding="utf-8").read()
    out = []
    blocks = raw.split(NL + "[node ")
    for b in blocks[1:]:
        head = b.split("]", 1)[0]
        m = re.match(r'name="([^"]+)"', head)
        if not m:
            continue
        body = b.split("]", 1)[1] if "]" in b else ""
        t = TARGET.search(body)
        if t:
            out.append((m.group(1), t.group(1)))
    return out


def main():
    scenes = sorted(f for f in os.listdir(W) if f.endswith(".tscn"))
    table = {}
    returns = {}
    for f in scenes:
        key = "res://" + W + f
        table[key] = exits_of(W + f)
        returns[key] = "is_return = true" in io.open(W + f, encoding="utf-8").read()

    bad = []
    for src, doors in sorted(table.items()):
        for name, dest in doors:
            if dest not in table:
                bad.append((src, name, dest, "destination scene not found"))
                continue
            if returns.get(dest):
                continue
            if len(table[dest]) <= 1:
                continue
            back = [d for _, d in table[dest] if d == src]
            if not back:
                bad.append((src, name, dest, "no door back"))

    print("Foreign to All \u2014 door check")
    print("  %d scenes, %d doors"
          % (len(table), sum(len(v) for v in table.values())))
    print()
    if not bad:
        print("  CLEAN")
        return 0
    for src, name, dest, why in bad:
        print("  %-44s %-22s -> %-44s %s"
              % (src.replace("res://" + W, ""), name,
                 dest.replace("res://" + W, ""), why))
    print()
    print("  %d PROBLEMS" % len(bad))
    return 1


if __name__ == "__main__":
    sys.exit(main())

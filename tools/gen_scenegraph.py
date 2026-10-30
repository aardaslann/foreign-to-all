# -*- coding: utf-8 -*-
"""Write autoload/SceneGraph.gd from the doors that actually exist.

The quest arrow has to answer "which way from here?" across a world of two
hundred scenes. Parsing .tscn at runtime to find out is far too slow, and a
hand-written map of a hundred districts would be wrong within a week -- the
door check already exists precisely because doors drift.

So the graph is generated from the same source of truth the game loads: every
SceneExit in every scene, with the position of the door, so the arrow can point
at the doorway rather than merely in its general direction.

    python tools/gen_scenegraph.py

Doors built in code rather than placed in a scene -- the hotel corridor makes
one per room -- are not here, and cannot be: they do not exist until the scene
runs. Those floors are leaves anyway.
"""
import io
import os
import re
import sys
import json
from pathlib import Path

NL = chr(10)
Q = chr(34)
WORLD = "scenes/world/"
OUT = "scenes/world/SceneGraph.gd"

TARGET = re.compile(r'^target_scene = "([^"]+)"', re.M)
POS = re.compile(r'^position = Vector2\(([-0-9.]+), ([-0-9.]+)\)', re.M)
RETURN = re.compile(r'^is_return = true', re.M)
SERVICE = re.compile(r'^service = "([^"]+)"', re.M)


def doors_of(path):
    """[(target_scene, x, y)] for every placed SceneExit in one scene."""
    raw = io.open(path, encoding="utf-8").read()
    out = []
    for b in raw.split(NL + "[node ")[1:]:
        if "]" not in b:
            continue
        body = b.split("]", 1)[1]
        t = TARGET.search(body)
        if not t or RETURN.search(body):
            continue
        p = POS.search(body)
        x, y = (float(p.group(1)), float(p.group(2))) if p else (0.0, 0.0)
        out.append((t.group(1), x, y))
    # Activity entrances keep the existing LocalSpot's authored street anchor;
    # ServicePoint exposes their destination at runtime rather than in .tscn.
    catalog_path = Path('art/environments/activity-world.json')
    if catalog_path.exists():
        entries = json.loads(catalog_path.read_text(encoding='utf-8')).get('entries', {})
        res = 'res://' + str(path).replace('\\', '/')
        for name, entry in entries.get(res, {}).items():
            at = entry.get('at')
            if at is None:
                scene = Path(path).stem
                for source in ['berlin-gameplay', 'istanbul-gameplay', 'city-gameplay']:
                    layouts = json.loads(Path('art/environments/' + source + '.json').read_text(encoding='utf-8'))
                    at = layouts.get(scene, {}).get('anchors', {}).get(name, at)
            if at is None:
                raise ValueError(f'Missing activity entrance anchor: {res} {name}')
            out.append(('res://scenes/world/activities/' + entry['place'] + '.tscn', *at))
    return out


def platform_of(path):
    """Where the U-Bahn platform stands in a transit hall, or None.

    Districts in a city are not joined by doors at all -- every hall has one
    exit and it is marked is_return, so the generated graph came out as
    twenty disconnected stars and an arrow could not route from one district
    to its neighbour. What joins them is a ServicePoint running ubahn_travel,
    which is a ride rather than a doorway. It is an edge all the same, and
    the position the arrow should point at is the platform.
    """
    raw = io.open(path, encoding="utf-8").read()
    for b in raw.split(NL + "[node ")[1:]:
        if "]" not in b:
            continue
        body = b.split("]", 1)[1]
        m = SERVICE.search(body)
        if not m or m.group(1) != "ubahn_travel":
            continue
        p = POS.search(body)
        return (float(p.group(1)), float(p.group(2))) if p else (0.0, 0.0)
    return None


def main():
    rows = []
    total = 0
    for path in sorted(Path(WORLD).rglob('*.tscn')):
        doors = doors_of(path)
        if not doors:
            continue
        res = "res://" + path.as_posix()
        items = []
        for tgt, x, y in doors:
            items.append("[%s%s%s, Vector2(%.1f, %.1f)]" % (Q, tgt, Q, x, y))
            total += 1
        rows.append('\t"%s": [%s],' % (res, ", ".join(items)))

    # Which districts feed each hall, so the hall knows where it can send you.
    halls = {}
    for name in sorted(os.listdir(WORLD)):
        if not name.endswith(".tscn"):
            continue
        pos = platform_of(WORLD + name)
        if pos is not None:
            halls["res://" + WORLD + name] = [pos, []]
    for name in sorted(os.listdir(WORLD)):
        if not name.endswith(".tscn"):
            continue
        me = "res://" + WORLD + name
        for tgt, _x, _y in doors_of(WORLD + name):
            if tgt in halls and me not in halls[tgt][1]:
                halls[tgt][1].append(me)

    trows = []
    rides = 0
    for hall in sorted(halls):
        pos, dests = halls[hall]
        if not dests:
            continue
        rides += len(dests)
        trows.append('	"%s": [Vector2(%.1f, %.1f), [%s]],'
                     % (hall, pos[0], pos[1],
                        ", ".join(Q + d + Q for d in sorted(dests))))

    body = io.open("tools/gen_scenegraph.head", encoding="utf-8").read()
    body += "const DOORS := {" + NL + NL.join(rows) + NL + "}" + NL
    body += NL + NL
    body += ("# A transit hall and everywhere it can put you down, with the" + NL
             + "# platform's position -- what the arrow points at inside a hall." + NL)
    body += "const TRANSIT := {" + NL + NL.join(trows) + NL + "}" + NL
    body += io.open("tools/gen_scenegraph.tail", encoding="utf-8").read()
    io.open(OUT, "w", encoding="utf-8", newline=NL).write(body)
    print("wrote %s  --  %d scenes, %d doors, %d halls, %d rides"
          % (OUT, len(rows), total, len(trows), rides))
    return 0


if __name__ == "__main__":
    sys.exit(main())

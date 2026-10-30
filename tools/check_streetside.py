# -*- coding: utf-8 -*-
"""Walk every streetside beat graph and prove it cannot dead-end.

The engine reads this data at runtime and a bad link fails silently: the panel
closes and the district looks broken for no stated reason. Nothing else in the
suite can see it, because it is data, not code.

Per spot:
    start / again name a beat that exists
    every row "to" is "" or names a beat that exists
    every row "needs" names a beat that exists
    every "toss" target exists
    every beat is reachable from start
    every beat has rows or a toss, so nothing dead-ends

Parsed by slicing between beat headers rather than by matching braces: a
one-line beat has no closing brace on a line of its own, and any non-greedy
match swallows the beat after it.
"""
import io
import os
import sys

NL = chr(10)
T = chr(9)
Q = chr(34)
W = "scenes/world/"
FILES = ["StreetsideWest.gd", "StreetsideNorth.gd", "StreetsideSouth.gd",
         "StreetsideNorthWest.gd", "StreetsideEastTwo.gd",
         "StreetsideSouthTwo.gd",
         "StreetsideEuropeTwo.gd",
         "StreetsideAmerica.gd",
         "StreetsideEast.gd", "StreetsidePacific.gd"]

SPOT_HEAD = NL + Q
BEAT_HEAD = NL + T + T + Q


def _ids_between(raw, opener, closer):
    """Every quoted id inside each opener..closer run."""
    out = []
    at = 0
    while True:
        i = raw.find(opener, at)
        if i < 0:
            return out
        j = raw.find(closer, i)
        if j < 0:
            return out
        chunk = raw[i + len(opener):j]
        parts = chunk.split(Q)
        out += [p for p in parts[1::2]]
        at = j
    return out


def _values(raw, field):
    """Every value of a "field": "value" pair."""
    out = []
    key = Q + field + Q + ": " + Q
    at = 0
    while True:
        i = raw.find(key, at)
        if i < 0:
            return out
        i += len(key)
        j = raw.find(Q, i)
        if j < 0:
            return out
        out.append(raw[i:j])
        at = j
    return out


def _slices(text, head, depth):
    """id -> body, for every block header at this indent depth."""
    heads = []
    at = 0
    while True:
        i = text.find(head, at)
        if i < 0:
            break
        start = i + len(head)
        j = text.find(Q, start)
        name = text[start:j]
        rest = text[j + 1:j + 4]
        if rest.startswith(": {"):
            heads.append((name, j + 4))
        at = j + 1
    out = {}
    for n, (name, body_at) in enumerate(heads):
        end = len(text)
        if n + 1 < len(heads):
            end = heads[n + 1][1] - len(head) - len(name) - 4
        out[name] = text[body_at:end]
    return out


def main():
    bad = []
    n_spots = 0
    n_beats = 0
    for f in FILES:
        p = W + f
        if not os.path.exists(p):
            bad.append(f + ": missing")
            continue
        text = io.open(p, encoding="utf-8").read()
        for key, body in _slices(text, SPOT_HEAD, 0).items():
            if ":" not in key:
                continue
            n_spots += 1
            bs = _slices(body, BEAT_HEAD, 2)
            n_beats += len(bs)
            if not bs:
                bad.append(key + ": no beats")
                continue
            starts = _values(body, "start")
            if not starts:
                bad.append(key + ": no start")
                continue
            for field in ["start", "again"]:
                for v in _values(body, field):
                    if v not in bs:
                        bad.append("%s: %s -> %s, which does not exist"
                                   % (key, field, v))
            reached = set()
            queue = [starts[0]]
            while queue:
                at = queue.pop()
                if at in reached or at not in bs:
                    continue
                reached.add(at)
                raw = bs[at]
                outs = [v for v in _values(raw, "to") if v]
                outs += _ids_between(raw, Q + "toss" + Q + ": [", "]")
                for t in outs:
                    if t not in bs:
                        bad.append("%s/%s: -> %s, which does not exist"
                                   % (key, at, t))
                    else:
                        queue.append(t)
                for need in _values(raw, "needs"):
                    if need not in bs:
                        bad.append("%s/%s: needs %s, which does not exist"
                                   % (key, at, need))
                if Q + "rows" + Q not in raw and Q + "toss" + Q not in raw:
                    bad.append("%s/%s: no rows and no toss - dead end" % (key, at))
            for b in bs:
                if b not in reached:
                    bad.append("%s/%s: unreachable from start" % (key, b))

    print("Foreign to All - streetside check")
    print("  %d spots, %d beats" % (n_spots, n_beats))
    if bad:
        print("")
        for b in bad:
            print("   " + b)
        print("")
        print("  %d PROBLEM(S)" % len(bad))
        return 1
    print("")
    print("  CLEAN")
    return 0


if __name__ == "__main__":
    sys.exit(main())

# -*- coding: utf-8 -*-
"""Does the picture show what the sentence says?

Every shot in a cutscene is a line of the alien's narration plus a set and a
handful of poses. Those three can disagree, and when they do the player is
told one thing and shown another -- a line about lying on the grass over a
pavement, a line about a streetcar with no streetcar in frame.

This reads every shot in the streetside data and reports where the words ask
for something the staging does not provide. It is deliberately literal: it
only fires on words that name a posture, an object or a place outright.
"""
import io
import os
import re
import sys

NL = chr(10)
W = "scenes/world/"
FILES = [f for f in sorted(os.listdir(W))
         if f.startswith("Streetside") and f.endswith(".gd")
         and f != "Streetside.gd"]

SIT = ["sit", "kneel"]

# word in the line  ->  what the cast or the set has to contain
POSE_RULES = [
    # People, not objects: a brick dome sitting flat on the ground is not
    # a posture, and a hotel standing on sand is not a stance.
    (r"\b(they are sitting|is sitting|are sitting|sat down|sit down|sitting on the|sitting on their|lying on the|lie on the)\b", "cast", SIT, "somebody seated"),
    (r"\bpoints? (at|to)\b", "cast", ["point"], "a pointing hand"),
    (r"\b(bows|bowing|bends at the waist)\b", "cast", ["bow"], "a bow"),
    (r"\b(carries|carrying|on (his|her|somebody’s) head|on somebody's head)\b", "cast", ["carry", "haul", "lift"], "somebody carrying"),
    # "It is not a queue" is a sentence about there being no queue.
    (r"\b(a queue|the queue|queuing)\b", "cast", ["queue"], "a queue"),
    (r"\b(hands? (it |them )?(over|back)|holds it out|gives me)\b", "cast", ["hand_over", "offer", "take", "reach"], "a hand-over"),
]

SET_RULES = [
    (r"\b(grass|lawn)\b", ["park", "field"], "grass"),
    (r"\b(streetcar|tram|metro|underground|the train|the platform|the stop)\b", ["station", "platform", "interior", "tram"], "a platform or a car"),
    (r"\b(counter|till|behind the glass)\b", ["counter", "shop"], "a counter"),
    # A market named in a list of what is in a square is scenery.
    (r"\b(a stall|the stall|a trestle|the trestle|stalls|the market)\b", ["market", "stall"], "a stall"),
    (r"\b(sand|beach|shorebreak)\b", ["beach"], "sand"),
    # A waterfront, not a drinking fountain.
    (r"\b(off the boat|along the canal|along the quay|the ferry|between me and the water)\b", ["water", "beach"], "water"),
    (r"\b(on (the|their|his|her) (front )?steps|up the steps|down the steps)\b", ["steps"], "steps"),
    (r"\b(courtyard)\b", ["courtyard"], "a courtyard"),
]

def shots_in(raw):
    """Yield (set, [acts], say) for every film shot in a table."""
    out = []
    at = 0
    key = chr(34) + 'set' + chr(34) + ': ' + chr(34)
    while True:
        i = raw.find('{' + key, at)
        if i < 0:
            return out
        j = raw.find('}', raw.find(chr(34) + 'say' + chr(34), i))
        if j < 0:
            return out
        body = raw[i:j + 1]
        at = j
        m_set = re.search(r'.set.: .([a-z_+]+).', body)
        m_say = re.search(r'.say.: .(.*)$', body, re.S)
        if m_set is None or m_say is None:
            continue
        say = m_say.group(1).rstrip()
        if say.endswith('}'):
            say = say[:-1]
        say = say.rstrip().rstrip(chr(34))
        out.append((m_set.group(1), ACT.findall(body), say, raw[:i].count(NL) + 1))


ACT = re.compile(r'"act": "([a-z_]+)"')


def main():
    total = 0
    bad = []
    for f in FILES:
        raw = io.open(W + f, encoding="utf-8").read()
        for kind, acts, line, ln in shots_in(raw):
            total += 1
            low = line.lower()
            where = "%s:%d" % (f.replace("Streetside", "").replace(".gd", ""),
                               ln)
            for pat, field, need, what in POSE_RULES:
                if not re.search(pat, low):
                    continue
                # "It is not a queue" is a sentence about there being no queue.
                if re.search(r"not a (queue|party|line)", low):
                    continue
                if field == "cast" and not any(a in need for a in acts):
                    bad.append((where, what, kind, ",".join(acts), line))
            parts = kind.split("+")
            for pat, need_sets, what in SET_RULES:
                if not re.search(pat, low):
                    continue
                if not any(p in need_sets for p in parts):
                    bad.append((where, what, kind, ",".join(acts), line))

    print("Foreign to All \u2014 film check")
    print("  %d shots" % total)
    print()
    if not bad:
        print("  CLEAN")
        return 0
    for where, what, kind, acts, line in bad:
        print("  %-22s wants %-22s set=%-10s acts=%s" % (where, what, kind, acts))
        print("      %s" % line[:104])
    print()
    print("  %d MISMATCHES" % len(bad))
    return 1


if __name__ == "__main__":
    sys.exit(main())

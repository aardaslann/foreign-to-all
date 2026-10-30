# -*- coding: utf-8 -*-
"""A person's silhouette should match the age their roster entry states.

CharacterArt draws four builds - child, youth, adult, elder - and build is the
only thing that changes a figure's height and posture. An elder is drawn
stooped, so a brisk fifty-five-year-old marked `elder` is not a stylistic
choice, it is the game contradicting its own character note.

The parser is deliberately fussy about what counts as an age, because the
naive version flagged four people who were fine: "nine hundred people",
"nine languages", and "newsagent, fifties. Came here at nineteen" - where the
age is the decade, not the year of arrival.

    python tools/check_npcs.py
"""
import io
import os
import re
import sys

NPC_DIR = "scenes/npc"
WORLD = "scenes/world"

DECADES = {"twenties": 25, "thirties": 35, "forties": 45, "fifties": 55,
           "sixties": 65, "seventies": 75, "eighties": 85}
TENS = {"twenty": 20, "thirty": 30, "forty": 40, "fifty": 50,
        "sixty": 60, "seventy": 70, "eighty": 80}
ONES = {"one": 1, "two": 2, "three": 3, "four": 4, "five": 5,
        "six": 6, "seven": 7, "eight": 8, "nine": 9}
TEENS = {"nine": 9, "ten": 10, "eleven": 11, "twelve": 12, "thirteen": 13,
         "fourteen": 14, "fifteen": 15, "sixteen": 16, "seventeen": 17,
         "eighteen": 18, "nineteen": 19}
# a number followed by one of these is counting something, not an age
COUNTING = ("hundred", "thousand", "languages", "things", "people", "years",
            "streets", "sentences", "glasses", "kinds", "times")


def age_from(role):
    low = role.lower()
    for word, a in DECADES.items():
        if re.search(r"\b" + word + r"\b", low):
            return a
    m = re.search(r"\b(" + "|".join(TENS) + r")[- ](" + "|".join(ONES) + r")\b", low)
    if m:
        return TENS[m.group(1)] + ONES[m.group(2)]
    for word, a in sorted(TEENS.items(), key=lambda kv: -len(kv[0])):
        for m2 in re.finditer(r"\b" + word + r"\b", low):
            after = low[m2.end():m2.end() + 14].strip()
            before = low[max(0, m2.start() - 10):m2.start()]
            if any(after.startswith(c) for c in COUNTING):
                continue
            if before.rstrip().endswith("at"):
                continue          # "came here at nineteen" is not their age
            return a
    return None


def want(age):
    if age < 14:
        return "child"
    if age < 25:
        # "youth" is drawn lanky, weight on one leg: a late-teens read. Past
        # the mid-twenties that silhouette stops being true of anybody.
        return "youth"
    if age >= 62:
        return "elder"
    return "adult"


def main():
    ages = {}
    for name in sorted(os.listdir(NPC_DIR)):
        if not name.startswith("CityNPCs") or not name.endswith(".gd"):
            continue
        src = io.open(os.path.join(NPC_DIR, name), encoding="utf-8").read()
        for m in re.finditer(
                r'"([a-z_]+)": \{\s*\n\s*"name": "[^"]+", "region"[^\n]*\n\s*"role": "([^"]*)"',
                src):
            a = age_from(m.group(2))
            if a is not None:
                ages[m.group(1)] = a

    issues = []
    checked = 0
    for name in sorted(os.listdir(WORLD)):
        if not name.endswith(".tscn"):
            continue
        src = io.open(os.path.join(WORLD, name), encoding="utf-8").read()
        for m in re.finditer(r'npc_id = "([a-z_]+)"', src):
            nid = m.group(1)
            if nid not in ages:
                continue
            checked += 1
            blk = src[m.start():m.start() + 260]
            bm = re.search(r'build = "([a-z]+)"', blk)
            build = bm.group(1) if bm else "adult"
            ok = want(ages[nid])
            if build != ok:
                issues.append("  %s: %s is %d, drawn as %s, should be %s"
                              % (name, nid, ages[nid], build, ok))

    print("Foreign to All - character build check")
    print("  %d roster ages, %d placed people" % (len(ages), checked))
    print("")
    if issues:
        print("  %d issue(s):" % len(issues))
        print("\n".join(issues))
        return 1
    print("  CLEAN")
    return 0


if __name__ == "__main__":
    sys.exit(main())

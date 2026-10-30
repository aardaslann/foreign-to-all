# -*- coding: utf-8 -*-
"""Does every person the prose names actually exist in the game?

The fault this exists for: the London staying ending -- one of the last
things a player ever reads -- said "Bev says one full sentence at full speed
about the weather, and I get all of it". Bev was London's key character in
the design that the eight-and-a-name storyline replaced on 2026-08-29. That
pass swapped her for Nadia and never came back for the endings, so the most
emotionally loaded line in the city named somebody the player had never met,
could not meet, and would never find. The caff woman is Dot, 71.

Nothing could catch it. It is not a compile error, it is not a broken link,
and a render of the ending screen looks perfect -- it is a correctly spelt,
correctly typeset sentence about a person who is not there.

How it works, without a dictionary and without a hand-written ignore list of
every capitalised word in the game:

  1. A word that appears LOWERCASE anywhere in the game's own strings is an
     ordinary word. "The", "When", "Every" all fall out for free.
  2. What is left is proper nouns. Those are checked against everybody the
     game actually knows: the NPC rosters, the eight, the encounter people,
     the cities, the districts and the names you can be given.
  3. Days, months and the handful of foreign common nouns the prose uses
     untranslated are listed below, because there is nowhere else to read
     them from.

Run:  python tools/check_names.py
"""
import io
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Where people are declared.
ROSTERS = [
    "scenes/npc/CityNPCs.gd", "scenes/npc/CityNPCsWorld.gd",
    "scenes/npc/CityNPCsAmerica.gd", "scenes/npc/Encounters.gd",
    "autoload/Story.gd", "scenes/npc/NPC.gd", "autoload/Services.gd",
]

# Where prose the player reads is written.
PROSE = [
    "scenes/world/WreckSite.gd", "scenes/ui/Naming.gd",
    "scenes/npc/KeyLines.gd", "scenes/npc/Encounters.gd",
]

# Not people, and not readable from anywhere else in the tree.
CALENDAR = set("""Monday Tuesday Wednesday Thursday Friday Saturday Sunday
January February March April May June July August September October November
December""".split())

# Dead, and deliberately so. The Bonfire Night reel turns on the alien asking
# who Guy Fawkes was and nobody within earshot being able to do better than
# "he tried to blow up Parliament, I fink" - so he is named, he acts, and he
# is correctly not somebody the player can go and meet.
HISTORICAL = set("Fawkes Guy".split())

# Words the prose deliberately leaves in another language. Each one is a thing
# rather than a person, and each one is taught by the game somewhere.
FOREIGN = set("""Anmeldung Pfand Spati Wiesn Boogg Sonntagsruhe Hochdeutsch
Hochdutsch Sechselauten Zunft Zunfte Grossmunster Oktoberfest Maslenitsa
Tanabata Bayrami Ramazan Ganesh Chaturthi Muertos Dia Juillet Bonfire
Night""".split())


# What a person does. A name in front of one of these is somebody the player
# is expected to know, which means somebody the player must be able to meet.
VERBS = (r"(?:says?|said|tells?|told|asks?|asked|explains?|explained|calls?"
         r"|called|hands?|handed|gives?|gave|takes?|took|puts?|points?"
         r"|pointed|nods?|nodded|laughs?|laughed|shrugs?|shrugged|walks?"
         r"|walked|stands?|stood|watches|watched|comes?|came|goes|went"
         r"|switches|switched|wears?|wore|is|was|has|had|does|did|will"
         r"|would|never|always)")


def read(rel):
    p = os.path.join(ROOT, rel)
    if not os.path.exists(p):
        return ""
    return io.open(p, encoding="utf-8").read()


def strings_in(src):
    """Every double-quoted literal, which is where prose lives."""
    return re.findall(r'"([^"\\]*(?:\\.[^"\\]*)*)"', src)


def _add(bag, text):
    for part in re.split(r"[\s,]+", text):
        part = part.strip(u",.'’")
        if part:
            bag.add(part)


def main():
    # -- 1. Everybody and everywhere the game knows -----------------------
    known = set()
    for rel in ROSTERS:
        src = read(rel)
        for n in re.findall(r'"name": "([^"]+)"', src):
            _add(known, n)
        for n in re.findall(r'"(?:who|title|relationship|gives)": "([^"]+)"', src):
            _add(known, n)

    gs = read("autoload/GameState.gd")
    for n in re.findall(r'"(?:name|country)": "([^"]+)"', gs):
        _add(known, n)
    m = re.search(r"const DISTRICT_NAMES := \{(.*?)\n\}", gs, re.S)
    if m:
        for n in re.findall(r'"([^"]+)"', m.group(1)):
            _add(known, n)
    # Story names holidays, trades and places in its own fields.
    for n in re.findall(r'"(?:holiday|when|trade|region)": "([^"]+)"',
                        read("autoload/Story.gd")):
        _add(known, n)
    known |= CALENDAR | FOREIGN | HISTORICAL

    # -- 2. Any word the game ever uses in lower case is ordinary ---------
    ordinary = set()
    for base, dirs, files in os.walk(ROOT):
        dirs[:] = [d for d in dirs if not d.startswith(".")]
        for f in files:
            if not f.endswith(".gd"):
                continue
            rel = os.path.relpath(os.path.join(base, f), ROOT)
            for s in strings_in(read(rel.replace(os.sep, "/"))):
                for w in re.findall(r"\b([a-z][a-z]{2,})\b", s):
                    ordinary.add(w[:1].upper() + w[1:])

    # -- 3. Somebody DOING something. That is the invariant --------------
    #
    # Flagging every proper noun in the prose is useless: this game is made
    # of them, and Bayern, Girgaum Chowpatty, Kappabashi-dori and Orihime
    # are all correct and all belong exactly where they are. What must never
    # appear is a person ACTING - and that is a grammatical shape rather
    # than a vocabulary, so it can be matched without listing places.
    #
    # "Bev says one full sentence" matches. "Petals laid in a line" does
    # not, because petals are not doing it to anybody.
    ghosts = []
    for rel in PROSE:
        for s in strings_in(read(rel)):
            if len(s) < 25:
                continue
            for w in re.findall(r"\b([A-Z][a-z][a-z]+) " + VERBS + r"\b", s):
                if w in ordinary or w in known:
                    continue
                ghosts.append((rel, w, s.strip()[:66]))

    NL = chr(10)
    sys.stdout.write(NL + "Foreign to All - everybody the prose names" + NL + NL)
    if not ghosts:
        print("  %d names known, and the prose invents none of them" % len(known))
        print("")
        print("  CLEAN")
        return 0
    seen = set()
    for rel, w, line in ghosts:
        if (rel, w) in seen:
            continue
        seen.add((rel, w))
        print("  GHOST  %-14s %s" % (w, rel))
        print("         \"%s...\"" % line)
    print("")
    print("  %d named in prose and not in the game" % len(seen))
    return 1


if __name__ == "__main__":
    sys.exit(main())

"""Can the alien say the things the game offers to let him say?

    python tools/check_options.py

A dialogue option carries up to four phrasings - gesture, words, frag, say -
and GameState.phrase_for() hands over the richest one the player's FLUENCY
allows. Fluency is a count. A count cannot tell you WHICH words, so a player
who had picked up twenty-two words of anything at all was offered

    "Bir ekmek alabilir miyim, abla?"

whether or not one of those five words had ever been said to them. This game
is about not having the words; handing them over because a counter passed
twenty-two is the one thing it must not do.

phrase_for() now skips any phrasing containing a word of the local language
that the player has neither learned nor just been told. This checks the other
half of that contract, which lives in the data rather than in the code:

  * every option must keep at least ONE phrasing a player with no vocabulary
    could still say - otherwise it falls through to `text`, which is a
    description of an action and not something anybody says out loud;
  * a word may appear in a phrasing with no lower fallback only when the NPC
    says it in the same breath, because echoing a sound back at somebody takes
    no vocabulary at all;
  * or the option declares `requires_word`, which hides it at the door instead.

What counts as a word of a language is the notebook: if Guesses has an entry
for it, it is a word this game teaches and can therefore withhold. A name, a
place or an English word is not in there and is never gated.
"""

import collections
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TIERS = ["gesture", "words", "frag", "say"]
TOKEN = re.compile(r"[A-Za-zÀ-ſ']+")

TABLE = re.compile(r"^const\s+([A-Z_0-9]+)\s*:=\s*\{", re.M)
ENTRY = re.compile(r'"words"\s*:\s*\[')
PIECE = re.compile(r'"word"\s*:\s*"([^"]*)"')
OPTION = re.compile(r'\{"(?:text|gesture|words|frag|say)"')
FIELD = re.compile(r'"(text|gesture|words|frag|say|requires_word)"\s*:\s*'
                   r'"((?:[^"\\]|\\.)*)"')


def _brace_body(src, start):
    """The text between the brace at `start` and the one that closes it."""
    depth = 0
    i = start
    while i < len(src):
        if src[i] == "{":
            depth += 1
        elif src[i] == "}":
            depth -= 1
            if depth == 0:
                return src[start + 1:i]
        i += 1
    return src[start:]


def _array_body(src, start):
    depth = 0
    i = start
    while i < len(src):
        if src[i] == "[":
            depth += 1
        elif src[i] == "]":
            depth -= 1
            if depth == 0:
                return src[start + 1:i]
        i += 1
    return src[start:]


def notebook():
    """{word: {languages}} for every word the game teaches, and the English."""
    words = collections.defaultdict(set)
    english = set()
    for name in ("Guesses.gd", "GuessesWorld.gd"):
        src = open(os.path.join(ROOT, "autoload", name),
                   encoding="utf-8").read()
        for m in TABLE.finditer(src):
            lang = m.group(1).lower()
            body = _brace_body(src, m.end() - 1)
            for km in re.finditer(r'"([^"]+)"\s*:', body):
                w = km.group(1).lower()
                if lang == "english":
                    english.add(w)
                else:
                    words[w].add(lang)
    return words, english


def options(src):
    """(line, option dict, the words the NPC just said) for every option."""
    spoken = []
    for m in ENTRY.finditer(src):
        body = _array_body(src, m.end() - 1)
        heard = set(w.lower() for w in PIECE.findall(body) if w)
        spoken.append((m.start(), heard))

    out = []
    for m in OPTION.finditer(src):
        i = m.start()
        blob = "{" + _brace_body(src, i) + "}"
        if '"word":' in blob:          # a speech piece, not an option
            continue
        row = {}
        for fm in FIELD.finditer(blob):
            row.setdefault(fm.group(1), fm.group(2))
        # An option with no phrasings at all is a pure gesture - "Bow slightly,
        # hands clasped" - and it is checked too: its description is the only
        # thing the player will ever see, so a foreign word in there is a
        # foreign word the game never asked whether he had.
        if not any(k in row for k in TIERS) and "text" not in row:
            continue
        heard = set()
        for (at, said) in spoken:
            if at < i:
                heard = said           # the nearest line before this option
        out.append((src.count("\n", 0, i) + 1, row, heard))
    return out


def sources():
    out = []
    for dirpath, _dirnames, filenames in os.walk(ROOT):
        if ".git" in dirpath:
            continue
        for fn in sorted(filenames):
            if fn.endswith(".gd"):
                out.append(os.path.join(dirpath, fn))
    return out


def ordinary_english(files, english):
    """The English the notebook also happens to spell: in, so, me, bin, war.

    Built from the game's own prose - a response DESCRIPTION is always authored
    English - and only from what recurs, because one foreign word quoted once
    inside one description must not be allowed to vouch for itself.
    """
    freq = collections.Counter()
    for path in files:
        src = open(path, encoding="utf-8", errors="replace").read()
        for m in re.finditer(r'"text"\s*:\s*"((?:[^"\\]|\\.)*)"', src):
            if '"word"' in m.group(1):
                continue
            for t in TOKEN.findall(m.group(1)):
                freq[t.lower()] += 1
    for w, n in freq.items():
        if n >= 3:
            english.add(w)
    return english


def main():
    words, english = notebook()
    files = sources()
    english = ordinary_english(files, english)

    checked = 0
    fails = 0
    thin = []
    print("")
    print("Foreign to All - what he is offered to say")
    print("")
    for path in files:
        src = open(path, encoding="utf-8", errors="replace").read()
        rel = os.path.relpath(path, ROOT).replace("\\", "/")
        for (line, row, heard) in options(src):
            checked += 1
            if row.get("requires_word"):
                continue              # gated at the door instead

            def unknown_in(key):
                out = []
                for t in TOKEN.findall(row.get(key, "")):
                    tl = t.lower()
                    if tl in english or tl in heard:
                        continue
                    if tl in words:
                        out.append(tl)
                return out

            said = [k for k in TIERS if k in row and not unknown_in(k)]
            if said:
                continue
            if not any(k in row for k in TIERS):
                # A pure gesture. There was never anything to say; its
                # description IS the option, and it was checked above.
                if "text" in row and not unknown_in("text"):
                    continue

            # No phrasing survives, so the option falls through to `text`. That
            # is allowed when `text` is clean - it is what he MEANT, and Speech
            # fills the local words into it as he learns them - but it is
            # third-person, so it is worth listing rather than passing quietly.
            if "text" in row and not unknown_in("text"):
                thin.append((rel, line, row.get("text", "")))
                continue

            fails += 1
            print(" FAIL %s:%d  nothing here he could always say" % (rel, line))
            print("       %s" % "  ".join(
                "%s(%s)" % (k, ",".join(unknown_in(k)))
                for k in TIERS if k in row))

    if thin:
        print("")
        print(" -- options that fall back to their description (%d)" % len(thin))
        for (rel, line, text) in thin:
            print("    %s:%d  %s" % (rel, line, text))

    print("")
    print("%d options, %d with nothing he could say, %d down to a description"
          % (checked, fails, len(thin)))
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())

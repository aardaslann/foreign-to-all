#!/usr/bin/env python3
"""Argument-count checks for Foreign to All.

Godot is not installed on this machine, so nothing can be run. `static_check.py`
catches calls to functions that do not exist. This catches the other half: calls
to functions that DO exist, with the wrong number of arguments.

    py tools/check_calls.py

Exit code 0 = clean, 1 = issues found.

Why this exists: the art helpers in InteriorArt/WorldArt take long positional
signatures (`counter(ci, x, y, w, h, top, face)`), and a background written from
a design note rather than from the header lands one argument out. GDScript only
reports that when the scene is instanced, which on this project means never,
because nothing has ever been run. Four such calls were written and caught on
the day this file was added.

Covers:
  * calls into any `class_name` static API (InteriorArt, WorldArt, CityNPCs),
    through either the class name or a `const XX := ClassName` alias
  * self-calls to funcs defined in the same script
Optional parameters (`= default`) widen the accepted range.
"""

import glob
import io
import os
import re
import sys

CALL = re.compile(r"\b([A-Za-z_][A-Za-z0-9_]*)\.([a-z_][A-Za-z0-9_]*)\s*\(")
SELF_CALL = re.compile(r"(?<![\w.])(_?[a-z][A-Za-z0-9_]*)\s*\(")

# Autoloads and built-ins: not static APIs, and not our arity problem.
SKIP_RECEIVERS = {
    "GameState", "SaveManager", "AudioManager", "TransitionManager", "UIStyles",
    "Services", "DevConsole", "self",
}


def gd_files():
    out = []
    for pat in ("autoload/**/*.gd", "scenes/**/*.gd", "tools/**/*.gd"):
        out += glob.glob(pat, recursive=True)
    return sorted(out)


def _split_params(text, open_idx):
    """Return the parameter source strings for a `(` at open_idx."""
    i, depth, params, buf = open_idx + 1, 1, [], ""
    quote = ""
    while i < len(text) and depth:
        c = text[i]
        if quote:
            # Inside a literal nothing counts, and a backslash eats the next
            # character. Commas in dialogue are the reason this exists.
            buf += c
            if c == "\\":
                if i + 1 < len(text):
                    buf += text[i + 1]
                    i += 2
                    continue
            elif c == quote:
                quote = ""
            i += 1
            continue
        if c in "\"'":
            quote = c
            buf += c
            i += 1
            continue
        if c in "([{":
            depth += 1
        elif c in ")]}":
            depth -= 1
            if depth == 0:
                break
        if depth == 1 and c == ",":
            params.append(buf)
            buf = ""
        else:
            buf += c
        i += 1
    if buf.strip():
        params.append(buf)
    return params


def parse_funcs(text):
    """name -> (min_args, max_args), counting the receiver for static helpers."""
    out = {}
    for m in re.finditer(r"^\s*(static\s+)?func\s+(\w+)\s*\(", text, re.M):
        params = _split_params(text, m.end() - 1)
        real = [p for p in params if p.strip()]
        opt = len([p for p in real if "=" in p])
        out[m.group(2)] = (len(real) - opt, len(real))
    return out


def count_args(text, open_idx):
    args = _split_params(text, open_idx)
    return len([a for a in args if a.strip()])


def line_starts(text):
    starts, n = [], 0
    for line in text.split("\n"):
        starts.append(n)
        n += len(line) + 1
    return starts


def main():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    os.chdir(root)

    files = gd_files()
    apis = {}
    for path in files:
        text = io.open(path, encoding="utf-8", errors="replace").read()
        cn = re.search(r"^class_name\s+(\w+)", text, re.M)
        if cn:
            apis[cn.group(1)] = parse_funcs(text)

    issues = []
    for path in files:
        text = io.open(path, encoding="utf-8", errors="replace").read()
        local = parse_funcs(text)
        alias = {}
        # `const IA := preload("res://.../InteriorArt.gd")` is the form this
        # codebase uses; a bare `const IA := InteriorArt` does not parse in
        # Godot 4 and static_check now rejects it outright.
        for m in re.finditer(r"^const\s+(\w+)\s*:=\s*preload\(\s*[\"']"
                             r"res://[^\"']*?(\w+)\.gd", text, re.M):
            if m.group(2) in apis:
                alias[m.group(1)] = m.group(2)
        for m in re.finditer(r"^const\s+(\w+)\s*:=\s*(\w+)\s*$", text, re.M):
            if m.group(2) in apis:
                alias[m.group(1)] = m.group(2)

        lines = text.split("\n")
        starts = line_starts(text)
        for ln, line in enumerate(lines, 1):
            if line.strip().startswith("#"):
                continue
            for m in CALL.finditer(line):
                recv, fn = m.group(1), m.group(2)
                if recv in SKIP_RECEIVERS:
                    continue
                cls = alias.get(recv) or (recv if recv in apis else None)
                if cls is None:
                    continue
                # .new() is on every GDScript ever loaded, declared or not, and
                # preload(...).new() is how this project reaches a class whose
                # class_name the editor's cache has not registered. Reporting
                # it as undefined is the checker being wrong about the engine.
                if fn in ("new", "duplicate", "instantiate"):
                    continue
                idx = starts[ln - 1] + m.end() - 1
                if fn not in apis[cls]:
                    issues.append("%s:%d  %s.%s() is not defined on %s"
                                  % (path, ln, recv, fn, cls))
                    continue
                got = count_args(text, idx)
                lo, hi = apis[cls][fn]
                if not (lo <= got <= hi):
                    issues.append("%s:%d  %s.%s() got %d args, expects %d-%d"
                                  % (path, ln, recv, fn, got, lo, hi))
            for m in SELF_CALL.finditer(line):
                fn = m.group(1)
                if fn not in local:
                    continue
                before = line[:m.start()].rstrip()
                if before.endswith(".") or before.endswith("func"):
                    continue
                idx = starts[ln - 1] + m.end() - 1
                got = count_args(text, idx)
                lo, hi = local[fn]
                if not (lo <= got <= hi):
                    issues.append("%s:%d  %s() got %d args, expects %d-%d"
                                  % (path, ln, fn, got, lo, hi))

    print("Foreign to All - call arity check")
    print("  %d scripts, %d class_name APIs" % (len(files), len(apis)))
    if not issues:
        print("\n  CLEAN")
        return 0
    print("\n  %d issue(s):\n" % len(issues))
    for i in sorted(set(issues)):
        print("   " + i)
    return 1


if __name__ == "__main__":
    sys.exit(main())

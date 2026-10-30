# -*- coding: utf-8 -*-
"""Every member a script reaches for through a NAME has to exist.

check_calls.py only knew about class_name APIs, so GameState.has_item() could
be missing while five services called it - and the Fundbuero, the police desk,
the hospital and Yusuf's shop all crashed outright the moment you spoke to
them. Nothing in the build said a word, because an autoload is reached by name
and GDScript resolves that at runtime.

Two kinds of name have that hole, and both are all over this project:

  * AUTOLOADS, read from project.godot
  * PRELOADED MODULES - `const CHAR := preload("res://.../CharacterArt.gd")` -
    which is how every script here reaches a non-class_name module, because
    the global class cache is the editor's and every tool runs headless. A
    typo in CHAR.draw_figur() is a runtime error in exactly the same way.

    python tools/check_autoloads.py
"""
import io
import os
import re
import sys

MEMBER = re.compile(r"^(?:@export\s+)?(?:static\s+)?"
                    r"(?:func|var|const|signal)\s+([A-Za-z_]\w*)", re.M)


def autoloads():
    """name -> the set of things it declares, read from project.godot."""
    out = {}
    cfg = io.open("project.godot", encoding="utf-8").read()
    for m in re.finditer(r'^([A-Za-z_]\w*)="\*?res://([^"]+)"', cfg, re.M):
        name, path = m.group(1), m.group(2)
        if not os.path.exists(path):
            continue
        out[name] = set(MEMBER.findall(io.open(path, encoding="utf-8").read()))
    return out


PRELOAD = re.compile(
    r'^[ 	]*const[ 	]+([A-Z][A-Z0-9_]*)[ 	]*:?=[ 	]*'
    r'preload\([ 	]*"(res://[^"]+\.gd)"', re.M)

# Reached through the base class, not declared in the file itself.
INHERITED = ("new", "call", "get", "set", "instantiate", "resource_path",
             "has_method", "bind", "duplicate", "call_deferred")


def members_of(path, cache):
    """What a script file declares, read once."""
    if path not in cache:
        if not os.path.exists(path):
            cache[path] = None
        else:
            src = io.open(path, encoding="utf-8").read()
            cache[path] = set(MEMBER.findall(src))
    return cache[path]


def main():
    known = autoloads()
    if not known:
        print("  no autoloads found in project.godot")
        return 1
    names = "|".join(sorted(known, key=len, reverse=True))
    call = re.compile(r"\b(" + names + r")\.([A-Za-z_]\w*)")
    issues = []
    scanned = 0
    cache = {}
    modules = 0
    roots = ["scenes", "autoload", "tools"]
    for root in roots:
        for base, _dirs, files in os.walk(root):
            for fn in files:
                if not fn.endswith(".gd"):
                    continue
                path = os.path.join(base, fn)
                scanned += 1
                src = io.open(path, encoding="utf-8").read()
                # What this file calls its preloaded modules, and what
                # each of those actually declares.
                local = {}
                for alias, target in PRELOAD.findall(src):
                    have = members_of(target.replace("res://", ""), cache)
                    if have is not None:
                        local[alias] = (target, have)
                modules += len(local)
                local_call = None
                if local:
                    ordered = sorted(local, key=len, reverse=True)
                    local_call = re.compile(
                        r"\b(" + "|".join(ordered) + r")\.([A-Za-z_]\w*)")
                for i, line in enumerate(src.split("\n"), 1):
                    if line.lstrip().startswith("#"):
                        continue
                    # a quoted path is not a member access
                    line = re.sub(r'"[^"]*"', '""', line)
                    for m in call.finditer(line):
                        who, member = m.group(1), m.group(2)
                        if member not in known[who]:
                            issues.append("  %s:%d  %s.%s does not exist"
                                          % (path, i, who, member))
                    if local_call is None:
                        continue
                    for m2 in local_call.finditer(line):
                        who2, member2 = m2.group(1), m2.group(2)
                        target, have = local[who2]
                        # `new()` and the Object built-ins come from the base
                        # class, not from the file, so they are never declared.
                        if member2 in ("new", "call", "get", "set", "instantiate",
                                       "resource_path", "has_method", "bind"):
                            continue
                        if member2 not in have:
                            issues.append(
                                "  %s:%d  %s.%s does not exist in %s"
                                % (path, i, who2, member2,
                                   target.rsplit("/", 1)[-1]))
    print("Foreign to All - name member check")
    print("  %d autoloads, %d preloaded modules, %d scripts"
          % (len(known), modules, scanned))
    print("")
    if issues:
        print("  %d issue(s):" % len(issues))
        print("\n".join(issues))
        return 1
    print("  CLEAN")
    return 0


if __name__ == "__main__":
    sys.exit(main())

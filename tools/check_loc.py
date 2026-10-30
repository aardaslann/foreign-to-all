# -*- coding: utf-8 -*-
"""Every language must be exactly as long as the key list.

LocText.gd stores twenty languages as parallel arrays, because sixty-two keys
times twenty as dictionaries is a wall nobody would read. The order IS the
contract: one entry added to KEYS without adding one to all twenty silently
shifts every string after it, so the journal's close button ends up saying
"Medium" in Tamil and nothing crashes.

    python tools/check_loc.py
"""
import io
import re
import sys

PATH = "autoload/LocText.gd"


def main():
    src = io.open(PATH, encoding="utf-8").read()
    keys_block = re.search(r"const KEYS := \[(.*?)\n\]", src, re.S)
    if not keys_block:
        print("  KEYS not found in " + PATH)
        return 1
    n = len(re.findall(r'"', keys_block.group(1))) // 2
    issues = []
    seen = 0
    for m in re.finditer(r'^"([a-z]{2,3})": \[(.*?)\n\],', src, re.S | re.M):
        seen += 1
        code, body = m.group(1), m.group(2)
        cnt = len(re.findall(r'"', body)) // 2
        if cnt != n:
            issues.append("  %s has %d entries, KEYS has %d" % (code, cnt, n))
    if seen == 0:
        issues.append("  no language tables found")
    print("Foreign to All - localisation check")
    print("  %d keys, %d languages" % (n, seen))
    print("")
    if issues:
        print("  %d issue(s):" % len(issues))
        print("\n".join(issues))
        return 1
    print("  CLEAN")
    return 0


if __name__ == "__main__":
    sys.exit(main())

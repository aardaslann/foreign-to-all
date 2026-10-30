#!/usr/bin/env python3
"""Static checks for Foreign to All.

Godot is not installed on this machine, so nothing can be run or play-tested.
This is the substitute: it catches the error classes that have actually broken
this project, before they reach the editor.

    py tools/static_check.py

Exit code 0 = clean, 1 = issues found.

What it catches, and why each one is here:
  * undefined self-calls      - killed the whole game once (MapView.gd called
                                _draw_interior_map() and never defined it, so
                                every scene that instances MapView failed to load)
  * undefined variables       - the half-finished-rename bug (WORD_GUESSES ->
                                WORD_GUESSES_DE left five dead call sites)
  * unresolvable res:// paths - a scene pointing at a file that isn't there
  * undeclared resource ids   - ExtResource("x") with no matching [ext_resource]
  * ':=' inference traps      - from a subscript, .get(), or a boolean; GDScript
                                cannot always infer these and refuses to compile
  * leading-space indentation - this codebase is tabs; mixing them is a parse error
  * `const X := SomeClassName` - a bare class reference is NOT a constant
                                expression in Godot 4. It parses in the
                                editor's class scan and then fails at load,
                                so every scene using the script dies with
                                'Assigned value for constant isn't a
                                constant expression'. Use preload().
  (line continuations are used throughout this codebase and parse fine — not flagged)
"""

import io
import os
import re
import sys
import glob

# Godot lifecycle callbacks: called by the engine, never defined by us
ENGINE_CALLBACKS = {
    "_ready", "_process", "_draw", "_input", "_init", "_physics_process",
    "_notification", "_exit_tree", "_enter_tree", "_unhandled_input",
    "_unhandled_key_input", "_gui_input", "_to_string", "_get", "_set",
    "_get_property_list", "_property_can_revert", "_property_get_revert",
    "_integrate_forces", "_shortcut_input", "_validate_property",
}

# Keywords that can legally sit immediately before a `[` — `x in [a, b]`,
# `return [1]`, `match [a, b]`. An earlier version flagged every one of these
# as an undefined variable, which is how we learned to keep this list.
GD_KEYWORDS = {
    "in", "return", "match", "and", "or", "not", "if", "elif", "else",
    "while", "for", "await", "as", "is", "assert", "yield", "pass", "break",
    "continue", "var", "const", "func", "class", "extends", "emit",
}

GD_BUILTINS = {
    "range", "print", "str", "int", "float", "bool", "abs", "min", "max",
    "clamp", "clampi", "clampf", "sin", "cos", "tan", "sqrt", "pow", "floor",
    "ceil", "round", "lerp", "randi", "randf", "len", "load", "preload",
    "maxi", "mini", "maxf", "minf", "absf", "absi", "sign", "snapped",
    "self", "true", "false", "null", "PI", "TAU", "INF", "NAN", "super",
}


def gd_files():
    return sorted(glob.glob("scenes/**/*.gd", recursive=True)) + \
           sorted(glob.glob("autoload/*.gd"))


def tscn_files():
    return sorted(glob.glob("scenes/**/*.tscn", recursive=True))


def read(path):
    return io.open(path, encoding="utf-8").read()


def strip_noncode(src):
    """Blank out comments and string bodies, preserving line numbers.

    Every check here has at some point reported a bug that was only *described*
    in a comment, or a pattern that lived inside a string literal. Doing it in
    one place means the next check gets it right for free. Newlines are kept so
    reported line numbers still match the real file.
    """
    def blank(m):
        return re.sub(r"[^\n]", " ", m.group(0))
    out = re.sub(r'"""(?:.|\n)*?"""', blank, src)
    out = re.sub(r"'''(?:.|\n)*?'''", blank, out)
    out = re.sub(r"(?m)#.*$", blank, out)
    out = re.sub(r'"(?:[^"\\\n]|\\.)*"', blank, out)
    out = re.sub(r"'(?:[^'\\\n]|\\.)*'", blank, out)
    return out



def check_empty_blocks(path, src, issues):
    """A block header with nothing under it.

    GDScript needs an indented body; a header followed by a comment and then a
    dedent is a parse error, and the whole SCRIPT fails to load - which in this
    project means every person, or every cat, in every scene silently vanishes.
    Deleting the one statement inside an `if` and leaving its comment behind is
    how it happens, and it happened.
    """
    openers = ("if ", "elif ", "else:", "for ", "while ", "match ", "func ")
    case = re.compile(r'^("[^"]*"|[A-Za-z_][A-Za-z0-9_.]*|-?[0-9]+|_)(, .+)?:$')
    lines = src.split(chr(10))
    # A `for x in [` whose list runs over four lines ends on a line that looks
    # exactly like a block header. Only a line that STARTS a statement can be
    # one, so bracket depth is tracked and continuation lines are skipped.
    depth = 0
    for i, ln in enumerate(lines):
        opening = depth
        bare = strip_noncode(ln)
        depth += bare.count("(") + bare.count("[") + bare.count("{")
        depth -= bare.count(")") + bare.count("]") + bare.count("}")
        if opening > 0:
            continue
        st = ln.strip()
        if not st.endswith(":") or st.startswith("#"):
            continue
        if not any(st.startswith(o) or st == o for o in openers)                 and not case.match(st):
            continue
        ind = len(ln) - len(ln.lstrip(chr(9)))
        for j in range(i + 1, len(lines)):
            nxt = lines[j]
            if not nxt.strip() or nxt.strip().startswith("#"):
                continue
            if len(nxt) - len(nxt.lstrip(chr(9))) <= ind:
                issues.append("%s:%d  block header with no body: %s"
                              % (path, i + 1, st))
            break



def check_dup_dict_keys(path, src, issues):
    """A key written twice in one dictionary literal is a parse error.

    Adding a mouth colour to a palette that already had one made
    CharacterArt.gd fail to compile, which silently removed every person
    from every scene in the game - and every check here passed.
    """
    # NOT strip_noncode: it blanks string bodies AND their quotes, so the
    # keys this looks for stop existing. Comment lines are dropped by hand.
    code = chr(10).join(
        "" if ln.lstrip().startswith("#") else ln
        for ln in src.split(chr(10)))
    depth = 0
    stack = []
    line_no = 1
    i = 0
    while i < len(code):
        ch = code[i]
        if ch == chr(10):
            line_no += 1
        elif ch == "{":
            depth += 1
            stack.append({})
        elif ch == "}":
            if stack:
                stack.pop()
            depth = max(0, depth - 1)
        elif ch == chr(34) and stack:
            j = code.find(chr(34), i + 1)
            if j > i:
                after = code[j + 1:j + 3].lstrip()
                if after[:1] == ":":
                    key = code[i + 1:j]
                    top = stack[-1]
                    if key in top:
                        issues.append(
                            "%s:%d  key %s appears twice in one dictionary"
                            % (path, line_no, key))
                    else:
                        top[key] = line_no
                line_no += code.count(chr(10), i, j)
                i = j
        i += 1


def check_duplicate_funcs(path, src, issues):
    """Two functions with the same name is a parse error, and this missed it.

    Replacing a block of CutsceneArt.gd left the old look() and alien_look()
    above the new ones. Every check in this file passed and the script would
    not load at all -- exactly the class of fault this exists to catch
    instead of the editor, because the editor is not on this machine.
    """
    seen = {}
    pat = r"^\s*(?:static\s+)?func\s+(\w+)"
    for m in re.finditer(pat, strip_noncode(src), re.M):
        name = m.group(1)
        line = src[:m.start()].count(chr(10)) + 1
        if name in seen:
            issues.append("%s:%d  func %s() is declared twice"
                          " (first at line %d)" % (path, line, name, seen[name]))
        else:
            seen[name] = line


def check_self_calls(path, src, issues):
    # `static func` counts as defined, which an earlier version of this script
    # got wrong and reported six false positives for
    defined = set(re.findall(r"^\s*(?:static\s+)?func\s+(\w+)", src, re.M))
    # A comment that names a function is not a call to it. This file's own
    # strip_noncode() says "doing it in one place means the next check gets it
    # right for free", and then three of the checks never called it - so a
    # comment explaining why something runs in _initialize() was reported as
    # an undefined self-call.
    src = strip_noncode(src)
    for m in re.finditer(r"(?<![\w.])(_[a-z]\w*)\s*\(", src):
        name = m.group(1)
        if name in defined or name in ENGINE_CALLBACKS:
            continue
        line = src[:m.start()].count("\n") + 1
        issues.append(f"{path}:{line}  undefined self-call {name}()")


def check_undefined_vars(path, src, issues):
    src = strip_noncode(src)
    """Bare identifiers used as a subscript that are declared NOWHERE in the file.

    File-scope rather than block-scope on purpose. Tracking real scope produced
    a flood of false positives (lambda params, loop vars, the `in` keyword) and
    a check nobody trusts is worse than no check. This is deliberately
    high-precision: it misses out-of-scope use, but it does catch the bug it
    exists for — a rename that leaves a dead reference behind, which is how
    WORD_GUESSES and a stray `names[i]` both slipped through.
    """
    declared = set()
    declared |= set(re.findall(r"^const (\w+)", src, re.M))
    declared |= set(re.findall(r"^(?:@export\s+)?(?:static\s+)?var (\w+)", src, re.M))
    declared |= set(re.findall(r"\bvar (\w+)", src))
    # `for s in ...` and the typed form `for s: Dictionary in ...`
    declared |= set(re.findall(r"\bfor\s+(\w+)\s*(?::\s*\w+)?\s+in\b", src))
    declared |= set(re.findall(r"\bsignal (\w+)", src))
    # every parameter of every func, named or lambda
    for params in re.findall(r"\bfunc\s*\w*\(([^)]*)\)", src):
        declared |= set(re.findall(r"(\w+)\s*[:,)=]", params + ","))

    # Scan code only. Comments were matching too: "# deep navy top" followed by
    # a newline and "[0.28, ...]" read as `top[...]`. And the gap before the
    # bracket must not span lines, for the same reason.
    # String literals go too: "%s[/url]" was reading as `s[...]`.
    # Triple-quoted blocks first — a help string containing "output[/color]"
    # was being read as `output[...]`.
    code = re.sub(r'"""(?:.|\n)*?"""', '""', src)
    code = re.sub(r"'''(?:.|\n)*?'''", "''", code)
    code = re.sub(r"(?m)#.*$", "", code)
    code = re.sub(r'"(?:[^"\\\n]|\\.)*"', '""', code)
    code = re.sub(r"'(?:[^'\\\n]|\\.)*'", "''", code)
    for m in re.finditer(r'(?<![\w."\'])([a-z_][a-z0-9_]*)[ \t]*\[', code):
        name = m.group(1)
        if name in declared or name in GD_BUILTINS or name in GD_KEYWORDS:
            continue
        line = code[:m.start()].count("\n") + 1
        issues.append(f"{path}:{line}  '{name}' used as {name}[...] but declared nowhere in this file")


def check_style(path, src, issues):
    for i, ln in enumerate(src.split("\n"), 1):
        if ln.startswith(" ") and ln.strip():
            issues.append(f"{path}:{i}  leading space (this codebase is tab-indented)")
        # Strip the comment before pattern-matching code. A comment that
        # *describes* one of these bugs was being reported as one.
        s = re.sub(r"#.*$", "", ln).strip()
        if re.search(r"\bvar \w+\s*:=\s*\w+\[[^\]]+\]\s*$", s) and "range(" not in s:
            issues.append(f"{path}:{i}  ':=' inferring from a subscript — give it an explicit type")
        if re.search(r"\bvar \w+\s*:=.*\b(and|or)\b", s) and not s.startswith("if"):
            issues.append(f"{path}:{i}  ':=' inferring from a boolean — give it an explicit type")


def check_named_args(path, src, issues):
    """`foo(bar = 1)` — Python keyword-argument syntax, which GDScript rejects.

    Easy to type without noticing when you have been switching between the two
    languages all day, and it is a hard parse error rather than a warning.
    Assignment inside a call is never valid GDScript, so any `name =` sitting
    directly inside an argument list is this bug.
    """
    src = strip_noncode(src)
    for m in re.finditer(r"(?<![\w.])(\w+)\s*\(([^()\n]*)\)", src):
        args = m.group(2)
        if not re.search(r"(?<![=!<>+\-*/%])\b\w+\s*=(?!=)", args):
            continue
        # A declaration's default values look identical and are perfectly
        # legal — `func f(n: int = 1)`. Only a CALL is the bug.
        line_start = src.rfind("\n", 0, m.start()) + 1
        if re.match(r"\s*(?:static\s+)?func\s", src[line_start:m.end()]):
            continue
        line = src[:m.start()].count("\n") + 1
        issues.append(
            f"{path}:{line}  {m.group(1)}({args.strip()}) uses named-argument "
            f"syntax — GDScript has no keyword arguments")


def check_literal_subscript(path, src, issues):
    """`var x := [a, b, c][i]` — an inline literal subscripted in place.

    The literal's element type is not carried through the subscript, so this
    is Variant and ':=' cannot infer it. Distinct from `var x := [a, b, c]`,
    which infers Array perfectly well — the difference is the trailing `[i]`,
    and reading past it is how two of these reached the editor.
    """
    src = strip_noncode(src)
    for m in re.finditer(r"\bvar\s+(\w+)\s*:=\s*[\[{]", src):
        i, depth, instr = m.end(), 1, False
        while i < len(src) and depth > 0:
            ch = src[i]
            if ch == '"':
                instr = not instr
            elif not instr:
                if ch in "([{":
                    depth += 1
                elif ch in ")]}":
                    depth -= 1
            i += 1
        if src[i:i + 40].lstrip().startswith("["):
            line = src[:m.start()].count("\n") + 1
            issues.append(
                f"{path}:{line}  var {m.group(1)} := [...][i] subscripts an inline "
                f"literal — infers Variant; hoist it to a const")


CASTS = ("int(", "float(", "String(", "bool(", "str(", "Vector2(", "Array(",
         "Dictionary(", "Color(", "StringName(", "NodePath(")


def check_variant_inference(path, src, issues):
    """`var x := <something>.get(...)` with no cast around it.

    Dictionary.get()/Array.get() return Variant, so ':=' infers Variant, and
    Godot with warnings-as-errors refuses to compile. This is narrower than a
    line regex on purpose: it walks the whole right-hand side across nesting,
    because the real instance in this project was a multi-line dictionary
    literal (`var dest := { ... }.get(pick, "")`) that a per-line pattern
    could never have seen.

    A cast wrapper (int(...), String(...)) makes it safe, and so does a
    ternary whose branches are typed — both are excluded.
    """
    src = strip_noncode(src)
    for m in re.finditer(r"\bvar\s+(\w+)\s*:=\s*", src):
        i, depth, instr, rhs = m.end(), 0, False, ""
        while i < len(src):
            ch = src[i]
            if ch == '"':
                instr = not instr
            if not instr:
                if ch in "([{":
                    depth += 1
                elif ch in ")]}":
                    depth -= 1
                elif ch == "\n" and depth <= 0:
                    # a trailing backslash continues the expression onto the
                    # next line; stopping here truncated a ternary and made
                    # this check fire on perfectly good code
                    if rhs.rstrip().endswith("\\"):
                        rhs = rhs.rstrip()[:-1] + " "
                        i += 1
                        continue
                    break
            rhs += ch
            i += 1
        flat = " ".join(rhs.split())
        if ".get(" not in flat or flat.startswith(CASTS):
            continue
        if " if " in flat and " else " in flat:
            continue
        # Only a bare, OUTERMOST .get() is a problem. `float(d.get(k)) * 2` is
        # fine — the cast fixes the type — so require the call's closing paren
        # to be the last thing in the expression.
        g = flat.rfind(".get(")
        j, d2 = g + 5, 1
        while j < len(flat) and d2 > 0:
            if flat[j] == "(":
                d2 += 1
            elif flat[j] == ")":
                d2 -= 1
            j += 1
        if flat[j:].strip():
            continue
        line = src[:m.start()].count("\n") + 1
        issues.append(
            f"{path}:{line}  var {m.group(1)} := ... .get(...) infers Variant — "
            f"wrap it in a cast or declare the type")


def check_resources(paths, issues):
    for path in paths:
        src = read(path)
        # Match the complete extension: .gdshader must not become .gd.
        for m in re.finditer(r'res://([^"\')\s]+\.(?:tscn|gdshader|gd|png|mp3|ogg|tres))(?![A-Za-z0-9_])', src):
            # "res://scenes/world/%s.tscn" is a format template, not a path
            if "%" in m.group(1):
                continue
            if not os.path.exists(m.group(1)):
                line = src[:m.start()].count("\n") + 1
                issues.append(f"{path}:{line}  missing resource res://{m.group(1)}")


def check_scene_ids(path, src, issues):
    declared = set(re.findall(r'\[ext_resource[^\]]*id="([^"]+)"', src))
    used = set(re.findall(r'ExtResource\("([^"]+)"\)', src))
    sub_declared = set(re.findall(r'\[sub_resource[^\]]*id="([^"]+)"', src))
    sub_used = set(re.findall(r'SubResource\("([^"]+)"\)', src))
    if used - declared:
        issues.append(f"{path}  undeclared ExtResource ids {sorted(used - declared)}")
    if sub_used - sub_declared:
        issues.append(f"{path}  undeclared SubResource ids {sorted(sub_used - sub_declared)}")


def check_exports(path, src, issues):
    """A scene setting `foo = ...` on a scripted node where the script has no
    @export foo. Godot drops the value silently, which is worse than erroring."""
    known = {"script", "position", "rotation", "scale", "z_index", "visible",
             "modulate", "self_modulate", "shape", "text", "index", "size",
             "polygon", "color", "theme_override_font_sizes/font_size"}
    for blk in re.split(r"(?=^\[node )", src, flags=re.M):
        sm = re.search(r'script = ExtResource\("([^"]+)"\)', blk)
        if not sm:
            continue
        pm = re.search(
            r'\[ext_resource[^\]]*path="res://([^"]+)"[^\]]*id="%s"' % re.escape(sm.group(1)),
            src)
        if not pm or not os.path.exists(pm.group(1)):
            continue
        exports = set(re.findall(r"@export var (\w+)", read(pm.group(1))))
        for p in re.findall(r"^(\w+) = ", blk, re.M):
            if p in known or p in exports:
                continue
            issues.append(f"{path}  '{p} = ...' is not an @export of {pm.group(1)}")


# `const X := SomeClassName` is accepted by the editor's class scan and then
# refused at load time: a bare class reference is not a constant expression.
# This project already had the right form (`preload("res://...gd")`) in every
# hand-written background; twelve generated ones did not, and every new city
# crashed on arrival. Caught here so it cannot happen twice.
CONST_CLASS = re.compile(r"^const\s+(\w+)\s*:=\s*([A-Z]\w*)\s*$", re.M)


def const_class_alias(path, text, class_names):
    out = []
    for m in CONST_CLASS.finditer(text):
        if m.group(2) not in class_names:
            continue
        ln = text[:m.start()].count(chr(10)) + 1
        out.append("%s:%d  const %s := %s is not a constant expression; "
                   "use preload(\"res://...%s.gd\")"
                   % (path, ln, m.group(1), m.group(2), m.group(2)))
    return out


OPS = ("+", "-", "*", "/", "and", "or", "==", "!=", "<", ">", "<=", ">=")


def dangling_operator(lines):
    """A continued expression with no backslash and no open bracket.

    GDScript continues a line for free inside ( [ { -- and only there.
    Splitting a condition over two lines anywhere else parses as two
    statements and the file will not load, which nothing else here catches
    because each line is valid on its own.
    """
    bad = []
    depth = 0
    for n, raw in enumerate(lines):
        line = raw.split("#", 1)[0].rstrip()
        opened = depth
        for ch in line:
            if ch in "([{":
                depth += 1
            elif ch in ")]}":
                depth = max(0, depth - 1)
        if not line or line.endswith(chr(92)) or opened > 0 or depth > 0:
            continue
        nxt = lines[n + 1].strip() if n + 1 < len(lines) else ""
        if not nxt or nxt.startswith("#"):
            continue
        for op in OPS:
            if nxt.startswith(op + " "):
                bad.append((n + 2, nxt[:52]))
                break
    return bad

def main():
    if not os.path.exists("project.godot"):
        print("run this from the project root (where project.godot lives)")
        return 2

    issues = []
    scripts = gd_files()
    scenes = tscn_files()

    # Every class_name declared anywhere, so the const-alias rule knows which
    # bare identifiers are class references rather than ordinary constants.
    class_names = set()
    for path in scripts:
        m = re.search(r"^class_name\s+(\w+)", read(path), re.M)
        if m:
            class_names.add(m.group(1))

    for path in scripts:
        src = read(path)
        issues.extend(const_class_alias(path, src, class_names))
        check_dup_dict_keys(path, src, issues)
        check_empty_blocks(path, src, issues)
        check_duplicate_funcs(path, src, issues)
        check_self_calls(path, src, issues)
        check_undefined_vars(path, src, issues)
        check_style(path, src, issues)
        check_variant_inference(path, src, issues)
        check_literal_subscript(path, src, issues)
        check_named_args(path, src, issues)
        for ln, txt in dangling_operator(src.split(chr(10))):
            issues.append("%s:%d  continued expression with no backslash: %s"
                          % (path, ln, txt))

    for path in scenes:
        src = read(path)
        check_scene_ids(path, src, issues)
        # check_exports() is deliberately NOT run: distinguishing a script's
        # @export from an engine property (layout_mode, anchors_preset, ...)
        # needs Godot's real property list, and guessing produced pages of
        # false positives on perfectly good scenes.

    check_resources(scripts + scenes, issues)

    print("Foreign to All — static check")
    print(f"  {len(scripts)} scripts, {len(scenes)} scenes\n")
    if not issues:
        print("  CLEAN")
        return 0
    print(f"  {len(issues)} issue(s):\n")
    for i in issues:
        print("   " + i)
    return 1


if __name__ == "__main__":
    sys.exit(main())

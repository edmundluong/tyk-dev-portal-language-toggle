#!/usr/bin/env python3
"""
Single source of truth for this theme's `dict "en" "X" "ar" "Y" "fr" "Z" ...`
translation strings.

Why this exists: the runtime strings stay as literal
`dict "en" ... "ar" ... "fr" ... "es" ...` blocks in each .tmpl file, since
that's how the Portal's template engine expects translated content to be
authored. What this script moves out of the templates is the *authoring*
source of truth: it keeps themes/i18n-strings.json (keyed by the exact
English string) and every `dict "en"/...` occurrence across the theme in
sync, so a translator edits one JSON file instead of hunting through 40+
.tmpl files.

LANGS below is the single place that knows which non-English languages
exist and what order their dict keys appear in (must match the literal
order in the .tmpl files -- "en" "X" "ar" "Y" "fr" "Z" "es" "W", not some
other order). Adding a language to the theme means adding its code here
too, in the same position it was added to the dict literals.

Deliberately scoped to ONLY the dominant `dict "en" "X" "ar" "Y" ...` shape.
A handful of other shapes exist for good, file-specific reasons --
$enumT (dict "EnglishValue" (dict "ar" "..." "fr" "...")), $monthNames,
$planFormats, $titleOverrides, TYK_PAGE_MAP, $languages/$homePaths in
top_nav.tmpl, and the hasPrefix language-filter in catalogue.tmpl/
blog_listing.tmpl/blog_detail.tmpl -- and are intentionally NOT covered
here: they're a handful of files each, already commented in place, and
forcing them into this same generic shape would be more machinery than
the repetition justifies. See themes/README.md's translation management
section for the full list of what still needs a manual touch per new
language.

Usage (run from the themes/ directory):
  python3 i18n-sync.py extract   Regenerate i18n-strings.json FROM the
                                  current .tmpl files. Use this once to
                                  bootstrap the JSON from existing
                                  templates, or to recover it if it's ever
                                  lost -- the .tmpl files remain the
                                  ultimate fallback source of truth.
  python3 i18n-sync.py check     Verify every dict occurrence matches
                                  i18n-strings.json. Exits 1 and prints
                                  every drifted/missing entry if anything
                                  doesn't match -- safe to wire into CI or
                                  a pre-commit hook.
  python3 i18n-sync.py apply     Rewrite every dict occurrence's non-English
                                  values to match i18n-strings.json exactly.
                                  Run this after editing the JSON.

Workflow for translators: edit i18n-strings.json, run `apply`, review the
resulting .tmpl diff, commit both. Workflow for a new English string: add
it to a template as normal (`dict "en" "New string" "ar" "" "fr" "" "es"
""`), run `extract` to pull the new key into the JSON with empty values,
translate it there, run `apply` to fill in the template. Workflow for a
new LANGUAGE: add its code to LANGS below, add a `"<code>" ""` stub to
every existing dict literal in the .tmpl files (a one-time mechanical
find/replace, since `extract`/`apply` need the literal to already have a
slot for the new language before they can populate it), run `extract` to
pull everything into the JSON, translate, `apply`.
"""

import json
import re
import sys
from pathlib import Path

THEME_DIR = Path(__file__).resolve().parent / "default"
JSON_PATH = Path(__file__).resolve().parent / "i18n-strings.json"

# Non-English languages, in the exact order their keys appear in every
# dict "en" ... literal across the theme. Add a language here (in position)
# when it's added to the theme -- see the "Workflow for a new LANGUAGE" note
# above.
LANGS = ["ar", "fr", "es"]

_STR_GROUP = r'"((?:[^"\\]|\\.)*)"'
PATTERN = re.compile(
    r'dict "en" ' + _STR_GROUP +
    "".join(f' "{lang}" ' + _STR_GROUP for lang in LANGS)
)


def all_tmpl_files():
    return sorted(THEME_DIR.glob("**/*.tmpl"))


def load_json():
    if not JSON_PATH.exists():
        return {}
    with open(JSON_PATH, encoding="utf-8") as f:
        return json.load(f)


def save_json(data):
    with open(JSON_PATH, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2, sort_keys=True)
        f.write("\n")


def match_to_entry(m):
    en = m.group(1)
    values = {lang: m.group(2 + i) for i, lang in enumerate(LANGS)}
    return en, values


def cmd_extract():
    strings = {}
    conflicts = []
    for path in all_tmpl_files():
        text = path.read_text(encoding="utf-8")
        for m in PATTERN.finditer(text):
            en, values = match_to_entry(m)
            if en in strings and strings[en] != values:
                conflicts.append((en, path, strings[en], values))
            strings[en] = values

    save_json(strings)
    print(f"Extracted {len(strings)} unique strings to {JSON_PATH}")
    if conflicts:
        print(f"\nWARNING: {len(conflicts)} EN string(s) had inconsistent "
              f"values across files (last occurrence wins in the JSON):")
        for en, path, old, new in conflicts:
            print(f"  {en!r} in {path.relative_to(THEME_DIR.parent)}: {old} != {new}")
    return 1 if conflicts else 0


def cmd_check():
    strings = load_json()
    if not strings:
        print(f"{JSON_PATH} is empty or missing -- run `extract` first.")
        return 1

    problems = []
    for path in all_tmpl_files():
        text = path.read_text(encoding="utf-8")
        for m in PATTERN.finditer(text):
            en, values = match_to_entry(m)
            entry = strings.get(en)
            if entry is None:
                problems.append(f"{path.relative_to(THEME_DIR.parent)}: {en!r} not in {JSON_PATH.name}")
                continue
            drifted = {lang: v for lang, v in values.items() if entry.get(lang) != v}
            if drifted:
                problems.append(
                    f"{path.relative_to(THEME_DIR.parent)}: {en!r} drifted "
                    f"from {JSON_PATH.name} (template has {drifted}, "
                    f"JSON has {{ {', '.join(f'{lang!r}: {entry.get(lang)!r}' for lang in drifted)} }})"
                )

    if problems:
        print(f"{len(problems)} problem(s):")
        for p in problems:
            print(f"  {p}")
        return 1

    print(f"OK -- every dict \"en\"...{'...'.join(LANGS)}... occurrence matches {JSON_PATH.name}.")
    return 0


def cmd_apply():
    strings = load_json()
    if not strings:
        print(f"{JSON_PATH} is empty or missing -- run `extract` first.")
        return 1

    missing = set()
    files_changed = 0
    occurrences_changed = 0

    for path in all_tmpl_files():
        text = path.read_text(encoding="utf-8")

        def repl(m):
            nonlocal occurrences_changed
            en, values = match_to_entry(m)
            entry = strings.get(en)
            if entry is None:
                missing.add(en)
                return m.group(0)
            new_values = {lang: entry.get(lang, values[lang]) for lang in LANGS}
            if new_values == values:
                return m.group(0)
            occurrences_changed += 1
            parts = [f'dict "en" "{en}"'] + [f'"{lang}" "{new_values[lang]}"' for lang in LANGS]
            return " ".join(parts)

        new_text = PATTERN.sub(repl, text)
        if new_text != text:
            path.write_text(new_text, encoding="utf-8")
            files_changed += 1

    print(f"Applied {JSON_PATH.name}: {occurrences_changed} occurrence(s) "
          f"updated across {files_changed} file(s).")
    if missing:
        print(f"\n{len(missing)} EN string(s) found in templates but not in "
              f"{JSON_PATH.name} (left unchanged -- add them and re-run):")
        for en in sorted(missing):
            print(f"  {en!r}")
        return 1
    return 0


def main():
    if len(sys.argv) != 2 or sys.argv[1] not in ("extract", "check", "apply"):
        print(__doc__)
        return 2
    return {"extract": cmd_extract, "check": cmd_check, "apply": cmd_apply}[sys.argv[1]]()


if __name__ == "__main__":
    sys.exit(main())

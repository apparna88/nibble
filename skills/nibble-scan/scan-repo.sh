#!/usr/bin/env bash
#
# nibble-scan deterministic pre-pass.
#
# Runs a small set of structural bug patterns BEFORE the model's review, so the
# obvious, mechanical defects are caught with zero guesswork.
#
#   - A regex baseline (ripgrep, or grep) always runs and covers every check.
#   - If ast-grep is installed, an extra AST-precise pass runs on top for the
#     structural checks where real parsing removes false positives.
#
# Advisory only: always exits 0. Matches are candidates, not confirmed bugs;
# feed them into nibble-scan's review and hand real findings to nibble-trace.
#
# Usage: ./scan-repo.sh [path]   (defaults to the current directory)

set -u
TARGET="${1:-.}"

# ast-grep only. Do NOT probe for the bare name "sg": on many systems that is
# the shadow-utils group command, not ast-grep.
AST=""
if command -v ast-grep >/dev/null 2>&1; then AST="ast-grep"; fi

SEARCH="grep"
if command -v rg >/dev/null 2>&1; then SEARCH="rg"; fi

echo "== nibble-scan deterministic pre-pass =="
echo "baseline: $SEARCH (regex)"
if [ -n "$AST" ]; then
  echo "precise:  ast-grep (AST) available, running extra pass"
else
  echo "precise:  ast-grep not found (install it for higher precision)"
fi
echo "target:   $TARGET"
echo

# regex_check <label> <extended-regex> <glob>
regex_check() {
  local label="$1" re="$2" glob="$3" hits=""
  if [ "$SEARCH" = "rg" ]; then
    hits="$(rg -n --no-heading -g "$glob" -e "$re" "$TARGET" 2>/dev/null)"
  else
    hits="$(grep -rEn --include="$glob" -e "$re" "$TARGET" 2>/dev/null)"
  fi
  if [ -n "$hits" ]; then
    printf '### %s\n' "$label"
    printf '%s\n\n' "$hits" | sed 's/^/  /'
  fi
}

# ast_check <label> <lang> <pattern> ; only runs when ast-grep is present.
ast_check() {
  [ -n "$AST" ] || return 0
  local label="$1" lang="$2" pat="$3" hits=""
  hits="$(ast-grep run -p "$pat" -l "$lang" "$TARGET" 2>/dev/null)"
  if [ -n "$hits" ]; then
    printf '### [AST] %s\n' "$label"
    printf '%s\n\n' "$hits" | sed 's/^/  /'
  fi
}

echo "--- baseline (regex) ---"
echo

# Security: dynamic code and injection
regex_check "Dynamic code evaluation: eval()" '\beval[[:space:]]*\(' '*'
regex_check "Dynamic code: new Function()" 'new[[:space:]]+Function[[:space:]]*\(' '*'
regex_check "Dynamic RegExp (verify the argument is not user input)" 'new[[:space:]]+RegExp[[:space:]]*\(' '*'
regex_check "postMessage with wildcard origin" '\.postMessage[[:space:]]*\([^)]*,[[:space:]]*['\''"]\*['\''"]' '*'
regex_check "Shell injection risk: subprocess with shell=True" 'subprocess\.[A-Za-z_]+\([^)]*shell[[:space:]]*=[[:space:]]*True' '*.py'
regex_check "Unsafe deserialization: pickle.loads" 'pickle\.loads[[:space:]]*\(' '*.py'
regex_check "Unsafe deserialization: yaml.load (prefer safe_load)" 'yaml\.load[[:space:]]*\(' '*.py'
regex_check "Command exec from a built string (Go)" 'exec\.Command\(' '*.go'

# Reliability: environment leakage in portable code
regex_check "Environment global in JS (guard for non-DOM/worker runtimes)" '\b(window|document|localStorage|sessionStorage)\b' '*.js'
regex_check "Environment global in TS (guard for non-DOM/worker runtimes)" '\b(window|document|localStorage|sessionStorage)\b' '*.ts'

# Correctness: obvious tautologies
regex_check "Possible tautology in a condition" '([A-Za-z_][A-Za-z0-9_.]*)[[:space:]]*===[[:space:]]*undefined[[:space:]]*\|\|[[:space:]]*\1[[:space:]]*!==[[:space:]]*undefined' '*'

if [ -n "$AST" ]; then
  echo "--- AST-precise pass (ast-grep) ---"
  echo
  for L in js ts tsx; do
    ast_check "Dynamic code evaluation ($L): eval()" "$L" 'eval($$$A)'
    ast_check "Dynamic code ($L): new Function()" "$L" 'new Function($$$A)'
    ast_check "Dynamic RegExp from a variable ($L)" "$L" 'new RegExp($A)'
    ast_check "postMessage wildcard origin ($L)" "$L" '$T.postMessage($M, "*")'
  done
  ast_check "Dynamic code evaluation (python): eval()" python 'eval($$$A)'
  ast_check "Dynamic code evaluation (python): exec()" python 'exec($$$A)'
fi

echo "== end pre-pass =="
echo "Note: matches are candidates, not confirmed bugs. Confirm each in the review,"
echo "then hand real findings to nibble-trace."
exit 0

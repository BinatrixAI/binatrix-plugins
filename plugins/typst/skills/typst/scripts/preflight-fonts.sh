#!/usr/bin/env bash
# preflight-fonts.sh — diagnose modern-cv font dependencies on macOS.
#
# Exits 0 if all three required fonts are present.
# Exits 1 if any are missing and prints actionable remediation.
#
# Required by @preview/modern-cv: Roboto, Source Sans Pro, FontAwesome.

set -uo pipefail

REQUIRED=("Roboto" "Source Sans" "FontAwesome")

if ! command -v typst >/dev/null 2>&1; then
  echo "error: typst not found on PATH. Install with: brew install typst" >&2
  exit 2
fi

# Capture fonts once
FONTS="$(typst fonts 2>/dev/null)"

missing=()
present=()

for f in "${REQUIRED[@]}"; do
  # Case-insensitive substring match; "Source Sans" matches both "Source Sans Pro" and "Source Sans 3"
  # "FontAwesome" matches both "FontAwesome" and "Font Awesome 6 Free"
  pattern="$(echo "$f" | tr '[:upper:]' '[:lower:]' | tr -d ' ')"
  haystack="$(echo "$FONTS" | tr '[:upper:]' '[:lower:]' | tr -d ' ')"
  if echo "$haystack" | grep -q "$pattern"; then
    present+=("$f")
  else
    missing+=("$f")
  fi
done

echo "Font preflight for @preview/modern-cv:"
echo "---------------------------------------"
for f in "${present[@]}"; do
  echo "  [ok]      $f"
done
for f in "${missing[@]}"; do
  echo "  [missing] $f"
done
echo

if [ ${#missing[@]} -eq 0 ]; then
  echo "All required fonts are present. You can compile modern-cv as-is."
  exit 0
fi

cat <<EOF
Remediation — pick ONE:

A) Install missing fonts via Homebrew (one-time, ~30s):

   brew install --cask$(printf ' %s' "$(for f in "${missing[@]}"; do
     case "$f" in
       Roboto)        echo -n " font-roboto" ;;
       "Source Sans") echo -n " font-source-sans-3" ;;
       FontAwesome)   echo -n " font-fontawesome" ;;
     esac
   done)")

B) Override fonts in the .typ file (no install, slight design loss):

   #show: resume.with(
     ...,
     font: "New Computer Modern",
     header-font: "New Computer Modern",
   )

   New Computer Modern ships with Typst, so this always works.
   Note: FontAwesome icons (github/linkedin/phone) will render as
   fallback squares without the icon font. Drop those fields from
   author: (...) and use a plain text Contact section instead.

After choosing path A, re-run this script to confirm.
EOF

exit 1

set -euo pipefail

# 1) Make sure submodule URL and pointer are up to date
git submodule sync --recursive
git submodule update --init --recursive linked-repositories/sodax-frontend

# 2) Define paths
SRC_BASE="linked-repositories/sodax-frontend/packages"
DST_BASE="developers/packages"

# 3) Create destination base
mkdir -p "$DST_BASE"

# 4) Copy only Markdown files, preserving directory structure
#    This handles spaces and odd characters safely.
find "$SRC_BASE" -type f -name '*.md' -print0 | while IFS= read -r -d '' filepath; do
  relpath="${filepath#"$SRC_BASE"/}"
  targetdir="$DST_BASE/$(dirname "$relpath")"
  mkdir -p "$targetdir"
  cp -f -- "$filepath" "$targetdir/"
done

set -euo pipefail

# 1) Make sure submodule URL and pointer are up to date and fetch latest changes from origin/main
git submodule sync --recursive
git submodule update --init --recursive linked-repositories/sodax-frontend

# Fetch the latest main branch from the submodule's origin and reset submodule worktree to origin/main
(
  cd linked-repositories/sodax-frontend
  git fetch origin main
  git checkout main
  git reset --hard origin/main
  git pull origin main
)

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

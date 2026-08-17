#!/usr/bin/env bash
set -euo pipefail

# 1) Make sure submodule URL and pointer are up to date and fetch latest changes from origin/main
git submodule sync
git submodule update --init linked-repositories/sodax-sdks

# Fetch origin/main into a local branch. -B recreates `main` from the remote
# even when the submodule is in detached HEAD (the usual checkout state).
(
  cd linked-repositories/sodax-sdks
  git fetch origin main
  git checkout -B main origin/main
)

# 2) Define paths
SRC="linked-repositories/sodax-sdks"
DST="developers"
MAP_FILE="$SRC/scripts/gitbook-sync-map.json"

# Helper: copy a single file, creating parent directories as needed.
# Refuses symlink sources: submodule content is upstream-controlled, and a
# symlink could smuggle arbitrary files from the machine running the sync
# into the docs tree (and from there into a sync PR).
copy_file() {
  if [ -L "$1" ]; then
    echo "ERROR: refusing to copy symlink: $1" >&2
    exit 1
  fi
  mkdir -p "$(dirname "$2")"
  cp -f -- "$1" "$2"
}

# Copy every file listed in sodax-sdks scripts/gitbook-sync-map.json.
# Docs Drift in that repo requires new feature pages to be on this list;
# reading the map here means a map entry is enough for the file to land in
# this tree — no second hardcoded copy_file list to keep in sync.
copy_mapped_docs() {
  if [ ! -f "$MAP_FILE" ]; then
    echo "ERROR: missing $MAP_FILE — cannot copy mirrored docs." >&2
    exit 1
  fi
  if ! command -v python3 >/dev/null 2>&1; then
    echo "ERROR: python3 is required to read $MAP_FILE." >&2
    exit 1
  fi

  local src dest
  while IFS=$'\t' read -r src dest; do
    case "$src" in
      *..*|/*) echo "ERROR: invalid map src: $src" >&2; exit 1 ;;
    esac
    case "$dest" in
      developers/*) ;;
      *) echo "ERROR: map dest must be under developers/: $dest" >&2; exit 1 ;;
    esac
    case "$dest" in
      *..*) echo "ERROR: invalid map dest: $dest" >&2; exit 1 ;;
    esac
    if [ ! -f "$SRC/$src" ]; then
      echo "ERROR: mapped source missing: $SRC/$src" >&2
      exit 1
    fi
    echo "copy $src -> $dest"
    copy_file "$SRC/$src" "$dest"
  done < <(python3 - "$MAP_FILE" <<'PY'
import json, sys

with open(sys.argv[1], encoding="utf-8") as fh:
    data = json.load(fh)
for item in data.get("mirrored", []):
    src, dest = item.get("src"), item.get("dest")
    if not src or not dest:
        sys.exit("gitbook-sync-map.json entry missing src or dest")
    print(f"{src}\t{dest}")
PY
)
}

# Fail the copy silently appearing on the site: a mapped dest that is not
# referenced from SUMMARY.md (GitBook) or docs.json (Mintlify) is an orphan.
# Lists missing dests on stderr and, in GitHub Actions, on GITHUB_OUTPUT
# (nav_missing) so the sync PR body can flag them. Does not fail the script:
# the files still need to land in the PR so a human can add the nav entry.
check_nav_coverage() {
  local missing
  missing=$(python3 - "$MAP_FILE" <<'PY'
import json, pathlib, sys

map_path = sys.argv[1]
summary = pathlib.Path("SUMMARY.md").read_text(encoding="utf-8") if pathlib.Path("SUMMARY.md").exists() else ""
docs = pathlib.Path("docs.json").read_text(encoding="utf-8") if pathlib.Path("docs.json").exists() else ""
nav = summary + "\n" + docs

with open(map_path, encoding="utf-8") as fh:
    data = json.load(fh)

missing = []
for item in data.get("mirrored", []):
    dest = item.get("dest") or ""
    stem = dest[:-3] if dest.endswith(".md") else dest
    candidates = [dest, stem]
    if dest.endswith("/README.md"):
        prefix = dest[: -len("/README.md")]
        candidates.extend((prefix, prefix + "/index", prefix + ".md"))
    if dest.endswith("/index.md"):
        prefix = dest[: -len("/index.md")]
        candidates.extend((prefix + "/README.md", prefix))
    if not any(c in nav for c in candidates):
        missing.append(dest)
print("\n".join(missing))
PY
)
  if [ -z "$missing" ]; then
    echo "All mapped dests are listed in SUMMARY.md or docs.json."
    return 0
  fi

  echo "WARNING: mapped dests copied but not in SUMMARY.md or docs.json:" >&2
  echo "$missing" >&2
  echo "Add a sidebar entry in this sync PR or the page will not appear on docs.sodax.com." >&2

  if [ -n "${GITHUB_OUTPUT:-}" ]; then
    {
      echo "nav_missing<<EOF"
      echo "$missing"
      echo "EOF"
    } >> "$GITHUB_OUTPUT"
  fi
}

# Overlay helpers no-op when the map dest moved (e.g. README.md → index.md)
# so a dest-path change fails on nav coverage, not on a missing inject target.
require_or_skip() {
  if [ ! -f "$1" ]; then
    echo "skip overlay (not in tree — map dest may have moved): $1"
    return 1
  fi
  return 0
}

# Helper: prepend GitBook frontmatter to a file (only icon, or icon + description)
# Usage: inject_frontmatter <file> <icon> [description]
inject_frontmatter() {
  require_or_skip "$1" || return 0
  local file="$1" icon="$2" desc="${3:-}"
  local tmp
  tmp=$(mktemp)
  {
    echo "---"
    if [ -n "$desc" ]; then
      echo "description: >-"
      echo "  $desc"
    fi
    echo "icon: $icon"
    echo "---"
    echo ""
    cat "$file"
  } > "$tmp"
  mv "$tmp" "$file"
}

# Helper: prepend GitBook frontmatter (description only, no icon) and a title heading.
# Strips any existing top-level heading (# ...) from the source to avoid duplicates.
# Usage: inject_description_frontmatter <file> <description> <title>
inject_description_frontmatter() {
  require_or_skip "$1" || return 0
  local file="$1" desc="$2" title="$3"
  local tmp
  tmp=$(mktemp)
  {
    echo "---"
    echo "description: $desc"
    echo "---"
    echo ""
    echo "# $title"
    echo ""
    # Strip first line if it's a top-level heading
    sed '1{/^# /d;}' "$file"
  } > "$tmp"
  mv "$tmp" "$file"
}

# Helper: fix relative CONTRIBUTING.md and LICENSE links that GitBook mis-resolves
fix_relative_repo_links() {
  require_or_skip "$1" || return 0
  local file="$1"
  local tmp
  tmp=$(mktemp)
  sed \
    -e 's|\[Contributing Guide\](CONTRIBUTING.md)|[Contributing Guide](https://github.com/icon-project/sodax-sdks/blob/main/CONTRIBUTING.md)|g' \
    -e 's|\[MIT\](LICENSE)|[MIT](https://github.com/icon-project/sodax-sdks/blob/main/LICENSE)|g' \
    "$file" > "$tmp"
  mv "$tmp" "$file"
}

# Helper: fix known broken links in synced files so they resolve correctly in GitBook
fix_synced_links() {
  require_or_skip "$1" || return 0
  local file="$1"
  local tmp
  tmp=$(mktemp)
  sed \
    -e 's|\./developers/how-to/how_to_create_a_spoke_provider|https://docs.sodax.com/developers/how-to/how_to_create_a_spoke_provider|g' \
    -e 's|https://github.com/icon-project/sodax-document/blob/main/developers/packages/sdk/CONTRIBUTING.md|https://github.com/icon-project/sodax-sdks/blob/main/CONTRIBUTING.md|g' \
    -e 's|https://github.com/icon-project/sodax-document/blob/main/developers/packages/sdk/LICENSE/README.md|https://github.com/icon-project/sodax-sdks/blob/main/LICENSE|g' \
    -e 's|https://docs.sodax.com/developers/packages/sdk/swaps|https://docs.sodax.com/developers/packages/foundation/sdk/functional-modules/swaps|g' \
    -e 's|https://docs.sodax.com/developers/packages/sdk/money_market|https://docs.sodax.com/developers/packages/foundation/sdk/functional-modules/money_market|g' \
    -e 's|https://docs.sodax.com/developers/packages/sdk/bridge|https://docs.sodax.com/developers/packages/foundation/sdk/functional-modules/bridge|g' \
    -e 's|https://docs.sodax.com/developers/packages/sdk/staking|https://docs.sodax.com/developers/packages/foundation/sdk/functional-modules/staking|g' \
    -e 's|https://docs.sodax.com/developers/packages/sdk/migration|https://docs.sodax.com/developers/packages/foundation/sdk/functional-modules/migration|g' \
    -e 's|https://docs.sodax.com/developers/packages/sdk/backend_api|https://docs.sodax.com/developers/packages/foundation/sdk/tooling-modules/backend_api|g' \
    -e 's|https://docs.sodax.com/developers/packages/sdk/intent_relay_api|https://docs.sodax.com/developers/packages/foundation/sdk/tooling-modules/intent_relay_api|g' \
    -e 's|https://docs.sodax.com/developers/packages/intent_relay_api|https://docs.sodax.com/developers/packages/foundation/sdk/tooling-modules/intent_relay_api|g' \
    -e 's|https://github.com/icon-project/sodax-frontend/|https://github.com/icon-project/sodax-sdks/|g' \
    "$file" > "$tmp"
  mv "$tmp" "$file"
}

# 3) Remove stale files from old flat-copy sync (not in SUMMARY.md, not from sodax-sdks)
rm -f "$DST/packages/types/README.md"
rm -f "$DST/packages/RELEASE_INSTRUCTIONS.md"
rm -rf "$DST/packages/dapp-kit/src"

# 4) Copy every mirrored page from the upstream map, then inject GitBook
#    frontmatter / link fixes. New map entries are copied even when they have
#    no overlay here (they land without an icon until one is added).
copy_mapped_docs

# Foundation layer
inject_frontmatter "$DST/packages/foundation/sdk/README.md" "cup-straw" \
  "The SODAX SDK provides a comprehensive interface for interacting with the SODAX protocol, enabling cross-chain swaps, money market, cross-chain bridging, migration and staking SODA token."
fix_synced_links "$DST/packages/foundation/sdk/README.md"

inject_frontmatter "$DST/packages/foundation/swaps-api.md" "plug" \
  "Minimal, type-safe HTTP client for the SODAX backend Swaps API v2 — the wire client that @sodax/sdk's sodax.api.swaps wraps."
fix_synced_links "$DST/packages/foundation/swaps-api.md"

# Functional modules
inject_frontmatter "$DST/packages/foundation/sdk/functional-modules/swaps.md"        "rotate"
inject_frontmatter "$DST/packages/foundation/sdk/functional-modules/money_market.md"  "sack-dollar"
inject_frontmatter "$DST/packages/foundation/sdk/functional-modules/bridge.md"        "bridge-suspension"
inject_frontmatter "$DST/packages/foundation/sdk/functional-modules/staking.md"       "seedling"
inject_frontmatter "$DST/packages/foundation/sdk/functional-modules/migration.md"     "truck"
inject_frontmatter "$DST/packages/foundation/sdk/functional-modules/leverage_yield.md"     "money-bill-trend-up"
inject_frontmatter "$DST/packages/foundation/sdk/functional-modules/leverage_yield_apr.md" "percent"

for f in swaps.md money_market.md bridge.md staking.md migration.md leverage_yield.md leverage_yield_apr.md; do
  fix_synced_links "$DST/packages/foundation/sdk/functional-modules/$f"
done

# Tooling modules
inject_frontmatter "$DST/packages/foundation/sdk/tooling-modules/backend_api.md"      "plug"
inject_frontmatter "$DST/packages/foundation/sdk/tooling-modules/intent_relay_api.md"  "envelope"

# Bitcoin Integration (lives under how-to/ to preserve the public URL)
inject_description_frontmatter "$DST/how-to/bitcoin-integration.md" \
  "This guide is a step-by-step walkthrough for integrating Bitcoin as a source or destination chain in a SODAX-powered dApp." \
  "Bitcoin Integration"
fix_synced_links "$DST/how-to/bitcoin-integration.md"

# AI Integration
inject_frontmatter "$DST/ai-integration/README.md" "robot" \
  "Every @sodax/* package on npm ships AI-readable docs at ai-exported/. Point Cursor, Claude Code, Copilot, or another coding agent at those files for v2-correct SDK code on the first try."

# Connection layer
inject_frontmatter "$DST/packages/connection/wallet-sdk-core.md"  "wallet"
inject_frontmatter "$DST/packages/connection/wallet-sdk-react.md" "react"
fix_relative_repo_links "$DST/packages/connection/wallet-sdk-react.md"

# Experience layer
inject_frontmatter "$DST/packages/experience/dapp-kit.md" "browser"
fix_relative_repo_links "$DST/packages/experience/dapp-kit.md"

inject_frontmatter "$DST/packages/experience/skills.md" "robot" \
  "Consumer-facing AI skills and knowledge so coding agents (Claude Code, Cursor, Copilot, Codex) write v2-correct @sodax/* SDK code."
fix_relative_repo_links "$DST/packages/experience/skills.md"

# 10) Audits (Markdown + PDF files, preserving directory structure)
AUDITS_SRC="$SRC/Audits"
AUDITS_DST="$DST/audits"
find "$AUDITS_SRC" -type f \( -name '*.md' -o -name '*.pdf' \) -print0 | while IFS= read -r -d '' filepath; do
  relpath="${filepath#"$AUDITS_SRC"/}"
  case "$relpath" in
    *..*) echo "ERROR: refusing audit path: $relpath" >&2; exit 1 ;;
  esac
  copy_file "$filepath" "$AUDITS_DST/$relpath"
done

# 11) GitHub Wiki pages → Deployments
# The source repos are private, so cloning their wikis needs an SSH key with
# access. CI runners don't have one — the sync workflow sets SKIP_WIKI_SYNC=1
# and these two pages stay manual (run the script locally to refresh them).
if [ "${SKIP_WIKI_SYNC:-0}" = "1" ]; then
  echo "SKIP_WIKI_SYNC=1 — skipping wiki-sourced deployments pages (mainnet.md, solver-compatible-assets.md)"
else
  WIKI_TMP=$(mktemp -d)
  trap 'rm -rf "$WIKI_TMP"' EXIT

  git clone --depth 1 git@github.com:icon-project/sodax-contracts.wiki.git "$WIKI_TMP/sodax-contracts-wiki"
  git clone --depth 1 git@github.com:icon-project/sodax-solver.wiki.git   "$WIKI_TMP/sodax-solver-wiki"

  copy_file "$WIKI_TMP/sodax-contracts-wiki/Mainnet.md"                "$DST/deployments/mainnet.md"
  copy_file "$WIKI_TMP/sodax-solver-wiki/Solver:-Compatible-Assets.md" "$DST/deployments/solver-compatible-assets.md"

  inject_description_frontmatter "$DST/deployments/mainnet.md" \
    "Mainnet smart contract deployments." "Mainnet"
  inject_description_frontmatter "$DST/deployments/solver-compatible-assets.md" \
    "Assets (tokens) supported by mainnet solver (swaps)." "Swap: Compatible Assets"
fi

check_nav_coverage

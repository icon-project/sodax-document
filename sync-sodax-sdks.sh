#!/usr/bin/env bash
set -euo pipefail

# Update the SDK submodule, then fast-forward it to origin/main.
git submodule sync
git submodule update --init linked-repositories/sodax-sdks

# Recreate `main` even when the submodule is in detached HEAD.
(
  cd linked-repositories/sodax-sdks
  git fetch origin main
  git checkout -B main origin/main
)

SRC="linked-repositories/sodax-sdks"
DST="developers"
MAP_FILE="$SRC/scripts/gitbook-sync-map.json"

# Copy one file and refuse symlink sources or dests.
copy_file() {
  if [ -L "$1" ]; then
    echo "ERROR: refusing to copy symlink: $1" >&2
    exit 1
  fi
  mkdir -p "$(dirname "$2")"
  if [ -L "$2" ]; then
    echo "ERROR: refusing to write through dest symlink: $2" >&2
    exit 1
  fi
  cp -f -- "$1" "$2"
}

# Copy every mirrored doc listed in the upstream sync map.
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
    if not isinstance(src, str) or not isinstance(dest, str):
        sys.exit("gitbook-sync-map.json src and dest must be strings")
    if any(c in src or c in dest for c in "\t\n\r"):
        sys.exit(f"invalid map path characters: {src!r} -> {dest!r}")
    print(f"{src}\t{dest}")
PY
)
}

# Warn when a copied page is missing from SUMMARY.md or docs.json.
# Keep the file in the PR so a human can add the nav entry.
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

# Skip overlays when the mapped destination moved.
require_or_skip() {
  if [ ! -f "$1" ]; then
    echo "skip overlay (not in tree — map dest may have moved): $1"
    return 1
  fi
  return 0
}

# Print FILE with a leading YAML frontmatter block removed.
# Pass a second argument of "h1" to also drop a duplicated top-level heading.
strip_overlay_body() {
  python3 - "$1" "${2:-}" <<'PY'
import re, sys
from pathlib import Path

text = Path(sys.argv[1]).read_text(encoding="utf-8")
match = re.match(r"^---\r?\n.*?\r?\n---\r?\n?", text, re.DOTALL)
if match:
    text = text[match.end():].lstrip("\r\n")
if sys.argv[2] == "h1" and text.startswith("# "):
    text = text.split("\n", 1)[1] if "\n" in text else ""
    text = text.lstrip("\r\n")
sys.stdout.write(text)
PY
}

# Prepend GitBook frontmatter: icon, with optional description.
inject_frontmatter() {
  require_or_skip "$1" || return 0
  local file="$1" icon="$2" desc="${3:-}"
  local tmp body
  tmp=$(mktemp)
  body=$(mktemp)
  strip_overlay_body "$file" > "$body"
  {
    echo "---"
    if [ -n "$desc" ]; then
      echo "description: >-"
      echo "  $desc"
    fi
    echo "icon: $icon"
    echo "---"
    echo ""
    cat "$body"
  } > "$tmp"
  mv "$tmp" "$file"
  rm -f "$body"
}

# Replace description-only frontmatter and a single page title.
inject_description_frontmatter() {
  require_or_skip "$1" || return 0
  local file="$1" desc="$2" title="$3"
  local tmp body
  tmp=$(mktemp)
  body=$(mktemp)
  strip_overlay_body "$file" h1 > "$body"
  {
    echo "---"
    echo "description: $desc"
    echo "---"
    echo ""
    echo "# $title"
    echo ""
    cat "$body"
  } > "$tmp"
  mv "$tmp" "$file"
  rm -f "$body"
}

# Rewrite repo-root links GitBook mis-resolves.
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

# Rewrite known broken links in synced pages.
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

# Remove leftovers from the old flat-copy layout.
rm -f "$DST/packages/types/README.md"
rm -f "$DST/packages/RELEASE_INSTRUCTIONS.md"
rm -rf "$DST/packages/dapp-kit/src"

# Copy mapped pages first, then apply local overlays.
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

# Keep Bitcoin Integration under how-to/ for its public URL.
inject_description_frontmatter "$DST/how-to/bitcoin-integration.md" \
  "This guide is a step-by-step walkthrough for integrating Bitcoin as a source or destination chain in a SODAX-powered dApp." \
  "Bitcoin Integration"
fix_synced_links "$DST/how-to/bitcoin-integration.md"

# AI Integration
inject_frontmatter "$DST/ai-integration/README.md" "robot" \
  "Every @sodax/* package on npm ships AI-readable docs at ai-exported/. Point Cursor, Claude Code, Copilot, or another coding agent at those files for v2-correct SDK code on the first try."

# Not yet on gitbook-sync-map.json; copy until upstream adds the dest.
copy_file "$SRC/docs/stellar-sponsoring-getting-started.md" \
  "$DST/how-to/stellar-sponsoring-getting-started.md"
inject_description_frontmatter "$DST/how-to/stellar-sponsoring-getting-started.md" \
  "A getting-started guide for activating sponsored Stellar accounts and integrating the SODAX Sponsoring API via dapp-kit, the SDK, or raw HTTP." \
  "Stellar Sponsoring - Getting Started"
fix_synced_links "$DST/how-to/stellar-sponsoring-getting-started.md"

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

# Audits are not on gitbook-sync-map.json. Copy the upstream Audits tree
# as-is; nav coverage does not warn for these files.
AUDITS_SRC="$SRC/Audits"
AUDITS_DST="$DST/audits"
find "$AUDITS_SRC" -type f \( -name '*.md' -o -name '*.pdf' \) -print0 | while IFS= read -r -d '' filepath; do
  relpath="${filepath#"$AUDITS_SRC"/}"
  case "$relpath" in
    *..*) echo "ERROR: refusing audit path: $relpath" >&2; exit 1 ;;
  esac
  copy_file "$filepath" "$AUDITS_DST/$relpath"
done

# Wiki-backed deployment pages stay manual in CI.
# Local runs can refresh them with SSH access to the private wikis.
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

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

# Icon given to a mapped page that no inject_frontmatter call below claims.
DEFAULT_SYNC_ICON="file-lines"

# GitBook dests in gitbook-sync-map.json → Mintlify paths on this branch.
# Drop this table at cutover once the map dests in sodax-sdks are rewritten.
# README.md → index.md (Mintlify folder indexes)
# ai-integration/README.md → flat .md (frontmatter icon + sidebarTitle)
# Relayer/Solver: one dest under Deployments (nav already points here; GitBook
# still lists packages/sdk/docs/* — docs.json redirects cover those URLs).
DEST_REMAP_PY='
DEST_REMAP = {
    "developers/packages/foundation/sdk/README.md": "developers/packages/foundation/sdk/index.md",
    "developers/ai-integration/README.md": "developers/ai-integration.md",
    "developers/packages/sdk/docs/RELAYER_API_ENDPOINTS.md": "developers/deployments/relayer-api-endpoints.md",
    "developers/packages/sdk/docs/SOLVER_API_ENDPOINTS.md": "developers/deployments/solver-api-endpoints.md",
}
'

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

# Copy src → dest only when dest is not already in the tree (map may have added it).
copy_if_missing() {
  local src="$1" dest="$2"
  if [ -f "$dest" ]; then
    echo "already present (mapped or previous copy): $dest"
    return 0
  fi
  if [ ! -f "$src" ]; then
    echo "skip missing source: $src"
    return 0
  fi
  echo "copy $src -> $dest (not yet on gitbook-sync-map.json)"
  copy_file "$src" "$dest"
}

# Copy every mirrored doc listed in the upstream sync map, remapping dests for Mintlify.
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
  done < <(python3 - "$MAP_FILE" <<PY
import json, sys
$DEST_REMAP_PY
with open(sys.argv[1], encoding="utf-8") as fh:
    data = json.load(fh)
for item in data.get("mirrored", []):
    src, dest = item.get("src"), item.get("dest")
    if not src or not dest:
        sys.exit("gitbook-sync-map.json entry missing src or dest")
    if not isinstance(src, str) or not isinstance(dest, str):
        sys.exit("gitbook-sync-map.json src and dest must be strings")
    if any(c in src or c in dest for c in "\\t\\n\\r"):
        sys.exit(f"invalid map path characters: {src!r} -> {dest!r}")
    dest = DEST_REMAP.get(dest, dest)
    print(f"{src}\\t{dest}")
PY
)
}

# Warn when a copied page is missing from docs.json (Mintlify) or SUMMARY.md (GitBook leftover).
check_nav_coverage() {
  local missing
  missing=$(python3 - "$MAP_FILE" <<PY
import json, pathlib, sys
$DEST_REMAP_PY
map_path = sys.argv[1]
summary = pathlib.Path("SUMMARY.md").read_text(encoding="utf-8") if pathlib.Path("SUMMARY.md").exists() else ""
docs = pathlib.Path("docs.json").read_text(encoding="utf-8") if pathlib.Path("docs.json").exists() else ""
nav = summary + "\\n" + docs

with open(map_path, encoding="utf-8") as fh:
    data = json.load(fh)

extra = [
    "developers/how-to/stellar-sponsoring-getting-started.md",
    "developers/how-to/quick-sponsoring-stellar-guide.md",
]
dests = []
for item in data.get("mirrored", []):
    dest = item.get("dest") or ""
    dests.append(DEST_REMAP.get(dest, dest))
for dest in extra:
    if pathlib.Path(dest).is_file():
        dests.append(dest)

missing = []
seen = set()
for dest in dests:
    if dest in seen:
        continue
    seen.add(dest)
    stem = dest[:-3] if dest.endswith(".md") else dest
    candidates = [dest, stem]
    if dest.endswith("/README.md"):
        prefix = dest[: -len("/README.md")]
        candidates.extend((prefix, prefix + "/index", prefix + ".md"))
    if dest.endswith("/index.md"):
        prefix = dest[: -len("/index.md")]
        candidates.extend((prefix + "/README.md", prefix))
    if dest.endswith(".md") and not dest.endswith("/index.md"):
        candidates.append(dest[:-3])
    if not any(c in nav for c in candidates):
        missing.append(dest)
print("\\n".join(missing))
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

# Prepend Mintlify frontmatter (title, optional icon, optional description, optional sidebarTitle).
# Usage: inject_frontmatter <file> <icon> <title> [description] [sidebarTitle]
inject_frontmatter() {
  require_or_skip "$1" || return 0
  local file="$1" icon="$2" title="$3" desc="${4:-}" sidebar="${5:-}"
  local tmp body
  tmp=$(mktemp)
  body=$(mktemp)
  strip_overlay_body "$file" h1 > "$body"
  {
    echo "---"
    echo "title: \"$title\""
    if [ -n "$sidebar" ]; then
      echo "sidebarTitle: \"$sidebar\""
    fi
    if [ -n "$desc" ]; then
      echo "description: >-"
      echo "  $desc"
    fi
    if [ -n "$icon" ]; then
      echo "icon: $icon"
    fi
    echo "---"
    echo ""
    cat "$body"
  } > "$tmp"
  mv "$tmp" "$file"
  rm -f "$body"
}

# Replace description-only frontmatter and a single page title.
# Usage: inject_description_frontmatter <file> <description> <title> [icon]
inject_description_frontmatter() {
  require_or_skip "$1" || return 0
  local file="$1" desc="$2" title="$3" icon="${4:-}"
  local tmp body
  tmp=$(mktemp)
  body=$(mktemp)
  strip_overlay_body "$file" h1 > "$body"
  {
    echo "---"
    echo "title: \"$title\""
    echo "description: $desc"
    if [ -n "$icon" ]; then
      echo "icon: $icon"
    fi
    echo "---"
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
# Also rewrite <https://...> autolinks — Mintlify compiles Markdown as MDX, so those
# tags 404 the whole page instead of rendering a link.
# Strip top-of-page "Error handling conventions" banners (SDK-internal; Error
# Handling sections already cover this).
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
    -e 's|\[`docs/quick-sponsoring-stellar-guide.md`\](https://github.com/icon-project/sodax-sdks/blob/main/docs/quick-sponsoring-stellar-guide.md)|[Sponsored Stellar account activation](/developers/how-to/quick-sponsoring-stellar-guide)|g' \
    -e 's|<\(https://[^>]*\)>|[\1](\1)|g' \
    -e '/^> \*\*Error handling conventions:/d' \
    "$file" > "$tmp"
  mv "$tmp" "$file"
}

# Print every mapped destination, remapped for Mintlify, one per line.
map_dests() {
  python3 - "$MAP_FILE" <<PY
import json, pathlib, sys
$DEST_REMAP_PY
with open(sys.argv[1], encoding="utf-8") as fh:
    data = json.load(fh)
extra = [
    "developers/how-to/stellar-sponsoring-getting-started.md",
    "developers/how-to/quick-sponsoring-stellar-guide.md",
]
seen = set()
for item in data.get("mirrored", []):
    dest = DEST_REMAP.get(item.get("dest") or "", item.get("dest") or "")
    if dest and dest not in seen:
        seen.add(dest)
        print(dest)
for dest in extra:
    if dest not in seen and pathlib.Path(dest).is_file():
        seen.add(dest)
        print(dest)
PY
}

# Title any mapped page that no inject_frontmatter call above claimed, taking the
# title from the page's own H1. Without this a new page on sodax-sdks' map lands
# with no frontmatter at all: it renders, but Mintlify has no sidebar label for
# it until someone adds an overlay call here. Explicit calls always win — this
# only fills the gap, so adding a page upstream needs no edit in this repo.
title_unclaimed_pages() {
  local dest title first
  local defaulted="" untitled=""

  while IFS= read -r dest; do
    [ -n "$dest" ] || continue
    case "$dest" in *.md) ;; *) continue ;; esac
    [ -f "$dest" ] || continue

    # An overlay call above already wrote frontmatter for this page.
    first=$(head -n 1 "$dest")
    [ "$first" = "---" ] && continue

    title=$(python3 - "$dest" <<'PY'
import re, sys
from pathlib import Path

title = ""
for line in Path(sys.argv[1]).read_text(encoding="utf-8").splitlines():
    if line.startswith("# "):
        title = line[2:]
        break
# chr(96) is a backtick: literal ones break the enclosing $( ) in bash.
# Backticks and double quotes would both break the YAML title this becomes.
title = title.replace(chr(96), "").replace(chr(34), "'")
sys.stdout.write(re.sub(r"\s+", " ", title).strip())
PY
)

    if [ -z "$title" ]; then
      untitled="$untitled$dest"$'\n'
      continue
    fi

    inject_frontmatter "$dest" "$DEFAULT_SYNC_ICON" "$title"
    defaulted="$defaulted$dest -> \"$title\""$'\n'
  done < <(map_dests)

  if [ -n "$defaulted" ]; then
    echo "Titled from each page's own H1 (no overlay call in this script):"
    printf '%s' "$defaulted"
    if [ -n "${GITHUB_OUTPUT:-}" ]; then
      {
        echo "titles_defaulted<<EOF"
        printf '%s' "$defaulted"
        echo "EOF"
      } >> "$GITHUB_OUTPUT"
    fi
  fi

  if [ -n "$untitled" ]; then
    echo "WARNING: mapped page has neither frontmatter nor an H1 - it will land untitled:" >&2
    printf '%s' "$untitled" >&2
    echo "Add a '# Heading' to the source in sodax-sdks, or an inject_frontmatter call here." >&2
  fi
}

# Remove leftovers from the old flat-copy layout and dual Relayer/Solver dests.
rm -f "$DST/packages/types/README.md"
rm -f "$DST/packages/RELEASE_INSTRUCTIONS.md"
rm -rf "$DST/packages/dapp-kit/src"
rm -f "$DST/packages/sdk/docs/RELAYER_API_ENDPOINTS.md"
rm -f "$DST/packages/sdk/docs/SOLVER_API_ENDPOINTS.md"
rm -f "$DST/ai-integration/README.md"

# Copy mapped pages first, then apply local overlays.
copy_mapped_docs

# Pages already on GitBook / sodax-sdks#383 but not yet on sodax-sdks main's map.
copy_if_missing "$SRC/docs/stellar-sponsoring-getting-started.md" \
  "$DST/how-to/stellar-sponsoring-getting-started.md"
copy_if_missing "$SRC/docs/quick-sponsoring-stellar-guide.md" \
  "$DST/how-to/quick-sponsoring-stellar-guide.md"

# Foundation layer
inject_frontmatter "$DST/packages/foundation/sdk/index.md" "cup-straw" "@sodax/sdk" \
  "The SODAX SDK provides a comprehensive interface for interacting with the SODAX protocol, enabling cross-chain swaps, money market, cross-chain bridging, migration and staking SODA token."
fix_synced_links "$DST/packages/foundation/sdk/index.md"
# Solver ownership language: module label is "Swaps", not "Swaps (Solver)"
if [ -f "$DST/packages/foundation/sdk/index.md" ]; then
  _swaps_label_tmp=$(mktemp)
  sed 's/Swaps (Solver)/Swaps/g' "$DST/packages/foundation/sdk/index.md" > "$_swaps_label_tmp"
  mv "$_swaps_label_tmp" "$DST/packages/foundation/sdk/index.md"
fi

inject_frontmatter "$DST/packages/foundation/swaps-api.md" "plug" "@sodax/swaps-api" \
  "Minimal, type-safe HTTP client for the SODAX backend Swaps API v2 — the wire client that @sodax/sdk's sodax.api.swaps wraps."
fix_synced_links "$DST/packages/foundation/swaps-api.md"

# Functional modules
inject_frontmatter "$DST/packages/foundation/sdk/functional-modules/swaps.md"        "rotate"             "Swaps" \
  "Quote and execute cross-network intents. SODAX routes and settles; solvers on the marketplace fill."
inject_frontmatter "$DST/packages/foundation/sdk/functional-modules/money_market.md"  "sack-dollar"         "Money Market"
inject_frontmatter "$DST/packages/foundation/sdk/functional-modules/bridge.md"        "bridge-suspension"   "Bridge"
inject_frontmatter "$DST/packages/foundation/sdk/functional-modules/staking.md"       "seedling"            "Staking"
inject_frontmatter "$DST/packages/foundation/sdk/functional-modules/migration.md"     "truck"               "Migration"
inject_frontmatter "$DST/packages/foundation/sdk/functional-modules/leverage_yield.md"     "money-bill-trend-up" "Leverage Yield"
inject_frontmatter "$DST/packages/foundation/sdk/functional-modules/leverage_yield_apr.md" "percent"             "Leverage-Yield Effective APR"

for f in swaps.md money_market.md bridge.md staking.md migration.md leverage_yield.md leverage_yield_apr.md; do
  fix_synced_links "$DST/packages/foundation/sdk/functional-modules/$f"
done

# Tooling modules
inject_frontmatter "$DST/packages/foundation/sdk/tooling-modules/backend_api.md"      "plug"     "Backend API"
inject_frontmatter "$DST/packages/foundation/sdk/tooling-modules/intent_relay_api.md"  "envelope" "Intent Relay API"

# How-to guides (stay at sdk/docs/, preserve names)
inject_frontmatter "$DST/packages/sdk/docs/CONFIGURE_SDK.md"          "sliders"    "Configure SDK"
inject_frontmatter "$DST/packages/sdk/docs/ESTIMATE_GAS.md"           "gauge-high" "Estimate Gas"
inject_frontmatter "$DST/packages/sdk/docs/HOW_TO_MAKE_A_SWAP.md"     "rotate"     "How to Make a Swap"
inject_frontmatter "$DST/packages/sdk/docs/MONETIZE_SDK.md"           "coins"      "Monetize SDK"
inject_frontmatter "$DST/packages/sdk/docs/WALLET_PROVIDERS.md"       "wallet"     "Wallet Providers"
inject_frontmatter "$DST/packages/sdk/docs/STELLAR_TRUSTLINE.md"      "link"       "Stellar Trustline Requirements"
inject_frontmatter "$DST/packages/sdk/docs/installation/nextjs.md"    "box"        "Installing @sodax/sdk with Next.js"

# Relayer / Solver — remapped onto Deployments (single dest).
inject_frontmatter "$DST/deployments/relayer-api-endpoints.md" "envelope" "Relayer API Endpoints" \
  "Intent relay hosts and SDK integration for submitting spoke-chain transactions to the SODAX hub."
inject_frontmatter "$DST/deployments/solver-api-endpoints.md" "server" "Solver API Endpoints" \
  "REST API endpoints for requesting quotes and tracking intent fills on the solver marketplace."
fix_synced_links "$DST/deployments/relayer-api-endpoints.md"
fix_synced_links "$DST/deployments/solver-api-endpoints.md"

# Keep Bitcoin Integration under how-to/ for its public URL.
inject_description_frontmatter "$DST/how-to/bitcoin-integration.md" \
  "This guide is a step-by-step walkthrough for integrating Bitcoin as a source or destination chain in a SODAX-powered dApp." \
  "Bitcoin Integration" \
  "bitcoin"
fix_synced_links "$DST/how-to/bitcoin-integration.md"

inject_description_frontmatter "$DST/how-to/stellar-sponsoring-getting-started.md" \
  "A getting-started guide for activating sponsored Stellar accounts and integrating the SODAX Sponsoring API via dapp-kit, the SDK, or raw HTTP." \
  "Stellar Sponsoring" \
  "star"
fix_synced_links "$DST/how-to/stellar-sponsoring-getting-started.md"

inject_frontmatter "$DST/how-to/quick-sponsoring-stellar-guide.md" "bolt" "Sponsored Stellar account activation" \
  "Short reference for Stellar account activation: ordered steps, SDK surface, React hooks, and gotchas." \
  "Stellar sponsoring (quick)"
fix_synced_links "$DST/how-to/quick-sponsoring-stellar-guide.md"

# AI Integration — flat .md so Mintlify picks up frontmatter icon + sidebarTitle.
inject_frontmatter "$DST/ai-integration.md" "robot" "AI Integration" \
  "Install @sodax/skills (CLI or npm) so Cursor, Claude Code, Copilot, and other agents write v2-correct @sodax/* code instead of stale training-data APIs." \
  "AI Integration"
if [ -f "$DST/ai-integration.md" ]; then
  _ai_tmp=$(mktemp)
  sed \
    -e 's/^### skills CLI/### Skills CLI/' \
    -e 's/^### npm from the registry/### Install from npm/' \
    "$DST/ai-integration.md" > "$_ai_tmp"
  mv "$_ai_tmp" "$DST/ai-integration.md"
fi

# Connection layer
inject_frontmatter "$DST/packages/connection/wallet-sdk-core.md"  "wallet" "@sodax/wallet-sdk-core"
inject_frontmatter "$DST/packages/connection/wallet-sdk-react.md" "react"  "@sodax/wallet-sdk-react"
fix_relative_repo_links "$DST/packages/connection/wallet-sdk-react.md"

# Experience layer
inject_frontmatter "$DST/packages/experience/dapp-kit.md" "browser" "@sodax/dapp-kit"
fix_relative_repo_links "$DST/packages/experience/dapp-kit.md"

inject_frontmatter "$DST/packages/experience/skills.md" "robot" "@sodax/skills" \
  "Consumer-facing AI skills and knowledge so coding agents (Claude Code, Cursor, Copilot, Codex) write v2-correct @sodax/* SDK code."
fix_relative_repo_links "$DST/packages/experience/skills.md"

# Audits — PDFs only. Landing page (developers/audits/index.md) is
# hand-maintained in sodax-document (firm names + trust narrative); do not
# overwrite it from Audits/Readme.md.
AUDITS_SRC="$SRC/Audits"
AUDITS_DST="$DST/audits"
find "$AUDITS_SRC" -type f -name '*.pdf' -print0 | while IFS= read -r -d '' filepath; do
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
    "Mainnet smart contract deployments." "Mainnet" "globe"
  inject_description_frontmatter "$DST/deployments/solver-compatible-assets.md" \
    "Assets (tokens) supported for swaps by solvers on mainnet." "Swap: Compatible Assets" "coins"
fi

# Fill in titles for mapped pages no overlay above claimed.
title_unclaimed_pages

check_nav_coverage

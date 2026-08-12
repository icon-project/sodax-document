set -euo pipefail

# 1) Make sure submodule URL and pointer are up to date and fetch latest changes from origin/main
git submodule sync --recursive
git submodule update --init --recursive linked-repositories/sodax-sdks

# Fetch the latest main branch from the submodule's origin and reset submodule worktree to origin/main
(
  cd linked-repositories/sodax-sdks
  git fetch origin main
  git checkout main
  git reset --hard origin/main
  git pull origin main
)

# 2) Define paths
SRC="linked-repositories/sodax-sdks"
DST="developers"

# Helper: copy a single file, creating parent directories as needed
copy_file() {
  mkdir -p "$(dirname "$2")"
  cp -f "$1" "$2"
}

# Helper: prepend Mintlify frontmatter (title, optional icon, optional description, optional sidebarTitle).
# Strips a duplicate leading top-level heading (# ...) from the source — Mintlify
# renders frontmatter `title` as the page header, so a matching body H1 would repeat it.
# Usage: inject_frontmatter <file> <icon> <title> [description] [sidebarTitle]
inject_frontmatter() {
  local file="$1" icon="$2" title="$3" desc="${4:-}" sidebar="${5:-}"
  local tmp
  tmp=$(mktemp)
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
    # Strip first line if it's a top-level heading (avoids duplicating the frontmatter title)
    sed '1{/^# /d;}' "$file"
  } > "$tmp"
  mv "$tmp" "$file"
}

# Helper: prepend Mintlify frontmatter (title + description, optional icon).
# Strips any existing top-level heading (# ...) from the source to avoid duplicating
# the frontmatter title in the page body.
# Usage: inject_description_frontmatter <file> <description> <title> [icon]
inject_description_frontmatter() {
  local file="$1" desc="$2" title="$3" icon="${4:-}"
  local tmp
  tmp=$(mktemp)
  {
    echo "---"
    echo "title: \"$title\""
    echo "description: $desc"
    if [ -n "$icon" ]; then
      echo "icon: $icon"
    fi
    echo "---"
    echo ""
    # Strip first line if it's a top-level heading
    sed '1{/^# /d;}' "$file"
  } > "$tmp"
  mv "$tmp" "$file"
}

# Helper: fix relative CONTRIBUTING.md and LICENSE links that GitBook mis-resolves
fix_relative_repo_links() {
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

# 4) SDK README → Foundation layer
# Lives at index.md, not README.md — Mintlify's file-based routing needs index.md/index.mdx
# to serve as a directory's default page; docs.json's nav entry expects that path.
copy_file "$SRC/packages/sdk/README.md" "$DST/packages/foundation/sdk/index.md"
inject_frontmatter "$DST/packages/foundation/sdk/index.md" "cup-straw" "@sodax/sdk" \
  "The SODAX SDK provides a comprehensive interface for interacting with the SODAX protocol, enabling cross-chain swaps, money market, cross-chain bridging, migration and staking SODA token."
fix_synced_links "$DST/packages/foundation/sdk/index.md"
# Solver ownership language: module label is "Swaps", not "Swaps (Solver)"
_swaps_label_tmp=$(mktemp)
sed 's/Swaps (Solver)/Swaps/g' "$DST/packages/foundation/sdk/index.md" > "$_swaps_label_tmp"
mv "$_swaps_label_tmp" "$DST/packages/foundation/sdk/index.md"

# 4b) swaps-api README → Foundation layer (standalone Swaps API v2 wire client)
copy_file "$SRC/packages/swaps-api/README.md" "$DST/packages/foundation/swaps-api.md"
inject_frontmatter "$DST/packages/foundation/swaps-api.md" "plug" "@sodax/swaps-api" \
  "Minimal, type-safe HTTP client for the SODAX backend Swaps API v2 — the wire client that @sodax/sdk's sodax.api.swaps wraps."
fix_synced_links "$DST/packages/foundation/swaps-api.md"

# 5) Functional modules (sdk/docs → foundation/sdk/functional-modules, lowercased)
copy_file "$SRC/packages/sdk/docs/SWAPS.md"        "$DST/packages/foundation/sdk/functional-modules/swaps.md"
copy_file "$SRC/packages/sdk/docs/MONEY_MARKET.md"  "$DST/packages/foundation/sdk/functional-modules/money_market.md"
copy_file "$SRC/packages/sdk/docs/BRIDGE.md"        "$DST/packages/foundation/sdk/functional-modules/bridge.md"
copy_file "$SRC/packages/sdk/docs/STAKING.md"       "$DST/packages/foundation/sdk/functional-modules/staking.md"
copy_file "$SRC/packages/sdk/docs/MIGRATION.md"     "$DST/packages/foundation/sdk/functional-modules/migration.md"
copy_file "$SRC/packages/sdk/docs/LEVERAGE_YIELD.md"     "$DST/packages/foundation/sdk/functional-modules/leverage_yield.md"
copy_file "$SRC/packages/sdk/docs/LEVERAGE_YIELD_APR.md" "$DST/packages/foundation/sdk/functional-modules/leverage_yield_apr.md"

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

# 6) Tooling modules (sdk/docs → foundation/sdk/tooling-modules, lowercased)
copy_file "$SRC/packages/sdk/docs/BACKEND_API.md"      "$DST/packages/foundation/sdk/tooling-modules/backend_api.md"
copy_file "$SRC/packages/sdk/docs/INTENT_RELAY_API.md"  "$DST/packages/foundation/sdk/tooling-modules/intent_relay_api.md"

inject_frontmatter "$DST/packages/foundation/sdk/tooling-modules/backend_api.md"      "plug"     "Backend API"
inject_frontmatter "$DST/packages/foundation/sdk/tooling-modules/intent_relay_api.md"  "envelope" "Intent Relay API"

# 7) How-to guides (stay at sdk/docs/, preserve names)
# Note: HOW_TO_CREATE_A_SPOKE_PROVIDER.md is no longer present in sodax-sdks.
for f in CONFIGURE_SDK ESTIMATE_GAS HOW_TO_MAKE_A_SWAP \
         MONETIZE_SDK WALLET_PROVIDERS STELLAR_TRUSTLINE \
         RELAYER_API_ENDPOINTS SOLVER_API_ENDPOINTS; do
  copy_file "$SRC/packages/sdk/docs/${f}.md" "$DST/packages/sdk/docs/${f}.md"
done
copy_file "$SRC/packages/sdk/docs/installation/nextjs.md" "$DST/packages/sdk/docs/installation/nextjs.md"

inject_frontmatter "$DST/packages/sdk/docs/CONFIGURE_SDK.md"          "sliders"    "Configure SDK"
inject_frontmatter "$DST/packages/sdk/docs/ESTIMATE_GAS.md"           "gauge-high" "Estimate Gas"
inject_frontmatter "$DST/packages/sdk/docs/HOW_TO_MAKE_A_SWAP.md"     "rotate"     "How to Make a Swap"
inject_frontmatter "$DST/packages/sdk/docs/MONETIZE_SDK.md"           "coins"      "Monetize SDK"
inject_frontmatter "$DST/packages/sdk/docs/WALLET_PROVIDERS.md"       "wallet"     "Wallet Providers"
inject_frontmatter "$DST/packages/sdk/docs/STELLAR_TRUSTLINE.md"      "link"       "Stellar Trustline Requirements"
inject_frontmatter "$DST/packages/sdk/docs/RELAYER_API_ENDPOINTS.md"  "envelope"   "Relayer API Endpoints"
inject_frontmatter "$DST/packages/sdk/docs/SOLVER_API_ENDPOINTS.md"   "server"     "Solver API Endpoints"
inject_frontmatter "$DST/packages/sdk/docs/installation/nextjs.md"    "box"        "Installing @sodax/sdk with Next.js"

# 7b) Bitcoin Integration (sdk/docs/BITCOIN_INTEGRATION.md → how-to/bitcoin-integration.md)
# Lives under how-to/ to preserve the public docs.sodax.com URL.
copy_file "$SRC/packages/sdk/docs/BITCOIN_INTEGRATION.md" "$DST/how-to/bitcoin-integration.md"
inject_description_frontmatter "$DST/how-to/bitcoin-integration.md" \
  "This guide is a step-by-step walkthrough for integrating Bitcoin as a source or destination chain in a SODAX-powered dApp." \
  "Bitcoin Integration" \
  "bitcoin"
fix_synced_links "$DST/how-to/bitcoin-integration.md"

# 7c) AI Integration (sodax-sdks/docs/ai-integration-guide.md → developers/ai-integration.md)
# Flat .md (not a folder/index) so Mintlify picks up frontmatter icon + sidebarTitle in the nav.
# sidebarTitle keeps "AI" capitalized (path-derived title would be "Ai integration").
copy_file "$SRC/docs/ai-integration-guide.md" "$DST/ai-integration.md"
inject_frontmatter "$DST/ai-integration.md" "robot" "AI Integration" \
  "Install @sodax/skills (CLI or npm) so Cursor, Claude Code, Copilot, and other agents write v2-correct @sodax/* code instead of stale training-data APIs." \
  "AI Integration"
# Normalize Install subsection titles for TOC consistency (sentence case).
_ai_tmp=$(mktemp)
sed \
  -e 's/^### skills CLI/### Skills CLI/' \
  -e 's/^### npm from the registry/### Install from npm/' \
  "$DST/ai-integration.md" > "$_ai_tmp"
mv "$_ai_tmp" "$DST/ai-integration.md"

# 8) Connection layer
copy_file "$SRC/packages/wallet-sdk-core/README.md"  "$DST/packages/connection/wallet-sdk-core.md"
copy_file "$SRC/packages/wallet-sdk-react/README.md" "$DST/packages/connection/wallet-sdk-react.md"

inject_frontmatter "$DST/packages/connection/wallet-sdk-core.md"  "wallet" "@sodax/wallet-sdk-core"
inject_frontmatter "$DST/packages/connection/wallet-sdk-react.md" "react"  "@sodax/wallet-sdk-react"

fix_relative_repo_links "$DST/packages/connection/wallet-sdk-react.md"

# 9) Experience layer
copy_file "$SRC/packages/dapp-kit/README.md" "$DST/packages/experience/dapp-kit.md"

inject_frontmatter "$DST/packages/experience/dapp-kit.md" "browser" "@sodax/dapp-kit"

fix_relative_repo_links "$DST/packages/experience/dapp-kit.md"

# 9b) skills README → Experience layer (AI-agent skills bundle)
copy_file "$SRC/packages/skills/README.md" "$DST/packages/experience/skills.md"
inject_frontmatter "$DST/packages/experience/skills.md" "robot" "@sodax/skills" \
  "Consumer-facing AI skills and knowledge so coding agents (Claude Code, Cursor, Copilot, Codex) write v2-correct @sodax/* SDK code."
fix_relative_repo_links "$DST/packages/experience/skills.md"

# 10) Audits — PDFs only. Landing page (developers/audits/index.md) is
# hand-maintained in sodax-document (firm names + trust narrative); do not
# overwrite it from Audits/Readme.md.
AUDITS_SRC="$SRC/Audits"
AUDITS_DST="$DST/audits"
find "$AUDITS_SRC" -type f -name '*.pdf' -print0 | while IFS= read -r -d '' filepath; do
  relpath="${filepath#"$AUDITS_SRC"/}"
  copy_file "$filepath" "$AUDITS_DST/$relpath"
done

# 11) GitHub Wiki pages → Deployments
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

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

# Helper: prepend GitBook frontmatter to a file (only icon, or icon + description)
# Usage: inject_frontmatter <file> <icon> [description]
inject_frontmatter() {
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
# Orphans that keep getting hand-edited. The canonical pages are
# developers/packages/sdk/docs/{RELAYER,SOLVER}_API_ENDPOINTS.md (nested under Deployments in
# SUMMARY.md) and developers/deployments/swaps-compatible-assets.md.
rm -f "$DST/deployments/relayer-api-endpoints.md"
rm -f "$DST/deployments/solver-api-endpoints.md"
rm -f "$DST/deployments/solver-compatible-assets.md"
rm -f "sdk-docs-comparison.md"

# 4) SDK README → Foundation layer
copy_file "$SRC/packages/sdk/README.md" "$DST/packages/foundation/sdk/README.md"
inject_frontmatter "$DST/packages/foundation/sdk/README.md" "cup-straw" \
  "The SODAX SDK provides a comprehensive interface for interacting with the SODAX protocol, enabling cross-chain swaps, money market, cross-chain bridging, migration and staking SODA token."
fix_synced_links "$DST/packages/foundation/sdk/README.md"

# 4b) swaps-api README → Foundation layer (standalone Swaps API v2 wire client)
copy_file "$SRC/packages/swaps-api/README.md" "$DST/packages/foundation/swaps-api.md"
inject_frontmatter "$DST/packages/foundation/swaps-api.md" "plug" \
  "Minimal, type-safe HTTP client for the SODAX backend Swaps API v2 — the wire client that @sodax/sdk's sodax.api.swaps wraps."
fix_synced_links "$DST/packages/foundation/swaps-api.md"

# 4c) swaps-api worked example (the only end-to-end app driving @sodax/swaps-api on its own)
copy_file "$SRC/apps/swap-api-example/README.md" "$DST/packages/foundation/swaps-api/example.md"
inject_frontmatter "$DST/packages/foundation/swaps-api/example.md" "terminal" \
  "A Vite + React app driving the backend Swaps API v2 through @sodax/swaps-api only — no @sodax/sdk, no @sodax/dapp-kit."
fix_synced_links "$DST/packages/foundation/swaps-api/example.md"

# 4d) @sodax/types → Foundation layer (published package, direct dependency of every @sodax/*)
copy_file "$SRC/packages/types/README.md" "$DST/packages/foundation/types.md"
inject_frontmatter "$DST/packages/foundation/types.md" "shapes" \
  "Shared chain, token, wallet-provider and backend-contract types consumed by every @sodax/* package."
fix_synced_links "$DST/packages/foundation/types.md"

# 5) Functional modules (sdk/docs → foundation/sdk/functional-modules, lowercased)
copy_file "$SRC/packages/sdk/docs/SWAPS.md"        "$DST/packages/foundation/sdk/functional-modules/swaps.md"
copy_file "$SRC/packages/sdk/docs/MONEY_MARKET.md"  "$DST/packages/foundation/sdk/functional-modules/money_market.md"
copy_file "$SRC/packages/sdk/docs/BRIDGE.md"        "$DST/packages/foundation/sdk/functional-modules/bridge.md"
copy_file "$SRC/packages/sdk/docs/STAKING.md"       "$DST/packages/foundation/sdk/functional-modules/staking.md"
copy_file "$SRC/packages/sdk/docs/MIGRATION.md"     "$DST/packages/foundation/sdk/functional-modules/migration.md"
copy_file "$SRC/packages/sdk/docs/LEVERAGE_YIELD.md"     "$DST/packages/foundation/sdk/functional-modules/leverage_yield.md"
copy_file "$SRC/packages/sdk/docs/LEVERAGE_YIELD_APR.md" "$DST/packages/foundation/sdk/functional-modules/leverage_yield_apr.md"
copy_file "$SRC/packages/sdk/docs/DEX.md"                "$DST/packages/foundation/sdk/functional-modules/dex.md"
copy_file "$SRC/packages/sdk/docs/RECOVERY.md"           "$DST/packages/foundation/sdk/functional-modules/recovery.md"

inject_frontmatter "$DST/packages/foundation/sdk/functional-modules/swaps.md"        "rotate"
inject_frontmatter "$DST/packages/foundation/sdk/functional-modules/money_market.md"  "sack-dollar"
inject_frontmatter "$DST/packages/foundation/sdk/functional-modules/bridge.md"        "bridge-suspension"
inject_frontmatter "$DST/packages/foundation/sdk/functional-modules/staking.md"       "seedling"
inject_frontmatter "$DST/packages/foundation/sdk/functional-modules/migration.md"     "truck"
inject_frontmatter "$DST/packages/foundation/sdk/functional-modules/leverage_yield.md"     "money-bill-trend-up"
inject_frontmatter "$DST/packages/foundation/sdk/functional-modules/leverage_yield_apr.md" "percent"
inject_frontmatter "$DST/packages/foundation/sdk/functional-modules/dex.md"                "droplet"
inject_frontmatter "$DST/packages/foundation/sdk/functional-modules/recovery.md"           "life-ring"

for f in swaps.md money_market.md bridge.md staking.md migration.md leverage_yield.md leverage_yield_apr.md dex.md recovery.md; do
  fix_synced_links "$DST/packages/foundation/sdk/functional-modules/$f"
done

# 6) Tooling modules (sdk/docs → foundation/sdk/tooling-modules, lowercased)
copy_file "$SRC/packages/sdk/docs/BACKEND_API.md"      "$DST/packages/foundation/sdk/tooling-modules/backend_api.md"
copy_file "$SRC/packages/sdk/docs/INTENT_RELAY_API.md"  "$DST/packages/foundation/sdk/tooling-modules/intent_relay_api.md"
copy_file "$SRC/packages/sdk/docs/SWAPS_API.md"         "$DST/packages/foundation/sdk/tooling-modules/swaps_api.md"

inject_frontmatter "$DST/packages/foundation/sdk/tooling-modules/backend_api.md"      "plug"
inject_frontmatter "$DST/packages/foundation/sdk/tooling-modules/intent_relay_api.md"  "envelope"
inject_frontmatter "$DST/packages/foundation/sdk/tooling-modules/swaps_api.md"         "code"

for f in backend_api.md intent_relay_api.md swaps_api.md; do
  fix_synced_links "$DST/packages/foundation/sdk/tooling-modules/$f"
done

# 7) How-to guides (stay at sdk/docs/, preserve names — no frontmatter needed)
for f in CONFIGURE_SDK ESTIMATE_GAS HOW_TO_MAKE_A_SWAP \
         MONETIZE_SDK WALLET_PROVIDERS STELLAR_TRUSTLINE \
         RELAYER_API_ENDPOINTS SOLVER_API_ENDPOINTS \
         LOGGING ARCHITECTURE; do
  copy_file "$SRC/packages/sdk/docs/${f}.md" "$DST/packages/sdk/docs/${f}.md"
  fix_synced_links "$DST/packages/sdk/docs/${f}.md"
done
copy_file "$SRC/packages/sdk/docs/installation/nextjs.md" "$DST/packages/sdk/docs/installation/nextjs.md"
fix_synced_links "$DST/packages/sdk/docs/installation/nextjs.md"

# 7d) Chain-ID migration table — mirrored one level above docs/ so that ARCHITECTURE.md's
# relative `../CHAIN_ID_MIGRATION.md` link resolves identically on both sides of the mirror.
copy_file "$SRC/packages/sdk/CHAIN_ID_MIGRATION.md" "$DST/packages/sdk/CHAIN_ID_MIGRATION.md"
fix_synced_links "$DST/packages/sdk/CHAIN_ID_MIGRATION.md"

# 7b) Bitcoin Integration (sdk/docs/BITCOIN_INTEGRATION.md → how-to/bitcoin-integration.md)
# Lives under how-to/ to preserve the public docs.sodax.com URL.
copy_file "$SRC/packages/sdk/docs/BITCOIN_INTEGRATION.md" "$DST/how-to/bitcoin-integration.md"
inject_description_frontmatter "$DST/how-to/bitcoin-integration.md" \
  "This guide is a step-by-step walkthrough for integrating Bitcoin as a source or destination chain in a SODAX-powered dApp." \
  "Bitcoin Integration"
fix_synced_links "$DST/how-to/bitcoin-integration.md"

# 7c) AI Integration (sodax-sdks/docs/ai-integration-guide.md → developers/ai-integration/README.md)
copy_file "$SRC/docs/ai-integration-guide.md" "$DST/ai-integration/README.md"
inject_frontmatter "$DST/ai-integration/README.md" "robot" \
  "Every @sodax/* package on npm ships AI-readable docs at ai-exported/. Point Cursor, Claude Code, Copilot, or another coding agent at those files for v2-correct SDK code on the first try."

# 8) Connection layer
copy_file "$SRC/packages/wallet-sdk-core/README.md"  "$DST/packages/connection/wallet-sdk-core.md"
copy_file "$SRC/packages/wallet-sdk-react/README.md" "$DST/packages/connection/wallet-sdk-react.md"

inject_frontmatter "$DST/packages/connection/wallet-sdk-core.md"  "wallet"
inject_frontmatter "$DST/packages/connection/wallet-sdk-react.md" "react"

fix_relative_repo_links "$DST/packages/connection/wallet-sdk-react.md"

# 8b) wallet-sdk-react consumer guides.
# Destination is `connection/docs/` (NOT `connection/wallet-sdk-react/`) so that the README's
# `docs/<FILE>.md` rows and the guides' own `./<FILE>.md` sibling links stay relative and legal for
# sodax-sdks' `pnpm check:doc-links`. The public URL comes from the SUMMARY.md parent, not the path.
# ADDING_A_NEW_CHAIN.md is deliberately NOT mirrored — it is a contributor workflow.
for entry in \
  "CONFIGURE_PROVIDER:gear" \
  "CONNECT_FLOW:link" \
  "WALLET_PROVIDER_BRIDGE:bridge" \
  "WALLET_MODAL:window-restore" \
  "CHAIN_DETECTION:magnifying-glass" \
  "CONNECTORS:plug" \
  "BATCH_OPERATIONS:layer-group" \
  "SIGN_MESSAGE:signature" \
  "EVM_SWITCH_CHAIN:shuffle" \
  "WALLETCONNECT:qrcode" \
  "SUB_PATH_EXPORTS:folder-tree" \
  "ARCHITECTURE:sitemap"; do
  f="${entry%%:*}"
  icon="${entry##*:}"
  copy_file "$SRC/packages/wallet-sdk-react/docs/${f}.md" "$DST/packages/connection/docs/${f}.md"
  inject_frontmatter "$DST/packages/connection/docs/${f}.md" "$icon"
  fix_synced_links "$DST/packages/connection/docs/${f}.md"
done

# 9) Experience layer
copy_file "$SRC/packages/dapp-kit/README.md" "$DST/packages/experience/dapp-kit.md"

inject_frontmatter "$DST/packages/experience/dapp-kit.md" "browser"

fix_relative_repo_links "$DST/packages/experience/dapp-kit.md"

# 9b) skills README → Experience layer (AI-agent skills bundle)
copy_file "$SRC/packages/skills/README.md" "$DST/packages/experience/skills.md"
inject_frontmatter "$DST/packages/experience/skills.md" "robot" \
  "Consumer-facing AI skills and knowledge so coding agents (Claude Code, Cursor, Copilot, Codex) write v2-correct @sodax/* SDK code."
fix_relative_repo_links "$DST/packages/experience/skills.md"

# 9c) dapp-kit backend query hooks reference
copy_file "$SRC/packages/dapp-kit/src/hooks/backend/README.md" "$DST/packages/experience/dapp-kit/backend-hooks.md"
inject_frontmatter "$DST/packages/experience/dapp-kit/backend-hooks.md" "database" \
  "React Query hooks over the SODAX backend API — intents, orderbook and money-market reads."
fix_synced_links "$DST/packages/experience/dapp-kit/backend-hooks.md"

# 9d) Example apps. Every published guide points at one of these for its runnable counterpart, so
# the READMEs have to be reachable on docs.sodax.com rather than only on GitHub.
# apps/example-next-js-16 is deliberately NOT mirrored — it is a regression harness for a single
# Turbopack bug, already linked from the Next.js installation guide.
copy_file "$SRC/apps/node/README.md" "$DST/packages/examples/node.md"
inject_frontmatter "$DST/packages/examples/node.md" "terminal" \
  "Runnable @sodax/sdk scripts for a backend integration — one file per chain or feature, no React."
fix_synced_links "$DST/packages/examples/node.md"

copy_file "$SRC/apps/demo/README.md" "$DST/packages/examples/demo.md"
inject_frontmatter "$DST/packages/examples/demo.md" "browser" \
  "Vite + React reference app covering the full SDK surface, one page per feature service."
fix_synced_links "$DST/packages/examples/demo.md"

copy_file "$SRC/apps/wallet-modal-example/README.md" "$DST/packages/examples/wallet-modal.md"
inject_frontmatter "$DST/packages/examples/wallet-modal.md" "wallet" \
  "Headless reference app for the @sodax/wallet-sdk-react modal primitives — no design system, no DeFi logic."
fix_synced_links "$DST/packages/examples/wallet-modal.md"

# 10) Audits (Markdown only — the PDFs are served from GitHub via the links in
# developers/audits/Readme.md, so copying them here just adds files nothing can reach).
AUDITS_SRC="$SRC/Audits"
AUDITS_DST="$DST/audits"
find "$AUDITS_SRC" -type f -name '*.md' -print0 | while IFS= read -r -d '' filepath; do
  relpath="${filepath#"$AUDITS_SRC"/}"
  copy_file "$filepath" "$AUDITS_DST/$relpath"
done

# 11) GitHub Wiki pages → Deployments
WIKI_TMP=$(mktemp -d)
trap 'rm -rf "$WIKI_TMP"' EXIT

git clone --depth 1 git@github.com:icon-project/sodax-contracts.wiki.git "$WIKI_TMP/sodax-contracts-wiki"

copy_file "$WIKI_TMP/sodax-contracts-wiki/Mainnet.md" "$DST/deployments/mainnet.md"

inject_description_frontmatter "$DST/deployments/mainnet.md" \
  "Mainnet smart contract deployments." "Mainnet"

# NOTE: developers/deployments/swaps-compatible-assets.md is deliberately hand-maintained and is NOT
# synced from the sodax-solver wiki. The wiki page lags SDK reality — it lists Nibiru, which is not a
# ChainKey in @sodax/types, and omits NEAR, Bitcoin, SUI, Ethereum and Redbelly, which are. Syncing it
# would delete live chains from the published page. The old solver-compatible-assets URL is preserved
# by a redirect in .gitbook.yaml.

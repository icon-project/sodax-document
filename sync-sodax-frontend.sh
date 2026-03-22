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
SRC="linked-repositories/sodax-frontend"
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
    -e 's|\[Contributing Guide\](CONTRIBUTING.md)|[Contributing Guide](https://github.com/icon-project/sodax-frontend/blob/main/CONTRIBUTING.md)|g' \
    -e 's|\[MIT\](LICENSE)|[MIT](https://github.com/icon-project/sodax-frontend/blob/main/LICENSE)|g' \
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
    -e 's|https://github.com/icon-project/sodax-document/blob/main/developers/packages/sdk/CONTRIBUTING.md|https://github.com/icon-project/sodax-frontend/blob/main/CONTRIBUTING.md|g' \
    -e 's|https://github.com/icon-project/sodax-document/blob/main/developers/packages/sdk/LICENSE/README.md|https://github.com/icon-project/sodax-frontend/blob/main/LICENSE|g' \
    -e 's|https://docs.sodax.com/developers/packages/sdk/swaps|https://docs.sodax.com/developers/packages/foundation/sdk/functional-modules/swaps|g' \
    -e 's|https://docs.sodax.com/developers/packages/sdk/money_market|https://docs.sodax.com/developers/packages/foundation/sdk/functional-modules/money_market|g' \
    -e 's|https://docs.sodax.com/developers/packages/sdk/bridge|https://docs.sodax.com/developers/packages/foundation/sdk/functional-modules/bridge|g' \
    -e 's|https://docs.sodax.com/developers/packages/sdk/staking|https://docs.sodax.com/developers/packages/foundation/sdk/functional-modules/staking|g' \
    -e 's|https://docs.sodax.com/developers/packages/sdk/migration|https://docs.sodax.com/developers/packages/foundation/sdk/functional-modules/migration|g' \
    -e 's|https://docs.sodax.com/developers/packages/sdk/backend_api|https://docs.sodax.com/developers/packages/foundation/sdk/tooling-modules/backend_api|g' \
    -e 's|https://docs.sodax.com/developers/packages/sdk/intent_relay_api|https://docs.sodax.com/developers/packages/foundation/sdk/tooling-modules/intent_relay_api|g' \
    -e 's|https://docs.sodax.com/developers/packages/intent_relay_api|https://docs.sodax.com/developers/packages/foundation/sdk/tooling-modules/intent_relay_api|g' \
    "$file" > "$tmp"
  mv "$tmp" "$file"
}

# 3) Remove stale files from old flat-copy sync (not in SUMMARY.md, not from sodax-frontend)
rm -f "$DST/packages/types/README.md"
rm -f "$DST/packages/RELEASE_INSTRUCTIONS.md"
rm -rf "$DST/packages/dapp-kit/src"

# 4) SDK README → Foundation layer
copy_file "$SRC/packages/sdk/README.md" "$DST/packages/foundation/sdk/README.md"
inject_frontmatter "$DST/packages/foundation/sdk/README.md" "cup-straw" \
  "The SODAX SDK provides a comprehensive interface for interacting with the SODAX protocol, enabling cross-chain swaps, money market, cross-chain bridging, migration and staking SODA token."
fix_synced_links "$DST/packages/foundation/sdk/README.md"

# 5) Functional modules (sdk/docs → foundation/sdk/functional-modules, lowercased)
copy_file "$SRC/packages/sdk/docs/SWAPS.md"        "$DST/packages/foundation/sdk/functional-modules/swaps.md"
copy_file "$SRC/packages/sdk/docs/MONEY_MARKET.md"  "$DST/packages/foundation/sdk/functional-modules/money_market.md"
copy_file "$SRC/packages/sdk/docs/BRIDGE.md"        "$DST/packages/foundation/sdk/functional-modules/bridge.md"
copy_file "$SRC/packages/sdk/docs/STAKING.md"       "$DST/packages/foundation/sdk/functional-modules/staking.md"
copy_file "$SRC/packages/sdk/docs/MIGRATION.md"     "$DST/packages/foundation/sdk/functional-modules/migration.md"

inject_frontmatter "$DST/packages/foundation/sdk/functional-modules/swaps.md"        "rotate"
inject_frontmatter "$DST/packages/foundation/sdk/functional-modules/money_market.md"  "sack-dollar"
inject_frontmatter "$DST/packages/foundation/sdk/functional-modules/bridge.md"        "bridge-suspension"
inject_frontmatter "$DST/packages/foundation/sdk/functional-modules/staking.md"       "seedling"
inject_frontmatter "$DST/packages/foundation/sdk/functional-modules/migration.md"     "truck"

for f in swaps.md money_market.md bridge.md staking.md migration.md; do
  fix_synced_links "$DST/packages/foundation/sdk/functional-modules/$f"
done

# 6) Tooling modules (sdk/docs → foundation/sdk/tooling-modules, lowercased)
copy_file "$SRC/packages/sdk/docs/BACKEND_API.md"      "$DST/packages/foundation/sdk/tooling-modules/backend_api.md"
copy_file "$SRC/packages/sdk/docs/INTENT_RELAY_API.md"  "$DST/packages/foundation/sdk/tooling-modules/intent_relay_api.md"

inject_frontmatter "$DST/packages/foundation/sdk/tooling-modules/backend_api.md"      "plug"
inject_frontmatter "$DST/packages/foundation/sdk/tooling-modules/intent_relay_api.md"  "envelope"

# 7) How-to guides (stay at sdk/docs/, preserve names — no frontmatter needed)
for f in CONFIGURE_SDK ESTIMATE_GAS HOW_TO_MAKE_A_SWAP HOW_TO_CREATE_A_SPOKE_PROVIDER \
         MONETIZE_SDK WALLET_PROVIDERS STELLAR_TRUSTLINE \
         RELAYER_API_ENDPOINTS SOLVER_API_ENDPOINTS; do
  copy_file "$SRC/packages/sdk/docs/${f}.md" "$DST/packages/sdk/docs/${f}.md"
done
copy_file "$SRC/packages/sdk/docs/installation/nextjs.md" "$DST/packages/sdk/docs/installation/nextjs.md"

# 8) Connection layer
copy_file "$SRC/packages/wallet-sdk-core/README.md"  "$DST/packages/connection/wallet-sdk-core.md"
copy_file "$SRC/packages/wallet-sdk-react/README.md" "$DST/packages/connection/wallet-sdk-react.md"

inject_frontmatter "$DST/packages/connection/wallet-sdk-core.md"  "wallet"
inject_frontmatter "$DST/packages/connection/wallet-sdk-react.md" "react"

fix_relative_repo_links "$DST/packages/connection/wallet-sdk-react.md"

# 9) Experience layer
copy_file "$SRC/packages/dapp-kit/README.md" "$DST/packages/experience/dapp-kit.md"

inject_frontmatter "$DST/packages/experience/dapp-kit.md" "browser"

fix_relative_repo_links "$DST/packages/experience/dapp-kit.md"

# 10) Audits (Markdown + PDF files, preserving directory structure)
AUDITS_SRC="$SRC/Audits"
AUDITS_DST="$DST/audits"
find "$AUDITS_SRC" -type f \( -name '*.md' -o -name '*.pdf' \) -print0 | while IFS= read -r -d '' filepath; do
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
  "Mainnet smart contract deployments." "Mainnet"
inject_description_frontmatter "$DST/deployments/solver-compatible-assets.md" \
  "Assets (tokens) supported by mainnet solver (swaps)." "Swap: Compatible Assets"

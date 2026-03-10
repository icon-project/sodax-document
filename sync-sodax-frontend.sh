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

# 3) Remove stale files from old flat-copy sync (not in SUMMARY.md, not from sodax-frontend)
rm -f "$DST/packages/types/README.md"
rm -f "$DST/packages/RELEASE_INSTRUCTIONS.md"
rm -rf "$DST/packages/dapp-kit/src"

# 4) SDK README → Foundation layer
copy_file "$SRC/packages/sdk/README.md" "$DST/packages/foundation/sdk/README.md"

# 5) Functional modules (sdk/docs → foundation/sdk/functional-modules, lowercased)
copy_file "$SRC/packages/sdk/docs/SWAPS.md"        "$DST/packages/foundation/sdk/functional-modules/swaps.md"
copy_file "$SRC/packages/sdk/docs/MONEY_MARKET.md"  "$DST/packages/foundation/sdk/functional-modules/money_market.md"
copy_file "$SRC/packages/sdk/docs/BRIDGE.md"        "$DST/packages/foundation/sdk/functional-modules/bridge.md"
copy_file "$SRC/packages/sdk/docs/STAKING.md"       "$DST/packages/foundation/sdk/functional-modules/staking.md"
copy_file "$SRC/packages/sdk/docs/MIGRATION.md"     "$DST/packages/foundation/sdk/functional-modules/migration.md"

# 6) Tooling modules (sdk/docs → foundation/sdk/tooling-modules, lowercased)
copy_file "$SRC/packages/sdk/docs/BACKEND_API.md"      "$DST/packages/foundation/sdk/tooling-modules/backend_api.md"
copy_file "$SRC/packages/sdk/docs/INTENT_RELAY_API.md"  "$DST/packages/foundation/sdk/tooling-modules/intent_relay_api.md"

# 7) How-to guides (stay at sdk/docs/, preserve names)
for f in CONFIGURE_SDK ESTIMATE_GAS HOW_TO_MAKE_A_SWAP HOW_TO_CREATE_A_SPOKE_PROVIDER \
         MONETIZE_SDK WALLET_PROVIDERS STELLAR_TRUSTLINE \
         RELAYER_API_ENDPOINTS SOLVER_API_ENDPOINTS; do
  copy_file "$SRC/packages/sdk/docs/${f}.md" "$DST/packages/sdk/docs/${f}.md"
done
copy_file "$SRC/packages/sdk/docs/installation/nextjs.md" "$DST/packages/sdk/docs/installation/nextjs.md"

# 8) Connection layer
copy_file "$SRC/packages/wallet-sdk-core/README.md"  "$DST/packages/connection/wallet-sdk-core.md"
copy_file "$SRC/packages/wallet-sdk-react/README.md" "$DST/packages/connection/wallet-sdk-react.md"

# 9) Experience layer
copy_file "$SRC/packages/dapp-kit/README.md" "$DST/packages/experience/dapp-kit.md"

# 10) Audits (Markdown + PDF files, preserving directory structure)
AUDITS_SRC="$SRC/Audits"
AUDITS_DST="$DST/Audits"
find "$AUDITS_SRC" -type f \( -name '*.md' -o -name '*.pdf' \) -print0 | while IFS= read -r -d '' filepath; do
  relpath="${filepath#"$AUDITS_SRC"/}"
  copy_file "$filepath" "$AUDITS_DST/$relpath"
done

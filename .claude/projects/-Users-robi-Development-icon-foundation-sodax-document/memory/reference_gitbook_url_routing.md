---
name: GitBook URL routing and sync link verification
description: How GitBook routes URLs for this site, how the sync script rewrites links, and how to verify links after syncing. Verified 2026-03-22.
type: reference
---

# GitBook URL Routing for docs.sodax.com

## Two URL patterns coexist

1. **Pages whose file path matches their SUMMARY.md parent** — URL = file path with `.md` stripped.
   Example: `developers/packages/foundation/sdk/functional-modules/swaps.md` → `/developers/packages/foundation/sdk/functional-modules/swaps`

2. **Pages whose file lives in a different directory than their SUMMARY.md parent** — URL = parent's URL path + lowercased filename slug.
   Example: `developers/packages/sdk/docs/MONETIZE_SDK.md` is nested under `developers/how-to/README.md` in SUMMARY.md → `/developers/how-to/monetize_sdk`

## Verified URL Mapping (all confirmed 200 on 2026-03-22)

| SUMMARY.md file path | Live URL path |
|---|---|
| `developers/deployments/README.md` | `/developers/deployments` |
| `developers/deployments/mainnet.md` | `/developers/deployments/mainnet` |
| `developers/packages/sdk/docs/RELAYER_API_ENDPOINTS.md` | `/developers/deployments/relayer_api_endpoints` |
| `developers/packages/sdk/docs/SOLVER_API_ENDPOINTS.md` | `/developers/deployments/solver_api_endpoints` |
| `developers/deployments/xcall-scanner.md` | `/developers/deployments/xcall-scanner` |
| `developers/deployments/solver-compatible-assets.md` | `/developers/deployments/solver-compatible-assets` |
| `developers/packages/README.md` | `/developers/packages` |
| `developers/packages/foundation/README.md` | `/developers/packages/foundation` |
| `developers/packages/foundation/sdk/README.md` | `/developers/packages/foundation/sdk` |
| `developers/packages/foundation/sdk/functional-modules/README.md` | `/developers/packages/foundation/sdk/functional-modules` |
| `developers/packages/foundation/sdk/functional-modules/swaps.md` | `/developers/packages/foundation/sdk/functional-modules/swaps` |
| `developers/packages/foundation/sdk/functional-modules/money_market.md` | `/developers/packages/foundation/sdk/functional-modules/money_market` |
| `developers/packages/foundation/sdk/functional-modules/bridge.md` | `/developers/packages/foundation/sdk/functional-modules/bridge` |
| `developers/packages/foundation/sdk/functional-modules/staking.md` | `/developers/packages/foundation/sdk/functional-modules/staking` |
| `developers/packages/foundation/sdk/functional-modules/migration.md` | `/developers/packages/foundation/sdk/functional-modules/migration` |
| `developers/packages/foundation/sdk/tooling-modules/README.md` | `/developers/packages/foundation/sdk/tooling-modules` |
| `developers/packages/foundation/sdk/tooling-modules/backend_api.md` | `/developers/packages/foundation/sdk/tooling-modules/backend_api` |
| `developers/packages/foundation/sdk/tooling-modules/intent_relay_api.md` | `/developers/packages/foundation/sdk/tooling-modules/intent_relay_api` |
| `developers/packages/connection/README.md` | `/developers/packages/connection` |
| `developers/packages/connection/wallet-sdk-core.md` | `/developers/packages/connection/wallet-sdk-core` |
| `developers/packages/connection/wallet-sdk-react.md` | `/developers/packages/connection/wallet-sdk-react` |
| `developers/packages/experience/README.md` | `/developers/packages/experience` |
| `developers/packages/experience/dapp-kit.md` | `/developers/packages/experience/dapp-kit` |
| `developers/technical-overview/README.md` | `/developers/technical-overview` |
| `developers/technical-overview/asset-manager.md` | `/developers/technical-overview/asset-manager` |
| `developers/technical-overview/vault-token.md` | `/developers/technical-overview/vault-token` |
| `developers/technical-overview/hub-wallet-abstraction.md` | `/developers/technical-overview/hub-wallet-abstraction` |
| `developers/technical-overview/intents.md` | `/developers/technical-overview/intents` |
| `developers/technical-overview/generalized-messaging-protocol.md` | `/developers/technical-overview/generalized-messaging-protocol` |
| `developers/how-to/README.md` | `/developers/how-to` |
| `developers/packages/sdk/docs/MONETIZE_SDK.md` | `/developers/how-to/monetize_sdk` |
| `developers/packages/sdk/docs/CONFIGURE_SDK.md` | `/developers/how-to/configure_sdk` |
| `developers/packages/sdk/docs/HOW_TO_MAKE_A_SWAP.md` | `/developers/how-to/how_to_make_a_swap` |
| `developers/packages/sdk/docs/HOW_TO_CREATE_A_SPOKE_PROVIDER.md` | `/developers/how-to/how_to_create_a_spoke_provider` |
| `developers/packages/sdk/docs/WALLET_PROVIDERS.md` | `/developers/how-to/wallet_providers` |
| `developers/packages/sdk/docs/ESTIMATE_GAS.md` | `/developers/how-to/estimate_gas` |
| `developers/packages/sdk/docs/STELLAR_TRUSTLINE.md` | `/developers/how-to/stellar_trustline` |
| `developers/faq.md` | `/developers/faq` |
| `developers/audits/Readme.md` | `/welcome-to-sodax/audits` |

## Sync Script Link Rewriting

`sync-sodax-frontend.sh` copies files from the `sodax-frontend` submodule and applies two types of link fixes:

### `fix_synced_links()` — applied to SDK README + functional modules
Rewrites:
- Relative `./developers/how-to/how_to_create_a_spoke_provider` → correct absolute docs.sodax.com URL
- `sodax-document` GitHub links → `sodax-frontend` GitHub links (CONTRIBUTING, LICENSE)
- Old flat SDK doc URLs (`/packages/sdk/swaps`) → new nested paths (`/packages/foundation/sdk/functional-modules/swaps`)

### `fix_relative_repo_links()` — applied to dapp-kit + wallet-sdk-react
Rewrites:
- Relative `(CONTRIBUTING.md)` → `https://github.com/icon-project/sodax-frontend/blob/main/CONTRIBUTING.md`
- Relative `(LICENSE)` → `https://github.com/icon-project/sodax-frontend/blob/main/LICENSE`

## How to Verify Links After Syncing

1. Grep synced files for `docs.sodax.com` URLs — each must match a verified live URL path from the table above
2. Grep for relative links `](CONTRIBUTING`, `](LICENSE`, `](./` — these break on GitBook
3. Check `developers/technical-overview/README.md` for internal relative links (this file is hand-edited, not synced)
4. Spot-check suspicious URLs with `WebFetch` to confirm no 404s

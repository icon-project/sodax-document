---
name: GitBook URL routing and sync link verification
description: How GitBook routes URLs based on SUMMARY.md hierarchy (not file paths), how the sync script rewrites links, and how to verify links after syncing.
type: reference
---

# GitBook URL Routing vs File Paths

GitBook does NOT route pages by their file path. It routes by the **SUMMARY.md nesting hierarchy**.

## The Key Rule

A file's live URL is determined by its **parent page path in SUMMARY.md** + the **lowercased filename slug**, regardless of where the `.md` file actually lives on disk.

### Example: How-to guides

In SUMMARY.md:
```
* [How to](developers/how-to/README.md)           ← parent URL: /developers/how-to
  * [Monetize SDK](developers/packages/sdk/docs/MONETIZE_SDK.md)
```

- File path: `developers/packages/sdk/docs/MONETIZE_SDK.md`
- Live URL: `https://docs.sodax.com/developers/how-to/monetize_sdk` (NOT `/developers/packages/sdk/docs/MONETIZE_SDK`)

### Example: Relayer/Solver API endpoints

In SUMMARY.md:
```
* [Deployments](developers/deployments/README.md)  ← parent URL: /developers/deployments
  * [Relayer API endpoints](developers/packages/sdk/docs/RELAYER_API_ENDPOINTS.md)
```

- File path: `developers/packages/sdk/docs/RELAYER_API_ENDPOINTS.md`
- Live URL: `https://docs.sodax.com/developers/deployments/relayer_api_endpoints`

### Example: Audits

In SUMMARY.md:
```
## WELCOME TO SODAX
* [Audits](developers/audits/Readme.md)
```

- Live URL: `https://docs.sodax.com/welcome-to-sodax/audits` (section name becomes URL prefix)

## Complete URL Mapping (SUMMARY.md → Live URL)

| SUMMARY.md file path | Live URL path |
|---|---|
| `README.md` | `/` |
| `README (1).md` | `/welcome-to-sodax/contact-form` |
| `developers/audits/Readme.md` | `/welcome-to-sodax/audits` |
| `developers/deployments/README.md` | `/developers/deployments` |
| `developers/deployments/mainnet.md` | `/developers/deployments/mainnet` |
| `developers/packages/sdk/docs/RELAYER_API_ENDPOINTS.md` | `/developers/deployments/relayer_api_endpoints` |
| `developers/packages/sdk/docs/SOLVER_API_ENDPOINTS.md` | `/developers/deployments/solver_api_endpoints` |
| `developers/deployments/xcall-scanner.md` | `/developers/deployments/xcall-scanner` |
| `developers/deployments/solver-compatible-assets.md` | `/developers/deployments/solver-compatible-assets` |
| `developers/packages/README.md` | `/developers/sdks` |
| `developers/packages/foundation/README.md` | `/developers/sdks/1.-the-foundation` |
| `developers/packages/foundation/sdk/README.md` | `/developers/sdks/1.-the-foundation/sodax-sdk` |
| `developers/packages/foundation/sdk/functional-modules/README.md` | `/developers/sdks/1.-the-foundation/sodax-sdk/functional-modules` |
| `developers/packages/foundation/sdk/functional-modules/swaps.md` | `/developers/sdks/1.-the-foundation/sodax-sdk/functional-modules/swaps` |
| `developers/packages/foundation/sdk/functional-modules/money_market.md` | `/developers/sdks/1.-the-foundation/sodax-sdk/functional-modules/money_market` |
| `developers/packages/foundation/sdk/functional-modules/bridge.md` | `/developers/sdks/1.-the-foundation/sodax-sdk/functional-modules/bridge` |
| `developers/packages/foundation/sdk/functional-modules/staking.md` | `/developers/sdks/1.-the-foundation/sodax-sdk/functional-modules/staking` |
| `developers/packages/foundation/sdk/functional-modules/migration.md` | `/developers/sdks/1.-the-foundation/sodax-sdk/functional-modules/migration` |
| `developers/packages/foundation/sdk/tooling-modules/README.md` | `/developers/sdks/1.-the-foundation/sodax-sdk/tooling-modules` |
| `developers/packages/foundation/sdk/tooling-modules/backend_api.md` | `/developers/sdks/1.-the-foundation/sodax-sdk/tooling-modules/backend_api` |
| `developers/packages/foundation/sdk/tooling-modules/intent_relay_api.md` | `/developers/sdks/1.-the-foundation/sodax-sdk/tooling-modules/intent_relay_api` |
| `developers/packages/connection/README.md` | `/developers/sdks/2.-the-connection-layer` |
| `developers/packages/connection/wallet-sdk-core.md` | `/developers/sdks/2.-the-connection-layer/sodax-wallet-sdk-core` |
| `developers/packages/connection/wallet-sdk-react.md` | `/developers/sdks/2.-the-connection-layer/sodax-wallet-sdk-react` |
| `developers/packages/experience/README.md` | `/developers/sdks/3.-the-experience-layer` |
| `developers/packages/experience/dapp-kit.md` | `/developers/sdks/3.-the-experience-layer/sodax-dapp-kit` |
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

**How to apply:** When checking if a `docs.sodax.com` link is correct, look up the target page in SUMMARY.md and derive the URL from its nesting, NOT from its file path. The URL mapping table above can be used to verify directly, but may become stale if SUMMARY.md changes — always cross-reference with SUMMARY.md.

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

1. Grep all synced files for `docs.sodax.com` URLs
2. For each URL found, check it against the URL mapping table above — the path after `docs.sodax.com` must match a known live URL path
3. Grep for relative links `](CONTRIBUTING`, `](LICENSE`, `](./` — these break on GitBook since it resolves them against the docs repo, not the source repo
4. Spot-check with `WebFetch` on any suspicious URLs to confirm they don't 404

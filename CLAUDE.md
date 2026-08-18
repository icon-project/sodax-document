# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **GitBook documentation repository** for the SODAX SDK ecosystem, published to docs.sodax.com. It contains only Markdown content and GitBook configuration — no application code, build system, or tests.

## Content Sync Workflow

Most content is **auto-synced from external sources** and should not be manually edited here.

A GitHub Action (`.github/workflows/sync-from-sdks.yml`) runs `sync-sodax-sdks.sh` daily (and on demand via **Run workflow**) and opens a `docs-sync` PR on `sync/sodax-sdks`. Nothing reaches docs.sodax.com until that PR is merged. The script copies every file listed in `sodax-sdks` `scripts/gitbook-sync-map.json` — a new feature page that is on the map is copied automatically; it still needs a sidebar entry in `SUMMARY.md` (or `docs.json` after a Mintlify migration) or it will not appear in nav.

Sources:

1. **`sodax-sdks` submodule** (`linked-repositories/sodax-sdks`) — SDK docs, how-to guides, wallet/dapp-kit READMEs, Bitcoin Integration guide, and audit reports (copied in CI).
2. **`sodax-contracts.wiki`** GitHub wiki — `developers/deployments/mainnet.md` (skipped in CI; `SKIP_WIKI_SYNC=1`).
3. **`sodax-solver.wiki`** GitHub wiki — `developers/deployments/solver-compatible-assets.md` (skipped in CI).

To sync all sources locally (including wikis; needs SSH access to the private wiki repos):

```bash
bash sync-sodax-sdks.sh
```

It pulls the latest `origin/main` of the submodule, copies mapped files, and injects GitBook frontmatter (icons, descriptions).

### What NOT to edit (synced content, will be overwritten)

- `developers/packages/**` — all SDK, wallet, and dapp-kit docs
- `developers/how-to/bitcoin-integration.md` — from `sodax-sdks/packages/sdk/docs/BITCOIN_INTEGRATION.md`
- `developers/how-to/stellar-sponsoring-getting-started.md` — from `sodax-sdks/docs/stellar-sponsoring-getting-started.md`
- `developers/ai-integration/README.md` — from `sodax-sdks/docs/ai-integration-guide.md`
- `developers/deployments/mainnet.md` — from contracts wiki
- `developers/deployments/solver-compatible-assets.md` — from solver wiki
- `developers/audits/**` — from sodax-sdks repo

Edit the source in the respective upstream repo instead.

### What IS safe to edit directly

- **SUMMARY.md** — GitBook table of contents; defines sidebar navigation. Must be updated when a new mapped page is added (the sync PR body lists dests that are missing).
- **README.md** — Product overview / GitBook landing page.
- `developers/technical-overview/` — Architecture deep-dives (Asset Manager, Vault Token, Hub Wallet Abstraction, Intents, GMP).
- `developers/deployments/README.md` and `developers/deployments/xcall-scanner.md`
- `developers/how-to/README.md` — wrapper page for the How-to section.
- `developers/faq.md`
- `README (1).md` — Contact form page.
- `.gitbook/` — Platform assets and images.

## SDK Architecture (3 Layers)

The documentation covers a dependency stack of npm packages:

1. **Foundation** (`@sodax/sdk`) — Core logic: swaps, lending, bridging, staking, migration.
2. **Connection** (`@sodax/wallet-sdk-core`, `@sodax/wallet-sdk-react`) — Multi-chain wallet management.
3. **Experience** (`@sodax/dapp-kit`) — Pre-built React hooks and components that wrap layers 1 and 2.

## Conventions

- Pages use GitBook-flavored Markdown (frontmatter with `description` and `icon`, hint blocks, card tables, embedded links).
- Commits follow the pattern `GITBOOK-<N>: <description>` for GitBook-originated changes.
- The sync script injects frontmatter via helper functions (`inject_frontmatter`, `inject_description_frontmatter`) — do not add frontmatter to files that will be synced.

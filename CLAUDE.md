# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **GitBook documentation repository** for the SODAX SDK ecosystem, published to docs.sodax.com. It contains only Markdown content and GitBook configuration — no application code, build system, or tests.

## Content Sync Workflow

Most content is **auto-synced from external sources** and should not be manually edited here. The sync script handles three sources:

1. **`sodax-frontend` submodule** (`linked-repositories/sodax-frontend`) — SDK docs, how-to guides, wallet/dapp-kit READMEs, and audit reports.
2. **`sodax-contracts.wiki`** GitHub wiki — `developers/deployments/mainnet.md`
3. **`sodax-solver.wiki`** GitHub wiki — `developers/deployments/solver-compatible-assets.md`

To sync all sources:

```bash
bash sync-sodax-frontend.sh
```

This pulls the latest `origin/main` of the submodule and clones the wikis (requires SSH access to `icon-project/sodax-contracts.wiki` and `icon-project/sodax-solver.wiki`). It also injects GitBook frontmatter (icons, descriptions) into copied files.

### What NOT to edit (synced content, will be overwritten)

- `developers/packages/**` — all SDK, wallet, and dapp-kit docs
- `developers/deployments/mainnet.md` — from contracts wiki
- `developers/deployments/solver-compatible-assets.md` — from solver wiki
- `developers/Audits/**` — from sodax-frontend repo

Edit the source in the respective upstream repo instead.

### What IS safe to edit directly

- **SUMMARY.md** — GitBook table of contents; defines sidebar navigation. Must be updated when adding/removing pages.
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

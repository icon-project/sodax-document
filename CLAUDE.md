# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Mintlify documentation repository** for the SODAX SDK ecosystem, to be published to docs.sodax.com. It contains only Markdown/MDX content and Mintlify configuration (`docs.json`) — no application code, build system, or tests.

This is being developed on a migration branch (`docs/complete-mintlify-migration`) and has not yet been merged to `main`. **docs.sodax.com is still live on GitBook** until this branch merges — changes here do not affect the published site yet. `SUMMARY.md` and `.gitbook.yaml` are leftover GitBook config, superseded by `docs.json`; they're unused on this branch and should be removed once the migration merges.

## Content Sync Workflow

Most content is **auto-synced from external sources** and should not be manually edited here. The sync script handles three sources:

1. **`sodax-sdks` submodule** (`linked-repositories/sodax-sdks`) — SDK docs, how-to guides, wallet/dapp-kit READMEs, Bitcoin Integration guide, and audit reports.
2. **`sodax-contracts.wiki`** GitHub wiki — `developers/deployments/mainnet.md`
3. **`sodax-solver.wiki`** GitHub wiki — `developers/deployments/solver-compatible-assets.md`

To sync all sources:

```bash
bash sync-sodax-sdks.sh
```

This pulls the latest `origin/main` of the submodule and clones the wikis (requires SSH access to `icon-project/sodax-contracts.wiki` and `icon-project/sodax-solver.wiki`). It also injects frontmatter (icons, descriptions — same keys Mintlify reads) into copied files.

### What NOT to edit (synced content, will be overwritten)

- `developers/packages/**` — all SDK, wallet, and dapp-kit docs
- `developers/how-to/bitcoin-integration.md` — from `sodax-sdks/packages/sdk/docs/BITCOIN_INTEGRATION.md`
- `developers/ai-integration/README.md` — from `sodax-sdks/docs/ai-integration-guide.md`
- `developers/deployments/mainnet.md` — from contracts wiki
- `developers/deployments/solver-compatible-assets.md` — from solver wiki
- `developers/audits/**` — from sodax-sdks repo

Edit the source in the respective upstream repo instead.

### What IS safe to edit directly

- **`docs.json`** — Mintlify config: sidebar navigation (`navigation.tabs`), theme colors, contextual AI menu, logo/favicon. Must be updated when adding/removing pages.
- **`index.md`** — Product overview / Mintlify homepage.
- **`custom.css`** — SODAX brand tokens and light/dark theme overrides.
- `developers/technical-overview/` — Architecture deep-dives (Asset Manager, Vault Token, Hub Wallet Abstraction, Intents, GMP).
- `developers/deployments/README.md` and `developers/deployments/xcall-scanner.md`
- `developers/how-to/README.md` — wrapper page for the How-to section.
- `developers/faq.md`
- `contact-form.md` — Contact form page.
- `solana/` — Solana-specific quickstart, swaps, wallets, money market, and FAQ pages.
- `.gitbook/assets/` — image assets (path is a holdover from GitBook; still the asset location on this branch).

## SDK Architecture (3 Layers)

The documentation covers a dependency stack of npm packages:

1. **Foundation** (`@sodax/sdk`) — Core logic: swaps, lending, bridging, staking, migration.
2. **Connection** (`@sodax/wallet-sdk-core`, `@sodax/wallet-sdk-react`) — Multi-chain wallet management.
3. **Experience** (`@sodax/dapp-kit`) — Pre-built React hooks and components that wrap layers 1 and 2.

## Conventions

- Pages use Mintlify-flavored Markdown/MDX (frontmatter with `description` and `icon`; components like `<Card>`, `<CardGroup>`, `<Tabs>`, `<Note>`, `<CodeGroup>`, `<Columns>`, `<Steps>`).
- Commits follow the pattern `docs: <description>`.
- The sync script injects frontmatter via helper functions (`inject_frontmatter`, `inject_description_frontmatter`) — do not add frontmatter to files that will be synced.

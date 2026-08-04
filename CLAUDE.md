# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **GitBook documentation repository** for the SODAX SDK ecosystem, published to docs.sodax.com. It contains only Markdown content and GitBook configuration — no application code, build system, or tests.

## Content Sync Workflow

Most content is **auto-synced from external sources** and should not be manually edited here. The sync script handles two sources:

1. **`sodax-sdks` submodule** (`linked-repositories/sodax-sdks`) — SDK docs, how-to guides, wallet/dapp-kit READMEs, Bitcoin Integration guide, and audit reports.
2. **`sodax-contracts.wiki`** GitHub wiki — `developers/deployments/mainnet.md`

To sync all sources:

```bash
bash sync-sodax-sdks.sh
```

This pulls the latest `origin/main` of the submodule and clones the contracts wiki (requires SSH access to `icon-project/sodax-contracts.wiki`). It also injects GitBook frontmatter (icons, descriptions) into copied files.

The mirror list is duplicated upstream at `sodax-sdks/scripts/gitbook-sync-map.json`, which the `pnpm check:doc-links` CI gate validates links against. **When a mirrored doc is added, renamed, or removed, change both files in the same PR** — a stale mapping breaks the sync or silently relaxes the link gate.

### What NOT to edit (synced content, will be overwritten)

- `developers/packages/**` — all SDK, wallet, and dapp-kit docs
- `developers/how-to/bitcoin-integration.md` — from `sodax-sdks/packages/sdk/docs/BITCOIN_INTEGRATION.md`
- `developers/ai-integration/README.md` — from `sodax-sdks/docs/ai-integration-guide.md`
- `developers/deployments/mainnet.md` — from contracts wiki
- `developers/audits/**` — from sodax-sdks repo

Edit the source in the respective upstream repo instead.

`developers/deployments/swaps-compatible-assets.md` is the exception: it looks synced but is **hand-maintained**. It used to shadow the `sodax-solver` wiki page, which lags SDK reality (lists Nibiru, which is not a `ChainKey`; omits NEAR, Bitcoin, SUI, Ethereum, Redbelly, which are), so the wiki sync was removed. Update it by hand, or replace it with a generator sourced from `@sodax/types`.

### After every sync: check nothing became invisible

GitBook publishes **only** what `SUMMARY.md` lists. A file the script writes but `SUMMARY.md` never links is copied on every run and published nowhere. Run this after syncing — it must print nothing:

```bash
comm -23 \
  <(find developers -name '*.md' | sort) \
  <(grep -oE '\((<[^>]+>|[^)]+)\)' SUMMARY.md | tr -d '()<>' | grep '\.md$' | sort -u)
```

### What IS safe to edit directly

- **SUMMARY.md** — GitBook table of contents; defines sidebar navigation. Must be updated when adding/removing pages.
- The section index pages under `developers/packages/**` (`README.md` for SDKs, foundation, functional-modules, tooling-modules, connection, experience, examples). The sync script writes the leaf pages, never these — a new leaf needs a card added here as well as a `SUMMARY.md` entry, or it is published but unreachable by navigation.
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

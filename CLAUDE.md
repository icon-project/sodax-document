# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **GitBook documentation repository** for the SODAX SDK ecosystem, published to docs.sodax.com. It contains only Markdown content and GitBook configuration — no application code, build system, or tests.

## Content Sync Workflow

All content for the **Developers** section of the GitBook (SDKs, How-to guides, Technical Overview, Deployments, FAQ — everything under `developers/packages/`) is sourced from the linked repository `sodax-frontend`. The sync script copies Markdown files from `linked-repositories/sodax-frontend/packages/` and its subdirectories into `./developers/packages/`, and audit files (Markdown + PDFs) from `linked-repositories/sodax-frontend/Audits/` into `./developers/Audits/`.

To sync:

```bash
bash sync-sodax-frontend.sh
```

This pulls the latest `origin/main` of the `sodax-frontend` submodule before copying. **Do not manually edit files under `developers/packages/`** — changes will be overwritten on next sync. Edit the source in the `sodax-frontend` repo instead.

## Structure

- **SUMMARY.md** — GitBook table of contents; defines the sidebar navigation hierarchy. Must be updated when adding/removing pages.
- **README.md** — Product overview (GitBook landing page).
- **developers/** — All documentation content:
  - `packages/foundation/sdk/` — Core SDK (`@sodax/sdk`) with functional modules (Swaps, Money Market, Bridge, Staking, Migration) and tooling modules (Backend API, Intent Relay API).
  - `packages/connection/` — Wallet SDKs (`@sodax/wallet-sdk-core`, `@sodax/wallet-sdk-react`).
  - `packages/experience/` — React component library (`@sodax/dapp-kit`).
  - `packages/sdk/docs/` — How-to guides (swaps, gas estimation, wallet providers, etc.).
  - `technical-overview/` — Architecture deep-dives (Asset Manager, Vault Token, Hub Wallet Abstraction, Intents, GMP).
  - `deployments/` — Mainnet contract addresses and API endpoints.
  - `Audits/` — Security audit reports (Markdown + PDFs).
- **.gitbook/** — GitBook platform assets and configuration.

## SDK Architecture (3 Layers)

The documentation covers a dependency stack of npm packages:

1. **Foundation** (`@sodax/sdk`) — Core logic: swaps, lending, bridging, staking.
2. **Connection** (`@sodax/wallet-sdk-core`, `@sodax/wallet-sdk-react`) — Multi-chain wallet management.
3. **Experience** (`@sodax/dapp-kit`) — Pre-built React hooks and components that wrap layers 1 and 2.

## Conventions

- Pages use GitBook-flavored Markdown (frontmatter with `description`, hint blocks, card tables, embedded links).
- Commits follow the pattern `GITBOOK-<N>: <description>` for GitBook-originated changes.

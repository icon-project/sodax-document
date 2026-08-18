# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Mintlify documentation repository** for the SODAX SDK ecosystem, to be published to docs.sodax.com. It contains only Markdown/MDX content and Mintlify configuration (`docs.json`) — no application code, build system, or tests.

This is being developed on a migration branch (`docs/complete-mintlify-migration`) and has not yet been merged to `main`. **docs.sodax.com is still live on GitBook** until this branch merges — changes here do not affect the published site yet. `SUMMARY.md` and `.gitbook.yaml` are leftover GitBook config, superseded by `docs.json`; they're unused on this branch and should be removed once the migration merges.

## Content Sync Workflow

Most content is **auto-synced from external sources** and should not be manually edited here.

A GitHub Action (`.github/workflows/sync-from-sdks.yml`) runs `sync-sodax-sdks.sh` daily (and on demand via **Run workflow**) and opens a `docs-sync` PR on `sync/sodax-sdks`. Nothing reaches docs.sodax.com until that PR is merged (and this Mintlify branch has not merged yet). The script copies every file listed in `sodax-sdks` `scripts/gitbook-sync-map.json`, then remaps a few GitBook dests to Mintlify paths (`README.md` → `index.md`, Relayer/Solver under Deployments). A new feature page that is on the map is copied automatically; it still needs a sidebar entry in `docs.json` or it will not appear in nav.

Sources:

1. **`sodax-sdks` submodule** (`linked-repositories/sodax-sdks`) — SDK docs, how-to guides, wallet/dapp-kit READMEs, Bitcoin Integration, Stellar sponsoring, and audit PDFs (copied in CI).
2. **`sodax-contracts.wiki`** GitHub wiki — `developers/deployments/mainnet.md` (skipped in CI; `SKIP_WIKI_SYNC=1`).
3. **`sodax-solver.wiki`** GitHub wiki — `developers/deployments/solver-compatible-assets.md` (skipped in CI).

To sync all sources locally (including wikis; needs SSH access to the private wiki repos):

```bash
bash sync-sodax-sdks.sh
```

CI / dry-run without wikis:

```bash
SKIP_WIKI_SYNC=1 bash sync-sodax-sdks.sh
```

It pulls the latest `origin/main` of the submodule, copies mapped files, remaps dests, and injects Mintlify frontmatter (`title`, `icon`, `description`, optional `sidebarTitle`).

### What NOT to edit (synced content, will be overwritten)

- `developers/packages/**` — all SDK, wallet, and dapp-kit docs
- `developers/how-to/bitcoin-integration.md` — from `sodax-sdks/packages/sdk/docs/BITCOIN_INTEGRATION.md`
- `developers/how-to/stellar-sponsoring-getting-started.md` — from `sodax-sdks/docs/stellar-sponsoring-getting-started.md`
- `developers/how-to/quick-sponsoring-stellar-guide.md` — from `sodax-sdks/docs/quick-sponsoring-stellar-guide.md`
- `developers/ai-integration.md` — from `sodax-sdks/docs/ai-integration-guide.md`
- `developers/deployments/mainnet.md` — from contracts wiki
- `developers/deployments/solver-compatible-assets.md` — from solver wiki
- `developers/deployments/relayer-api-endpoints.md` and `solver-api-endpoints.md` — remapped from `packages/sdk/docs/RELAYER_API_ENDPOINTS.md` / `SOLVER_API_ENDPOINTS.md`
- `developers/audits/**/*.pdf` — PDFs from sodax-sdks `Audits/` (synced). The landing page `developers/audits/index.md` is **hand-maintained** here (do not replace from upstream `Audits/Readme.md`).

Edit the source in the respective upstream repo instead.

### What IS safe to edit directly

- **`docs.json`** — Mintlify config: sidebar navigation (`navigation.tabs`), theme colors, contextual AI menu, logo/favicon, `seo.metatags.canonical`, and `redirects`. Must be updated when adding/removing pages.
- **`DOCS_WRITING.md`** — clarity / no-repeat writing rules for hand-edited Mintlify pages (keep style guidance here, not in this file).
- **`index.mdx`** — Product overview / Mintlify homepage (solution-led Tabs).
- **`quickstart.mdx`** — 5-minute install → quote → execute (Get Started).
- **`custom.css`** — SODAX brand tokens and light/dark theme overrides.
- `swap/`, `money-market/`, `bridge/`, `yield/` — solution hub overviews (hand-maintained; link into API/SDK deep pages).
- `resources/` — **DevRel-owned** (Hazy / John): videos, blog, changelog. Register new pages in the Resources tab of `docs.json`.
- `developers/http-api/` — Partner HTTP API reference (hand-maintained; not synced from the SDK submodule).
- `developers/technical-overview/` — Architecture deep-dives (Asset Manager, Vault Token, Hub Wallet Abstraction, Intents, GMP).
- `developers/audits/index.md` — Audit landing narrative (PDFs still sync from sodax-sdks).
- `developers/deployments/index.md` and `developers/deployments/sodaxscan.md`
- `developers/how-to/index.md` — wrapper page for the How-to section.
- `developers/faq.md`
- `contact-form.md` — Contact form page.
- `solana/` — Solana-specific quickstart, swaps, wallets, money market, and FAQ pages.
- `.gitbook/assets/` — image assets (path is a holdover from GitBook; still the asset location on this branch).

### Navigation model

Top tabs are **solution-led** (Swap, Money Market, Bridge, Yield), then **Reference** (technical deep docs), then **Resources** last (DevRel). Prefer keeping deep page file paths stable so old links keep working; add Mintlify `redirects` for renames instead of moving synced files.
## SDK Architecture (3 Layers)

The documentation covers a dependency stack of npm packages:

1. **Foundation** (`@sodax/sdk`) — Core logic: swaps, lending, bridging, staking, migration.
2. **Connection** (`@sodax/wallet-sdk-core`, `@sodax/wallet-sdk-react`) — Multi-chain wallet management.
3. **Experience** (`@sodax/dapp-kit`) — Pre-built React hooks and components that wrap layers 1 and 2.

## Conventions

- Pages use Mintlify-flavored Markdown/MDX (frontmatter with `description` and `icon`; components like `<Card>`, `<CardGroup>`, `<Tabs>`, `<Note>`, `<CodeGroup>`, `<Columns>`, `<Steps>`).
- Commits follow the pattern `docs: <description>`.
- The sync script injects frontmatter via helper functions (`inject_frontmatter`, `inject_description_frontmatter`) — do not add frontmatter to files that will be synced.
- **Brand colors are applied globally, not per page.** `<Note>` is themed to SODAX cherry in `custom.css` (Mintlify ships it blue) — just use `<Note>` and it comes out on-brand. Don't reach for `<Callout variant="custom" color="#A55C55">` on individual pages. `Warning` / `Danger` / `Tip` / `Check` intentionally keep Mintlify's semantic colors.
- **Raw HTML in MDX must be JSX-safe.** Mintlify compiles pages as MDX: use `className` (not `class`), and avoid `<strong>` / other tags Mintlify remaps poorly. Prefer `<span>` for emphasis hooks styled in `custom.css`, or Markdown `**bold**`. Example pattern: the homepage hero + stat strip in `index.mdx` (`className` + `<span id="...">`).
- **Writing / clarity (no repeated sidebar or intro text):** see [`DOCS_WRITING.md`](DOCS_WRITING.md). Keep that file for docs style; keep this file for repo architecture and sync.

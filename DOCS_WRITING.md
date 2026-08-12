# Docs writing guide (Mintlify)

Use this file when editing hand-maintained Mintlify pages in `sodax-document`. Keep `CLAUDE.md` for repo/sync architecture; put writing and clarity rules here.

## Where content lives

- **Synced from upstream** — do not hand-edit; change the source repo / wiki, then run `sync-sodax-sdks.sh`. See `CLAUDE.md`.
- **Hand-edited here** — homepage, `quickstart.mdx`, `docs.json`, `custom.css`, technical overview, Solana, FAQ, contact, deployments wrappers, `developers/http-api/`, `developers/audits/index.md`, solution hubs (`swap/`, `money-market/`, `bridge/`, `yield/`), and **Resources / DevRel** (`resources/`).

## Solution hubs vs Reference vs Resources

| Area | Job | Owners |
|------|-----|--------|
| Solution hubs (Swap / Money Market / Bridge / Yield) | Outcome first — hub overview with cards to HTTP / SDK / how-tos | Engineering / docs |
| Get Started | Onboarding + network guides (Solana, Bitcoin) | Engineering / docs |
| Reference | Canonical deep docs: HTTP API, SDKs, How To, architecture, deployments | Engineering |
| Resources (always last tab) | Videos, blog, changelog, FAQ, audits | DevRel / community (Hazy, John); eng registers new pages in `docs.json` |

Do not put API/SDK method docs in Resources. Do not invent write APIs for Money Market / Bridge — link to contact until they exist.

### One home per page (Mintlify)

List each page in **exactly one** tab in `docs.json`. Mintlify picks a single sidebar owner; duplicates make the wrong tab look selected (e.g. Reference click → Swap sidebar).

| Content type | Canonical home | Elsewhere |
|--------------|----------------|-----------|
| Solution overview (`swap`, `money-market`, …) | That solution tab (hub only) | Link from Home / Get Started cards |
| HTTP API, SDK modules, deployments, architecture | Reference | Link from solution hub cards |
| Task guides (`HOW_TO_*`, configure, monetize, …) | Reference → How To | Link from hubs / Get Started |
| Solana / Bitcoin network guides | Get Started → Network guides | Link from hubs (do not re-list in Reference or solution sidebars) |

Solution tabs stay thin on purpose: the hub page is the router; deep pages live once under Reference (or Get Started for networks).

## Redirects

When renaming or retiring a page, add a `redirects` entry in `docs.json` (`source` → `destination`) instead of leaving a 404. Prefer stable paths for synced content.
## No repeated text

Mintlify already shows `title` (and often `description`) above the body. **Never** restate them.

| Layer | Job | Do not |
|-------|-----|--------|
| `docs.json` group label | Section name in the sidebar | Call the group `Overview`, or duplicate that string as the first page’s sidebar label |
| Frontmatter `title` | Page H1 | Repeat as a `#` heading in the body (sync script strips this for synced pages; hand-edited pages must not add it either) |
| Frontmatter `description` | One-line subtitle under the H1 | Open the body with the same sentence or a close paraphrase |
| Frontmatter `sidebarTitle` | Short sidebar label | Mirror the group name (e.g. group `HTTP API` + sidebar `HTTP API`) |

**Bad — double title + echoed description** (what readers see: group eyebrow, H1, subtitle, then the same H1 again):

```md
---
title: The SDK Stack
description: Foundation, Connection, and Experience — the SODAX dependency stack, layer by layer.
---

# The SDK stack

The SODAX developer suite is a dependency stack. …
```

**Good — body adds information only:**

```md
---
title: The SDK Stack
description: Foundation, Connection, and Experience — the SODAX dependency stack, layer by layer.
---

Integrate at the foundation for maximum control, or use the higher layers for speed.

### 1. Foundation: @sodax/sdk
```

Rules of thumb:

- No leading `#` in page bodies. Use `##` / `###` for sections.
- If the first paragraph only rephrases `description`, delete it and start with the first real section or a new point.
- Do not wrap Home (or any single section) in a group named `Overview` — that prints “Overview” above every page title. Prefer tab-level `pages`, or a specific group name.

**Group index pattern** (Deployments / SDKs / HTTP API / How To):

In `docs.json`, reference folder indexes explicitly as `path/index` (not bare `path`) so Mintlify resolves the file. Do **not** use group `root` against bare folder paths — local `mint dev` reports “file does not exist” and client navigation can blank the page when switching routes.

```json
{
  "group": "HTTP API",
  "icon": "server",
  "pages": [
    "developers/http-api/index",
    "developers/http-api/swaps"
  ]
}
```

Page frontmatter sets the H1 / sidebar label / icon:

```yaml
title: "HTTP API"          # full H1
sidebarTitle: "Overview"   # short sidebar entry under the group
icon: server
```

If a listed page still shows a path-derived label (e.g. “Http api”) or drops its icon, flatten it to a sibling `.md` / `.mdx` (see AI Integration in `sync-sodax-sdks.sh`) — folder `index` frontmatter is unreliable in the sidebar.

Child pages under a named group: prefer a short `sidebarTitle` (`Oracle`, `Swaps`) and keep the fuller `title` for the page H1 (`Oracle API`).

## Solver / marketplace language (entity separation)

SODAX is non-custodial protocol and software. It **routes and settles**. Independent solvers on the marketplace **fill**. Docs must not imply SODAX trades, takes custody, or owns/operates a solver.

**Memorize:** SODAX routes and settles. Solvers fill.

| Do not say | Say instead |
|------------|-------------|
| "our solver" / "the SODAX solver" | "the solver" / "a solver on the marketplace" |
| "SODAX fills your order" | "SODAX routes and settles. Solvers fill." |
| "SODAX trades across networks" | "SODAX provides cross-network execution infrastructure. Solvers provide the liquidity." |
| "SODAX manages / runs the solver" | (omit; or if a partner asks who trades: separate entities — do not volunteer Blockzen in outbound docs) |
| "mainnet solver" (singular ownership) | "solvers on mainnet" / "the marketplace" |
| Module title "Swaps (Solver)" | "Swaps" |

**Ownership test:** things (contracts, venues, marketplace, SDK, rails) are SODAX. Actions (pricing, route selection, committing capital, filling, inventory, rebalancing) belong to the solver. Prefer "solvers access" for venues — never "solver owns" Money Market / AMM / intents.

**Do not** proactively advertise the entity structure or Blockzen in docs. Surface the trading-entity split only when a partner due-diligence question requires it. Do not claim live KYT/sanctions screening until that provider is confirmed live.

Synced SDK pages: keep titles/descriptions solver-safe in `sync-sodax-sdks.sh` injects so a re-sync does not restore "Swaps (Solver)" / "mainnet solver" wording.

## Clarity checklist (before merging)

- One idea per section; one H2 purpose.
- Link to sibling pages instead of copying the same explanation.
- Prefer relative Mintlify paths (`/developers/...`) over hard-coded `https://docs.sodax.com/...` for in-site pages.
- Brand casing: **SODAX**, **SDK**, **API**, **FAQ**; scanner is **SODAX Scan** / sodaxscan.com (not xCall).
- Heading case: start every `##` / `###` with a capital letter (or a proper noun). Prefer sentence case. Don’t leave product CLI names uncapitalized at the start of a heading (`Skills CLI`, not `skills CLI`). For `npm`, rewrite as `Install from npm` rather than starting with lowercase.
- Use shared components (`<Note>`, `<Card>`, `<CardGroup>`, …). Brand `<Note>` via `custom.css` — do not set custom callout colors per page.
- New pages must be added to `docs.json` or they will 404 in nav.

## Importing content from other repos

When folding in drafts (e.g. SDK PRs):

1. Place files under the canonical Mintlify tree in **this** repo — do not add a second `docs.json` Mintlify site elsewhere.
2. Fix links to match `docs.json` routes.
3. Apply the no-repeat / `sidebarTitle` rules above.
4. Flag Preview / canary surfaces with `<Note>` when not production-ready.

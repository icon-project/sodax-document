# Docs writing guide (Mintlify)

Use this file when editing hand-maintained Mintlify pages in `sodax-document`. Keep `CLAUDE.md` for repo/sync architecture; put writing and clarity rules here.

## Where content lives

- **Synced from upstream** — do not hand-edit; change the source repo / wiki, then run `sync-sodax-sdks.sh`. See `CLAUDE.md`.
- **Hand-edited here** — homepage, `docs.json`, `custom.css`, technical overview, Solana, FAQ, contact, deployments wrappers, `developers/http-api/`, solution hubs (`swap/`, `money-market/`, `bridge/`, `yield/`), and **Resources / DevRel** (`resources/`).

## Solution hubs vs Reference vs Resources

| Area | Job | Owners |
|------|-----|--------|
| Solution hubs + homepage Tabs | Outcome first (Swap / Money Market / Bridge / Yield), then HTTP API vs SDK | Engineering / docs |
| Reference | Deep SDK tree, deployments, architecture, shared HTTP (oracle/stats) | Engineering |
| Resources (always last tab) | Videos, blog, changelog, FAQ, audits | DevRel / community (Hazy, John); eng registers new pages in `docs.json` |

Do not put API/SDK method docs in Resources. Do not invent write APIs for Money Market / Bridge — link to contact until they exist.

## Redirects

When renaming or retiring a page, add a `redirects` entry in `docs.json` (`source` → `destination`) instead of leaving a 404. Prefer stable paths for synced content.
## No repeated text

Mintlify already shows `title` (and often `description`) above the body. Do not restate them in the first paragraph.

| Layer | Job | Do not |
|-------|-----|--------|
| `docs.json` group label | Section name in the sidebar | Duplicate that string as the first page’s sidebar label |
| Frontmatter `title` | Page H1 | Repeat as a `#` heading in the body (sync script strips this for synced pages; hand-edited pages must not add it either) |
| Frontmatter `description` | One-line subtitle under the H1 | Open the body with the same sentence |
| Frontmatter `sidebarTitle` | Short sidebar label | Mirror the group name (e.g. group `HTTP API` + sidebar `HTTP API`) |

**Group index pattern** (already used by Deployments / SDKs):

```yaml
title: "HTTP API"          # full H1
sidebarTitle: "Overview"   # short sidebar entry under the group
```

Child pages under a named group: prefer a short `sidebarTitle` (`Oracle`, `Swaps`) and keep the fuller `title` for the page H1 (`Oracle API`).

## Clarity checklist (before merging)

- One idea per section; one H2 purpose.
- Link to sibling pages instead of copying the same explanation.
- Prefer relative Mintlify paths (`/developers/...`) over hard-coded `https://docs.sodax.com/...` for in-site pages.
- Brand casing: **SODAX**, **SDK**, **API**, **FAQ**; scanner is **SODAX Scan** / sodaxscan.com (not xCall).
- Use shared components (`<Note>`, `<Card>`, `<CardGroup>`, …). Brand `<Note>` via `custom.css` — do not set custom callout colors per page.
- New pages must be added to `docs.json` or they will 404 in nav.

## Importing content from other repos

When folding in drafts (e.g. SDK PRs):

1. Place files under the canonical Mintlify tree in **this** repo — do not add a second `docs.json` Mintlify site elsewhere.
2. Fix links to match `docs.json` routes.
3. Apply the no-repeat / `sidebarTitle` rules above.
4. Flag Preview / canary surfaces with `<Note>` when not production-ready.

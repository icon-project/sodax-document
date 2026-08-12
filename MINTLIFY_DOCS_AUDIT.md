# SODAX Docs Audit — Mintlify migration

**Branch:** `docs/complete-mintlify-migration` · **Live today:** [GitBook docs.sodax.com](https://docs.sodax.com/) · **Reviewed:** Aug 2026

Where the Mintlify branch stands vs live GitBook, closest functional competitors, and best-in-class docs homepages — and what to change so the homepage wins the first five seconds.

| Lens | Status |
|------|--------|
| IA & product framing | Ahead |
| Homepage 5-sec clarity | Mixed |
| API UX & proof stats | Behind |
| AI / MCP / skills | Unique |

**Verdict:** Mintlify already beats GitBook on structure, onboarding, and dual API/SDK paths. It does not yet beat Across on first-screen clarity or LI.FI / Socket on integration surface completeness. Win the homepage by cutting essay, leading with one path, and putting builder-proof numbers above the fold.

---

## 1. Executive summary

The migration is a real upgrade in information architecture: solution hubs (Swap / Money Market / Bridge / Yield), a 5-minute quickstart, partner HTTP API docs, Solana guides, and Mintlify AI affordances (copy page, MCP, assistant). Live GitBook still reads like a long product essay with a developer dump underneath.

Competitive risk is not “missing pages” — it is the first five seconds. Across opens with one promise + three proof stats + three CTAs. SODAX Mintlify opens with a hero image, search, a stat strip, a how-it-works strip, then solution tabs with code. That is richer than GitBook, but denser and less decisive than category leaders.

### Keep / double down

- Solution-led tabs + thin hubs → Reference
- 5-minute swap quickstart
- HTTP API + SDK dual path (Swap / Yield)
- Builders MCP + `@sodax/skills`
- Writing rules (no title echo)
- Redirects from GitBook URLs

### Fix before / at launch

- Homepage: one primary CTA in first viewport
- Proof stats competitors use (volume, fill time, partners)
- OpenAPI / interactive Swap API reference
- Populate Resources (changelog, videos) or hide stubs
- Honest gaps: MM/Bridge HTTP “notify me” still weak

---

## 2. Competitive landscape

Closest functional peers = cross-network swap/bridge/intent infrastructure. Best-in-class homepage pattern = Across + LayerZero (pick path in &lt;5s).

| Player | Category role | Docs homepage pattern | Implication for SODAX |
|--------|---------------|----------------------|------------------------|
| Across | Intent bridge / Swap API | One line + $35B / &lt;2s / 26+ chains + 3 CTAs | Gold standard for first five seconds |
| LI.FI | Aggregation / orchestration | Capability list → without/with table → SDK / API / Widget | Shows three surfaces clearly; widget path missing at SODAX |
| Socket / Bungee | Money movement routing | Route money framing + API + Widget + AI agents | Widget + agent paths are first-class |
| LayerZero | Messaging (category IA) | Pick VM / product immediately | Best “choose your entry” IA — SODAX hubs rhyme with this |
| GitBook SODAX (live) | Your current public docs | Long essay: stack, execution model, partner table | Credibility prose; weak “ship now” path |
| Mintlify SODAX (branch) | Your migration | Hero + stats + how-it-works + solution Tabs + code | Better than GitBook; still denser than Across |

### Capability matrix

| Capability | SODAX Mintlify | Across | LI.FI | Socket |
|------------|----------------|--------|-------|--------|
| Intent / solver framing | Yes | Yes | Partial | Partial |
| HTTP Swap API docs | Yes | Strong | Strong | Strong |
| Typed SDK docs | Strong | Yes | Strong | Yes |
| Money market / lend-borrow | Yes (unique) | No | Adjacent | No |
| Yield / vault HTTP | Preview | No | Earn/zap | Deposit |
| Embeddable widget | No | UI link | Yes | Yes |
| Interactive API playground | Weak | Strong | Strong | Strong |
| AI skills / MCP | Strong (unique) | Skills | Agent guide | AI agents |

Sources: [docs.across.to](https://docs.across.to/), [docs.li.fi](https://docs.li.fi/introduction/introduction), [docs.socket.tech](https://docs.socket.tech/), [docs.layerzero.network](https://docs.layerzero.network/v2), [docs.sodax.com](https://docs.sodax.com/), sodax-document Mintlify branch.

---

## 3. Gap analysis

### A. Mintlify vs live GitBook — what improved

| Area | GitBook (live) | Mintlify (branch) | Delta |
|------|----------------|-------------------|-------|
| Nav model | Welcome + Developers dump | Solution tabs → Reference → Resources | Much clearer for product intent |
| Homepage job | Explain SODAX (essay) | Route builder to API/SDK + code | Action over narrative |
| Onboarding | Buried in SDK tree | Get Started + 5-min quickstart | Time-to-first-call drops |
| HTTP API | Thin / secondary | Hand-maintained partner HTTP section | Language-agnostic path exists |
| Network guides | Solana as separate book | Solana under Get Started + Bitcoin | Same content, better placement |
| AI builders | MCP CTA on homepage | MCP + skills + contextual AI menu | Platform advantage |
| URL hygiene | GitBook paths | Large redirects map in `docs.json` | Migration-ready |

### B. What GitBook still does better

| Gap | Detail | Severity |
|-----|--------|----------|
| Partner-type table on home | Wallets / DEXs / Lending / Perps — moved to Why SODAX in Mintlify | Medium — useful for BD, not for ship-now |
| Single narrative arc | GitBook tells one story; Mintlify home has more competing modules | Medium for first visit |
| Production = GitBook | SEO and partner bookmarks still hit the old site until merge | Ops — until cutover |
| Cover cards (xStocks / Bitcoin) | Visual product teasers on GitBook home | Low — replace with hubs |

### C. Missing vs category (not GitBook)

**High — missing / weak**

- Homepage proof: volume, fill time, # partners live
- Interactive OpenAPI for Swap (try / copy schemas)
- Widget / embed path (competitors lead with it)
- Resources stubs (videos, changelog “coming soon”)
- Error catalog / failure-mode playbook
- Status page link in navbar

**Known product gaps (docs already say)**

- Money Market HTTP write API → contact form
- Bridge hosted API → contact form
- Mainnet-only (no competitor-style testnet sandbox)
- Yield HTTP still Preview / canary

### D. Content completeness snapshot (branch)

| Surface | Status | Note |
|---------|--------|------|
| Swap hub + SDK + HTTP | Strong | Primary path; matches competitor focus |
| SDK stack / how-tos / deployments | Strong | Synced + hand wrappers |
| Money Market hub | SDK-only | Correct honesty; weak vs “full product” story |
| Bridge hub | SDK-only | Same |
| Technical overview + audits | Strong | Credibility layer intact |
| AI integration / MCP | Differentiator | Ahead of most peers |
| Resources / DevRel | Empty shells | Risk of looking unfinished at launch |

---

## 4. Homepage plan — win the first five seconds

Goal: a builder who lands cold should answer three questions in five seconds — what is this, can I ship it, where do I click — without reading an essay.

| | Across (target bar) | SODAX Mintlify today | Proposed SODAX home |
|--|---------------------|----------------------|---------------------|
| Promise | Fastest crosschain infra for builders | Hero image + “What can we help you build?” | One line: routes & settles; solvers fill |
| Proof | $35B+ · &lt;2s · 26+ chains | 21+ nets · 30+ assets · 137+ tokens · 8 audits | Live volume / partners / networks / audits |
| Paths | Integrate · API · AI Agents | Search · how-strip · 4 solution tabs · more cards | 5-min Swap · Swap HTTP · AI agents |

### Recommended first viewport (above the fold)

1. **Brand + one sentence** — e.g. “Cross-network swaps, lend/borrow, and settlement — one integration. SODAX routes and settles; solvers fill.”
2. **Three proof stats (builder-credible)** — Prefer: filled volume or partner count · networks · audits (or median fill time if publishable). Drop “tokens supported” from hero if it crowds the bar.
3. **Three CTAs only** — Primary: 5-minute swap · Secondary: Swap HTTP API · Tertiary: AI agents / Builders MCP
4. **Everything else below the fold** — How-it-works strip → solution Tabs (Swap default) → dapp-kit note → audits → Go deeper. Do not put marketing “What you get” bullets above the fold.

### Keep vs cut on the current homepage

| Block | Decision | Why |
|-------|----------|-----|
| Hero brand + search | Keep, simplify | Search is fine; hero image optional / quieter |
| Stat strip | Keep, re-rank | Lead with proof that closes deals |
| Builders MCP Note | Keep, demote | AI path is tertiary CTA, not first paragraph |
| How it works 01–03 | Keep below fold | Differentiates intent model in ~10s |
| Solution Tabs + code | Keep below fold | Best Mintlify improvement vs GitBook |
| “What you get” bullets | Cut or move | Echoes GitBook essay; slows scan |
| Audits + Go deeper | Keep footer zone | Credibility + escape hatches |

**Positioning:** Do not compete with Across on “fastest bridge.” Compete on breadth of execution (swap + money market + yield) and honesty of the fill model. The homepage should make that difference feel obvious in one sentence, then force a single ship path (Swap).

---

## 5. Action list

### P0 — before or at Mintlify cutover

- [ ] Rewrite homepage first viewport to promise + proof + 3 CTAs (primary = 5-min Swap; move essay bullets off home)
- [ ] Publish 1–2 competitive proof metrics on home (volume / partners / fill time) — not only network/token counts
- [ ] Ship or hide empty Resources (first changelog + 1 video, or collapse stubs from nav)
- [ ] Cutover: DNS, redirects, llms.txt, GA4, broken-link crawl of top GitBook URLs

### P1 — close competitor gaps (30–60 days)

- [ ] Interactive Swap OpenAPI / try-it — Across/LI.FI/Socket win on API reference UX
- [ ] Failure-mode / `error.code` playbook for swaps next to quickstart (`Result<T,E>` terminal states)
- [ ] Status + Scan in navbar (or footer primary) for operational trust
- [ ] Upgrade MM/Bridge “notify me” with waitlist + timeline
- [ ] Decide: position dapp-kit as the Widget path on home, or ship a real embed

### P2 — category polish

- [ ] Optional “Build as…” strip (wallet / DEX / lending) below fold — recover GitBook partner table
- [ ] Surface bug bounty next to audits if one exists
- [ ] Brand typography in `docs.json` (currently Inter)

---

## Bottom line

The Mintlify migration already improves the product story vs GitBook: solution-led IA, dual API/SDK, real quickstart, AI tooling. Against Across / LI.FI / Socket, SODAX wins on multi-product execution (money market + yield) and AI/MCP — and loses on homepage decisiveness, API playground UX, and widget-class embed framing.

**Highest ROI change:** compress the homepage to promise → proof → three CTAs, keep solution tabs below the fold, and do not launch with empty Resources stubs.

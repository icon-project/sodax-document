---
description: >-
  One SDK. Every network. Scope the integration from your own repo before you
  commit.
---

# Build with SODAX

{% hint style="success" %}
**See what integration takes before you commit.** Run the SODAX Builders MCP locally against your own codebase. Your AI assistant reads your repo and maps exactly what a SODAX integration looks like and how light the work is. One integration reaches all networks. No call required.

[Try the Builders MCP](https://builders.sodax.com/)
{% endhint %}

{% embed url="https://gist.github.com/DavidFBD/5317ad739330cecd497010655187b8bc" %}

***

<table data-card-size="large" data-view="cards"><thead><tr><th></th><th data-hidden data-card-cover data-type="image">Cover image</th></tr></thead><tbody><tr><td>Integrate the SODAX SDK and get access to all networks<br><a href="developers/packages/foundation/sdk/" class="button primary" data-icon="cup-straw">@sodax/sdk</a></td><td><a href=".gitbook/assets/sodax-sdk-2.jpg">sodax-sdk-2.jpg</a></td></tr><tr><td><p>Integrate Bitcoin as a source or destination chain</p><p><a href="https://docs.sodax.com/developers/how-to/bitcoin-integration" class="button primary" data-icon="bitcoin">Bitcoin Integration</a></p></td><td><a href=".gitbook/assets/1779804933397-Blog__56_.webp">1779804933397-Blog__56_.webp</a></td></tr></tbody></table>

### What SODAX gives you

SODAX is execution infrastructure for modern money. You integrate one SDK, and your app can exchange, lend, borrow, and settle across blockchain networks as if there were no boundaries.

Most cross-network systems move assets. SODAX coordinates execution: it plans liquidity, timing, and recovery so an action started on one network completes predictably on another, even when conditions change mid-flight.

You integrate through a single SDK surface and keep full control of your user experience, pricing logic, and risk parameters. SODAX handles how execution behaves when networks are slow, fragmented, or partially available.

Three things you get out of one integration:

* **One surface, every network.** Build once against @sodax/sdk and reach all 18 connected networks.
* **Execution that settles, not just routes.** Swaps, borrows, and deposits complete across networks under real conditions, with explicit handling for delays and partial completion.
* **Your app stays yours.** You own the UX, the pricing, and the risk parameters. SODAX is infrastructure underneath, not a front end on top.

***

### The SDK stack

The SODAX developer suite is a dependency stack. Integrate at the foundation for maximum control, or use the higher layers for speed.

#### 1. Foundation: @sodax/sdk

The core logic layer that powers everything else. Raw functional modules to build with SODAX programmatically.

Functional modules:

* **Swaps** — quote and execute cross-network intents through the Solver.
* **Lend / Borrow** — interact directly with the SODAX money market.
* **Bridge** — low-level primitives for asset transfer.
* **Staking** — manage SODA staking and governance positions.
* **Migration** — utilities for migrating ICX to SODA.

Tooling modules:

* **Backend API** — useful data points for each feature.
* **Intent Relay API** — direct access to the intent propagation network.

#### 2. Connection layer

Manages connecting user wallets across heterogeneous networks (EVM, SVM, and non-EVM blockchain networks). Two flavors:

* **@sodax/wallet-sdk-core (TypeScript)** — a pure TypeScript implementation of wallet providers. Use this for a custom frontend framework or a non-React app.
* **@sodax/wallet-sdk-react (React adapter)** — an opinionated wrapper for React, with pre-built context providers and state management for wallet connections.

#### 3. Experience layer: @sodax/dapp-kit

The highest-level layer, built for speed. An opinionated set of UI components, hooks, and utilities built on the layers below.

* Under the hood: automatically wires @sodax/wallet-sdk for connection and @sodax/sdk for execution.
* What it offers: React hooks, contexts, and utilities for SODAX features.

***

### How execution works

Cross-network execution is asynchronous by nature, depends on liquidity fragmented across networks, and is exposed to volatility and partial completion. Asset transfers can succeed while the action they were meant to enable fails: collateral arrives but the borrow does not fill, a quoted price cannot be filled when execution begins.

SODAX is built to coordinate execution across those realities, end to end, so DeFi actions complete predictably. Three components make that possible.

#### Intent-based execution

You express an intent, a desired outcome, and SODAX fulfills it. Users do not hand-route transactions.

* **Solver coordination.** The proprietary Solver plans execution across networks based on liquidity, pricing, network constraints, and your builder-defined parameters. It decides and coordinates, it is not a passive relay.
* **Outcome-oriented settlement.** Routes are quoted from coordinated liquidity or external venues based on current conditions, then executed explicitly once approved.
* **Explicit asynchronous handling.** Multi-step execution, partial completion, and recovery paths are handled deliberately, so flows that cannot complete atomically still complete reliably.

#### Unified liquidity

SODAX treats liquidity as one system-level inventory, not isolated pools per network.

* **Global execution inventory.** Assets are accounted for across networks and coordinated to fulfill cross-network intents.
* **Solver-accessed at execution time.** The Solver draws on liquidity when planning and executing, then redistributes it to keep the system balanced.
* **Less fragmentation risk.** Execution no longer depends on the right liquidity sitting on a specific network at a specific moment.

#### Smart wallet abstraction

SODAX coordinates cross-network account state as part of the execution layer, rather than relying on separate wallets per network.

* **Deterministic execution wallets.** Users get deterministic smart wallets that act as one consistent execution identity across networks.
* **Unified execution account.** Apps execute cross-network actions through a single wallet context, not separate accounts and approvals per network.
* **Simplified coordination.** SODAX handles wallet creation and execution routing, so you focus on what happens after execution.

***

### What you can build

SODAX is a modular execution system. Integrate each SDK module on its own, or combine them.

<table><thead><tr><th width="222.0390625">Partner Type</th><th>What you can build with SODAX</th></tr></thead><tbody><tr><td><strong>Wallets</strong></td><td>Use <strong>Swaps (Solver)</strong> to offer cross-network swaps in your UI, plus <strong>Bridge</strong> primitives where needed for asset transfer. Use <strong>Lend / Borrow (Money Market)</strong> to integrate lending primitives.</td></tr><tr><td><strong>DEXs &#x26; Aggregators</strong></td><td>Use <strong>Swaps (Solver)</strong> to quote and execute cross-network intents and expand routing beyond single-network liquidity</td></tr><tr><td><strong>Lending Protocols</strong></td><td>Use <strong>Lend / Borrow (Money Market)</strong> to integrate lending primitives and support multi-network user flows around collateral and borrowing.</td></tr><tr><td><strong>Perp DEXs / Yield Apps</strong></td><td>Use <strong>Swaps (Solver)</strong> to accept deposits from other networks via swap-into-your-asset flows, then complete the deposit inside your app. Use <strong>Lend / Borrow (Money Market)</strong> to enable borrowed asset deposits with user collateral on other networks.</td></tr><tr><td><strong>New Networks</strong></td><td>Integrate SODAX to provide builders with ready-made cross-network execution capabilities and liquidity access from day one.</td></tr></tbody></table>

<p align="center"><a href="https://sodax.com/partners" class="button primary" data-icon="handshake">Go to sodax.com/partners</a></p>

### Why build with SODAX

* **Execution beyond routing.** Routes move assets. SODAX coordinates liquidity so swaps, borrows, and deposits actually settle across networks.
* **One SDK, modular usage.** Integrate @sodax/sdk once, then use only the modules you need.
* **Built for real execution conditions.** Asynchronous by nature, with explicit timeouts and clear completion or failure handling.
* **Your control preserved.** You keep ownership of user experience, pricing logic, and risk parameters.
* **Proven in production.** Live cross-network flows across heterogeneous networks with Solver-coordinated settlement. 21 protocols have integrated SODAX so far.

***

### Ecosystem reach

* **Networks:** 18+ networks spanning EVM and non-EVM environments, including Ethereum, Arbitrum, Base, BNB Chain, Avalanche, Optimism, Polygon, Solana, Sui, Stellar, Injective, and ICON.
* **Money market:** 26 assets available for lending and borrowing across networks.
* **Liquidity venues:** the Solver routes execution through deep venues including Uniswap V3, PancakeSwap, Raydium, Pharaoh, Cetus, and DojoSwap.
* **Infrastructure compatibility:** designed to work alongside major messaging standards (GMP) for secure intent propagation, not replace them.

***

### Protocol-owned liquidity (POL)

SODAX deploys protocol-owned liquidity as part of its unified execution inventory, so cross-network actions can complete reliably.

* **Baseline execution inventory.** Protocol-owned assets give the Solver dedicated baseline liquidity to fulfill intents when external liquidity is fragmented or unavailable.
* **System-level reliability.** Liquidity is coordinated and redistributed after execution to keep global inventory healthy and reduce failures caused by local shortages.
* **Aligned incentives.** Revenue from protocol-owned liquidity supports ongoing execution reliability and system sustainability.

Together, these provide the execution infrastructure modern money needs across networks.Together, SODAX provides the execution infrastructure required for modern money across networks.

***

### Next

* Install [@sodax/sdk](./#id-1.-foundation-sodax-sdk) and ship your first cross-network action.
* Or scope it first: run the [Builders MCP](https://builders.sodax.com/) against your repo.

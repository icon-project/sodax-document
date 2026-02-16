---
description: >-
  SODAX is execution coordination and liquidity infrastructure for modern money,
  enabling applications to deliver real DeFi use-cases and predictable outcomes
  across multiple networks.
---

# Product Overview

<table data-view="cards"><thead><tr><th></th><th data-hidden data-card-cover data-type="image">Cover image</th></tr></thead><tbody><tr><td>Go to @sodax/sdk<br><br><a href="developers/packages/foundation/sdk/" class="button primary" data-icon="cup-straw">@sodax/sdk</a></td><td><a href=".gitbook/assets/sodax-sdk-2.jpg">sodax-sdk-2.jpg</a></td></tr><tr><td><p>View SDK breakdown<br></p><p><a href="./#developer-ecosystem" class="button primary" data-icon="chevrons-down">Scroll down</a></p></td><td><a href=".gitbook/assets/sodax-sdk-3.jpg">sodax-sdk-3.jpg</a></td></tr><tr><td><p>Get in touch<br></p><p><a href="https://se8br1ugut6.typeform.com/to/ZV7lvNfW" class="button primary" data-icon="hand-wave">Contact Form</a></p></td><td><a href=".gitbook/assets/sodax-sdk.jpg">sodax-sdk.jpg</a></td></tr></tbody></table>

SODAX is built as infrastructure for modern money, coordinating how DeFi actions execute across multiple networks under real-world conditions.

Instead of treating cross-network activity as asset movement, SODAX coordinates execution behavior across fragmented liquidity, asynchronous settlement, and conditional completion.

Applications integrate through a single SDK surface while retaining control over user experience, pricing logic, and risk parameters. SODAX handles how execution behaves when network conditions change.

***

### The Core Problem

Cross-network systems can move assets, but they do not reliably deliver real DeFi actions.

Bridge transfers are executed successfully but get stranded due to missing liquidity. Collateral arrives on a destination network but borrowing fails. Routes quote a price that cannot be filled when execution begins.

This happens because cross-network execution is:

• Asynchronous by nature\
• Dependent on fragmented liquidity across networks\
• Exposed to volatility and partial completion

SODAX exists to coordinate execution across these realities.

Rather than optimizing transfers or routes in isolation, SODAX coordinates liquidity, timing, and recovery paths end to end so DeFi use-cases complete predictably under real conditions.

### Core Components

#### Intent-based execution

SODAX coordinates cross-network execution through an intent-centric model designed to support increasingly complex DeFi actions over time.

* **Proprietary Solver:** Coordinates execution flows across networks based on liquidity availability, pricing conditions, network constraints, and builder-defined parameters.
* **Outcome-oriented settlement:** Execution routes are quoted using coordinated liquidity domains or external venues based on current conditions, then executed explicitly once approved.
* **Explicit asynchronous handling:** Multi-step execution, partial completion, and recovery paths are handled deliberately, enabling flows that cannot be assumed to complete atomically.

#### Unified Liquidity Layer

SODAX treats liquidity as a unified, system-level inventory rather than isolated pools on individual networks.

* **Unified execution inventory:** Assets are accounted for globally and coordinated across networks to fulfill cross-network intents.
* **Solver-accessed at execution time:** Liquidity is used by the solver when planning and executing actions, then redistributed to maintain system balance.
* **Reduced fragmentation risk:** Execution no longer depends on liquidity being available on a specific network at a specific moment.

#### Smart Wallet Abstraction

SODAX coordinates cross-network account state as part of the execution layer rather than relying on independently managed wallets on each network.

* **Deterministic execution wallets:** SODAX automatically assigns users deterministic smart wallets that act as a consistent execution identity across networks.
* **Unified execution account:** Applications execute cross-network swaps through a single wallet context rather than managing separate accounts and approvals on each network.
* **Simplified cross-network coordination:** SODAX handles wallet creation and execution routing so applications can focus on post-execution actions.

***

### Partner Use Cases

SODAX is designed as a modular execution system. Each SDK module can be integrated independently or combined to support specific integration needs.

<table><thead><tr><th width="222.0390625">Partner Type</th><th>What you can build with SODAX</th></tr></thead><tbody><tr><td><strong>Wallets</strong></td><td>Use <strong>Swaps (Solver)</strong> to offer cross-network swaps in your UI, plus <strong>Bridge</strong> primitives where needed for asset transfer. Use <strong>Lend / Borrow (Money Market)</strong> to integrate lending primitives.</td></tr><tr><td><strong>DEXs &#x26; Aggregators</strong></td><td>Use <strong>Swaps (Solver)</strong> to quote and execute cross-network intents and expand routing beyond single-network liquidity</td></tr><tr><td><strong>Lending Protocols</strong></td><td>Use <strong>Lend / Borrow (Money Market)</strong> to integrate lending primitives and support multi-network user flows around collateral and borrowing.</td></tr><tr><td><strong>Perp DEXs / Yield Apps</strong></td><td>Use <strong>Swaps (Solver)</strong> to accept deposits from other networks via swap-into-your-asset flows, then complete the deposit inside your app. Use <strong>Lend / Borrow (Money Market)</strong> to enable borrowed asset deposits with user collateral on other networks.</td></tr><tr><td><strong>New Networks</strong></td><td>Integrate SODAX to provide builders with ready-made cross-network execution capabilities and liquidity access from day one.</td></tr></tbody></table>

<p align="center"><a href="https://se8br1ugut6.typeform.com/to/ZV7lvNfW" class="button primary" data-icon="hand-wave">Contact Form</a></p>

### Why Partners Choose SODAX

* **Execution beyond routing:** Routes move assets. SODAX coordinates liquidity so swaps, borrows, and deposits can actually settle across networks.
* **Single SDK, modular usage:** Integrate `@sodax/sdk` once, then use only the modules you need, such as Swaps, Lend/Borrow, or Bridge.
* **Designed for real execution conditions:** Cross-network execution is asynchronous by nature, with built-in timeouts and clear completion or failure handling.
* **Builder control preserved:** Partners retain ownership of user experience, pricing logic, and risk parameters.
* **Proven cross-network execution:** Live production flows across heterogeneous networks with solver-coordinated settlement.

***

### Developer Ecosystem

The SODAX developer suite is architected as a dependency stack. Builders can choose to integrate at the foundational level for maximum control or use opinionated layers for speed.

#### 1. The Foundation: [sdk](developers/packages/foundation/sdk/ "mention")

This is the core logic layer that powers the entire ecosystem. It provides the raw functional modules required to build with SODAX programmatically.

* **Functional Modules:**
  * `Swaps`: Quote and execute cross-chain intents via the solver.
  * `Lend/Borrow`: Interact directly with the SODAX money market logic.
  * `Bridge`: Core bridging primitives for asset transfer.
  * `Staking`: Management of SODA staking and governance positions.
  * `Migration`: Utilities for migrating ICX to SODA tokens.
* **Tooling Modules:**
  * `Backend API`: Provides useful data points for each feature
  * `Intent Relay API`: Direct access to the intent propagation network.

#### 2. The Connection Layer

Sitting above the core SDK, this package manages the complexity of connecting user wallets across heterogeneous chains (EVM, SVM, non-EVM). It is available in two flavors:

* [wallet-sdk-core.md](developers/packages/connection/wallet-sdk-core.md "mention") **Core (TypeScript)**: A pure TypeScript implementation of wallet providers. Use this if you are building a custom frontend framework or a non-React application.
* [wallet-sdk-react.md](developers/packages/connection/wallet-sdk-react.md "mention") **React Adapter**: An opinionated wrapper optimized for React applications, providing pre-built context providers and state management for wallet connections.

#### 3. The Experience Layer: [dapp-kit.md](developers/packages/experience/dapp-kit.md "mention")

The fastest way to build with SODAX. This is an opinionated collection of UI components, hooks, and utilities that leverages the layers below it.

* **Under the Hood:** It automatically implements `@sodax/wallet-sdk` for connection and `@sodax/sdk` for execution.
* **What it offers:** React based hooks, contexts, and utilities for SODAX features

***

### Ecosystem reach

* **Supported Networks:** 15+ heterogeneous environments including Arbitrum, BNB Chain, Avalanche, Sui, Solana, Stellar, and ICON.
* **Liquidity Sources:** The proprietary solver routes execution through deep liquidity venues like Uniswap V3, PancakeSwap, Raydium, Pharaoh, Cetus, and DojoSwap.
* **Infrastructure Compatibility:** Designed to work alongside major messaging standards (GMP) for secure intent propagation, not replace them.

***

### Protocol-owned Liquidity (POL)

SODAX deploys protocol-owned liquidity as part of its unified execution inventory to ensure cross-network actions can complete reliably.

**Baseline execution inventory:** Protocol-owned assets provide the solver with guaranteed liquidity to fulfill cross-network intents when external liquidity is fragmented or unavailable.

**System-level balance and reliability:** Liquidity is coordinated and redistributed after execution to maintain global inventory health and reduce failed actions caused by local shortages.

**Aligned long-term incentives:** Revenue generated from protocol-owned liquidity supports ongoing execution reliability and system sustainability.

***

Together, SODAX provides the execution infrastructure required for modern money across networks.

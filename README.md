---
description: >-
  SODAX is an execution coordination system that enables applications to deliver
  reliable financial outcomes across networks. Explore the intent-based
  architecture, unified liquidity layer, and the SDK.
---

# Product Overview

<a href="https://se8br1ugut6.typeform.com/to/ZV7lvNfW" class="button primary" data-icon="hand-wave">Contact Form</a>

SODAX is an execution coordination system that enables applications to perform complex financial actions across multiple networks, without owning cross-network infrastructure.

Utilizing a high-performance hub-and-spoke architecture (anchored on the Sonic blockchain), SODAX abstracts the complexity of asynchronous execution. It connects EVM and non-EVM networks through a unified intent-based system, allowing builders to integrate swapping, lending, and liquidity features while retaining full control over their user experience.

***

### The Core Problem

Cross-network systems today can move assets, but they do not reliably deliver intended outcomes. Transfers succeed while liquidity fails; routes exist but execution breaks mid-flow.

SODAX exists to absorb this complexity into infrastructure. Instead of treating cross-network activity as a simple transfer problem, SODAX treats it as an execution problem. It coordinates liquidity, routing, and recovery paths to ensure predictable results for users and builders.

### Core Components

#### Intent-based execution

SODAX replaces manual bridging with an intent-centric execution system powered by specialized infrastructure.

* **Proprietary Solver:** SODAX operates a proprietary solver that acts as the intelligence layer for the system. It quotes and routes user intents, reasoning across networks to find the most efficient execution path.
* **Outcome Optimization:** The system reasons across networks to find the most efficient path, utilizing the Unified Liquidity Layer or external AMMs to settle trades.
* **Asynchronous Recovery:** SODAX explicitly manages the reality of asynchronous networks. If an intent cannot be filled instantly due to volatility, the system provides clear recovery flows rather than silent failures.

#### Unified Liquidity Layer

SODAX does not treat liquidity as a "black box" or a static pool mirrored across chains.

* **DeFi-Native Participation:** Liquidity is sourced from a external network AMMs and a transparent, on-chain money market where capital is visible and participatory.
* **Capital Efficiency:** Solvers utilize this layer to source inventory for cross-network trades without needing to hoard idle balances on every spoke chain.

#### Smart Wallet Abstraction

SODAX eliminates the fragmentation of user identity across chains by managing the complexity of cross-network accounts.

* **Deterministic Proxy Wallets:** SODAX automatically generates deterministic smart wallets on the Hub. These allow users to have a consistent identity across chains without manual deployment or management.
* **Chain Abstraction:** This infrastructure enables complex flows, such as "swap and deposit," to be coordinated across networks. The user signs a single intent, and SODAX coordinates the asynchronous steps required to complete the action.

***

### Partner Use Cases

SODAX is designed for composability. Each module can be used independently or in combination to solve specific integration challenges.

<table><thead><tr><th width="222.0390625">Partner Type</th><th>What you can build with SODAX</th></tr></thead><tbody><tr><td><strong>Wallets</strong></td><td>Integrate native cross-network swaps, savings, and stablecoin transfers directly into your UI using a single SDK, without managing bridge connections or liquidity pools</td></tr><tr><td><strong>DEXs &#x26; Aggregators</strong></td><td>Route users to the best price across 12+ networks. Use SODAX liquidity as a settlement layer to fill orders that your local pools cannot support.</td></tr><tr><td><strong>Lending Protocols</strong></td><td>Enable "Cross-Network Collateral." Allow users to supply assets on one network (e.g., Ethereum) and borrow against them on another (e.g., Solana) instantly</td></tr><tr><td><strong>Perp DEXs / Yield Apps</strong></td><td>Accept deposits from any network. Users can deposit USDC from Solana, and SODAX settles it into your protocol's native asset (e.g., USDC on Sonic) automatically.</td></tr><tr><td><strong>New Networks</strong></td><td>Bootstrap initial liquidity and stablecoin utility on day one by connecting your new chain to the SODAX Hub, instantly accessing liquidity from established networks</td></tr></tbody></table>

<p align="center"><a href="https://se8br1ugut6.typeform.com/to/ZV7lvNfW" class="button primary" data-icon="hand-wave">Contact Form</a></p>

### Why Partners Choose SODAX

We position SODAX as serious infrastructure for builders who want results, not hype.

* **Composability by Design:** Every component (wallets, lending, swaps) is SDK-accessible and independently usable. You don't have to adopt the whole stack to solve one problem.
* **True Network Abstraction:** We connect EVM and non-EVM environments (like Solana and Stellar) seamlessly via intent-based messaging. Your users shouldn't have to care which network they are on.
* **Shared Economics**: Partners participate in the value they create. We offer revenue sharing on protocol fees and solver execution for volume routed through your integration.
* **Invisible Complexity:** We handle the routing, bridging, and error recovery in the background, so you can offer a frictionless user experience without the operational headache

***

### Developer Ecosystem

The SODAX developer suite is architected as a dependency stack. Builders can choose to integrate at the foundational level for maximum control or use opinionated layers for speed.

#### 1. The Foundation: [sdk](developers/packages/sdk/ "mention")

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

* [wallet-sdk-core](developers/packages/wallet-sdk-core/ "mention") **Core (TypeScript)**: A pure TypeScript implementation of wallet providers. Use this if you are building a custom frontend framework or a non-React application.
* [wallet-sdk-react](developers/packages/wallet-sdk-react/ "mention") **React Adapter**: An opinionated wrapper optimized for React applications, providing pre-built context providers and state management for wallet connections.

#### 3. The Experience Layer: [dapp-kit](developers/packages/dapp-kit/ "mention")

The fastest way to build with SODAX. This is an opinionated collection of UI components, hooks, and utilities that leverages the layers below it.

* **Under the Hood:** It automatically implements `@sodax/wallet-sdk` for connection and `@sodax/sdk` for execution.
* **What it offers:** React based hooks, contexts, and utilities for SODAX features

***

### Ecosystem reach

* **Supported Networks:** 12+ heterogeneous environments including Arbitrum, BNB Chain, Avalanche, Sui, Solana, Stellar, and ICON.
* **Liquidity Sources:** The proprietary solver routes execution through deep liquidity venues like Uniswap V3, PancakeSwap, Raydium, Pharaoh, Cetus, and DojoSwap.
* **Infrastructure Compatibility:** Designed to work alongside major messaging standards (GMP) for secure intent propagation, not replace them.

***

### Protocol-owned Liquidity (POL)

SODAX actively deploys Protocol-owned Liquidity to bootstrap the network and support solver execution.

* **Bootstrapping Reliability:** By owning its own liquidity, SODAX ensures that the solver always has access to a baseline inventory for supported assets.
* **Sustainable Yield:** Revenue generated from this liquidity flows back into the protocol, aligning the long-term health of the system with the success of its partners.

***



###

***

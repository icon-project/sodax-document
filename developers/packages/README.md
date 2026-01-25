---
description: Software development kits available to the integrators.
icon: screwdriver-wrench
---

# SDKs

The SODAX developer suite is architected as a dependency stack. Builders can choose to integrate at the foundational level for maximum control or use opinionated layers for speed.

**1. The Foundation:** [sdk](1.-the-foundation/sdk/ "mention")

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

**2. The Connection Layer**

Sitting above the core SDK, this package manages the complexity of connecting user wallets across heterogeneous chains (EVM, SVM, non-EVM). It is available in two flavors:

* [wallet-sdk-core.md](2.-the-connection-layer/wallet-sdk-core.md "mention") **Core (TypeScript)**: A pure TypeScript implementation of wallet providers. Use this if you are building a custom frontend framework or a non-React application.
* [wallet-sdk-react.md](2.-the-connection-layer/wallet-sdk-react.md "mention") **React Adapter**: An opinionated wrapper optimized for React applications, providing pre-built context providers and state management for wallet connections.

**3. The Experience Layer:** [dapp-kit.md](3.-the-experience-layer/dapp-kit.md "mention")

The fastest way to build with SODAX. This is an opinionated collection of UI components, hooks, and utilities that leverages the layers below it.

* **Under the Hood:** It automatically implements `@sodax/wallet-sdk` for connection and `@sodax/sdk` for execution.
* **What it offers:** React based hooks, contexts, and utilities for SODAX features

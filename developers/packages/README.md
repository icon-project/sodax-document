---
description: Software development kits available to the integrators.
icon: screwdriver-wrench
---

# SDKs

The SODAX developer suite is architected as a dependency stack. Builders can choose to integrate at the foundational level for maximum control or use opinionated layers for speed.

**1. The Foundation:** [sdk](foundation/sdk/ "mention")

This is the core logic layer that powers the entire ecosystem. It provides the raw functional modules required to build with SODAX programmatically.

* **Functional Modules:**
  * `Swaps`: Quote and execute cross-chain intents via the solver.
  * `Lend/Borrow`: Interact directly with the SODAX money market logic.
  * `Bridge`: Core bridging primitives for asset transfer.
  * `DEX`: Asset wrapping plus concentrated-liquidity positions and rewards.
  * `Leverage Yield`: Cross-chain deposits into leveraged ERC-4626 vaults on the Sonic hub.
  * `Staking`: Management of SODA staking and governance positions.
  * `Migration`: Utilities for migrating ICX to SODA tokens.
  * `Recovery`: Returning assets stranded in a user's hub wallet after a half-completed operation.
* **Tooling Modules:**
  * `Backend API`: Provides useful data points for each feature
  * `Intent Relay API`: Direct access to the intent propagation network.
  * `Swaps API`: Typed client for the backend Swaps API v2.

Two further packages sit in this layer: [swaps-api.md](foundation/swaps-api.md "mention") — a standalone wire client for the Swaps API v2 that does not depend on `@sodax/sdk` — and [types.md](foundation/types.md "mention"), the shared chain, token and wallet-provider types every `@sodax/*` package builds on.

**2. The Connection Layer**

Sitting above the core SDK, this package manages the complexity of connecting user wallets across heterogeneous chains (EVM, SVM, non-EVM). It is available in two flavors:

* [wallet-sdk-core.md](connection/wallet-sdk-core.md "mention") **Core (TypeScript)**: A pure TypeScript implementation of wallet providers. Use this if you are building a custom frontend framework or a non-React application.
* [wallet-sdk-react.md](connection/wallet-sdk-react.md "mention") **React Adapter**: An opinionated wrapper optimized for React applications, providing pre-built context providers and state management for wallet connections.

**3. The Experience Layer:** [dapp-kit.md](experience/dapp-kit.md "mention")

The fastest way to build with SODAX. This is an opinionated collection of UI components, hooks, and utilities that leverages the layers below it.

* **Under the Hood:** It automatically implements `@sodax/wallet-sdk` for connection and `@sodax/sdk` for execution.
* **What it offers:** React based hooks, contexts, and utilities for SODAX features

Alongside it, [skills.md](experience/skills.md "mention") ships consumer-facing AI skills and knowledge so coding agents write v2-correct `@sodax/*` code.

**4. Examples:** [examples](examples/ "mention")

Reference apps you can run, one per integration style — a React demo covering every feature service, backend Node scripts, the wallet modal on its own, and a standalone Swaps API app. Each guide in these docs links to whichever of them is its working counterpart.

# Product Overview

Sodax is a modular DeFi infrastructure stack built to abstract cross-chain complexity and unlock unified liquidity across EVM and non-EVM chains. It enables builders to integrate swapping, lending, stablecoin minting, and wallet management into their applications with minimal effort.

By coordinating execution through a hub-based intent system and abstracted wallets, Sodax simplifies liquidity access and execution routing across chains all while enabling partners to participate in and earn from protocol activity.

***

### Key Modules

#### Cross-Chain Swaps

Sodax enables cross-chain swaps through an intent-based execution system. Users define what they want to swap; the solver borrows liquidity, routes trades via external AMMs, and delivers the output asset to the destination chain.

* Unified swap interface across all supported chains
* Executes through integrated AMMs (Uniswap, PancakeSwap, Raydium, etc.)
* Solvers manage rebalancing and repayment
* SDK exposes quote, route, and execute functionality

#### Lending and Borrowing

The Sodax money market is a multi-chain, capital-efficient lending protocol built on a fork of Aave v3. It supports single-sided liquidity provision across all supported networks, enabling users to supply assets independently of pairs and without impermanent loss. The protocol supports asset-specific interest rate strategies per chain, and the yield generated is distributed back to suppliers and the protocol treasury.

In addition to user participation, the Sodax solver system is also integrated with the money market. Solvers borrow liquidity temporarily to execute cross-chain swaps or arbitrage routes, enhancing capital efficiency and utility. This borrowed liquidity is sourced directly from protocol-owned and user-supplied assets and routed through integrated AMMs such as PancakeSwap, Uniswap, and others.

* Multi-chain lending with single-asset supply
* Collateralized borrowing across all chains and solver-driven liquidity usage
* Flash loan-style interactions for execution use cases
* Revenue shared to suppliers

#### Stablecoin: bnUSD

bnUSD is a cross-chain stablecoin minted from approved collateral assets. It's used internally for routing and liquidity pairing and can also be integrated into partner ecosystems.

* Overcollateralized CDP model
* Fixed flat interest rate for minting
* Mintable and redeemable across all supported chains
* Integrated into swaps and lending flows

#### Intent-Based Execution Engine

The intent architecture allows users (or frontends) to specify what they want to do (e.g., "Swap Token A to Token B on Chain Y") and lets solvers fulfill the request using any available liquidity path.

* Intents created on the hub chain
* Solvers can fulfill from any spoke chain
* Enables optimized routing and partial fills
* Integrated with the cross-chain GMP layer

#### Wallet Abstraction

Sodax abstracts away chain-specific user wallets by creating deterministic proxy wallets for each user on the hub chain. This unlocks true chain-agnostic UX and simplifies cross-chain composability.

* Deterministic CREATE3 wallets per user and chain
* Executes payloads passed via GMP
* Supports permissioned hooks for asset manager or custom extensions
* Used as the default destination for bridging and execution

***

### Protocol-Owned Liquidity

Sodax currently holds over six million dollars in protocol-owned liquidity. This capital is deployed into the Sodax money market and is accessible to all partners who consume our core SDKs.

Partners integrating the Sodax SDKs can tap into this liquidity to facilitate trades, lending operations, or stablecoin minting across any supported chain. The solver borrows from this shared liquidity pool to execute intent-based trades, sourcing the best paths across integrated AMMs like PancakeSwap, Uniswap, Raydium, and more.

This ensures that partner applications not only get best-in-class cross-chain execution but also benefit from deeply integrated, high-availability liquidity that is owned and managed by the protocol.

***

### Partner Use Cases

| Partner Type            | Benefits from Sodax                                      |
| ----------------------- | -------------------------------------------------------- |
| Wallets                 | Integrate swap, lend, and bnUSD flows with a single SDK  |
| DEXs & Aggregators      | Access external liquidity across chains and route orders |
| Lending Platforms       | Utilize Sodax money market or integrate bnUSD minting    |
| Perp DEXs / Yield Apps  | Use cross-chain stablecoin and abstracted wallet flows   |
| Protocols on new chains | Add bridging, stablecoin support, and capital sourcing   |

Sodax is designed for composability. Each module can be used independently or in combination, depending on partner needs.

***

### Why Partners Choose Sodax

* Composability by Design: Every module (wallets, lending, swaps, rewards) is SDK-accessible and independently usable.
* Chain Abstraction: Works across EVM and non-EVM chains via intent-based messaging and deterministic wallets.
* Revenue Participation: Partners can earn through fees, point systems, or solver execution.
* Frictionless User Experience: No bridging, wrapping, or manual routing required.
* Stability & Yield: bnUSD minting and network-owned liquidity unlock predictable yields and system sustainability.

***

### SDK Overview

Sodax offers three SDKs, allowing partners to choose the level of integration that best fits their product needs:

#### Sodax Core SDK

The foundation of the Sodax ecosystem. This SDK provides:

* Access to cross-chain swap routing via the intent-based solver
* Full integration with the money market
* Interactions with bnUSD minting and redemption
* Coverage across all supported chains

#### Sodax Wallet SDK

An optional module providing wallet integration across all supported chains. This SDK enables:

* Pre-built wallet connection logic for EVM and non-EVM chains
* Support for native wallet flows on each chain
* Flexible use for teams that want a drop-in solution without building custom wallet logic

#### Sodax dAppKit

A high-level frontend utility package that combines the Core and Wallet SDKs. It provides:

* Pre-built hooks and components for money market functions (supply, borrow, repay)
* Swap interfaces using the solver
* Full end-to-end dApp scaffolding support for rapid integration

***

### Integration Highlights

* 12+ Chains Supported: ICON, Arbitrum, BNB, Avalanche, SUI, Solana, Stellar, and more
* Native SDKs: Core SDK, Sodax Wallet SDK, and dApp Kit (for frontend builders)
* AMMs Integrated: Uniswap V3, PancakeSwap, Raydium, Pharaoh, Cetus, DojoSwap, Soroswap
* GMP Compatible: Fully abstracted message-passing layer for secure cross-chain intents

***

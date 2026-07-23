---
description: >-
  What is live on Solana today, and the networks and assets your users can
  reach from it.
icon: circle-nodes
---

# Networks & Assets

Solana is a spoke network in the SODAX System. User funds stay on Solana; the hub (Sonic) coordinates execution, and solvers settle against deep native liquidity on each network rather than isolated bridge pools.

## Live on Solana today

Solver-compatible assets on Solana:

* **SOL**
* **USDC**
* **bnUSD**

Native DEX liquidity is routed through **Raydium V3**. The canonical, continuously updated list (including hub vault addresses) lives at [Swaps: Compatible Assets](../developers/deployments/swaps-compatible-assets.md#solana).

Both SODAX modules relevant to Solana builders are live for these assets: [Swaps](swaps.md) and the [Money Market](money-market.md).

## What your users can reach

From a Solana-sourced action, users can trade, lend, and borrow against assets across every SODAX-supported network:

* **EVM**: Sonic (hub), Ethereum, Arbitrum, Base, BSC, Optimism, Polygon, Avalanche, HyperEVM, Lightlink, Redbelly, Kaia
* **Non-EVM**: Solana, Sui, Stellar, ICON, Injective, NEAR, Stacks, Bitcoin

Chain identifiers come from `ChainKeys.*` in the SDK (`ChainKeys.SOLANA_MAINNET` = `'solana'`), and the live chain list from `sodax.config.getSupportedSpokeChains()`. Prefer the config call over hard-coding: networks are added over time.

## Asset discovery in code

```typescript
import { Sodax, ChainKeys } from '@sodax/sdk';

const sodax = new Sodax();
await sodax.initialize(); // pull the latest asset config

// Swappable assets on Solana
const swapTokens = sodax.swaps.getSupportedSwapTokensByChainId(ChainKeys.SOLANA_MAINNET);

// Money market assets on Solana
const mmTokens = sodax.moneyMarket.getSupportedTokensByChainId(ChainKeys.SOLANA_MAINNET);
```

***

* All deployment addresses by network: [Mainnet Deployments](../developers/deployments/mainnet.md)
* The full cross-network asset directory: [sodax.com/partners/asset-directory](https://sodax.com/partners/asset-directory)

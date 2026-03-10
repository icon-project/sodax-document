# SDK Docs Comparison: sodax-document vs sodax-frontend

Comparison of files in `sodax-document/developers/packages/sdk/docs/` (published GitBook) against `sodax-frontend/packages/sdk/docs/` (source of truth).

**Date**: 2026-03-10

**Direction**: `sodax-document` (left/old) vs `sodax-frontend` (right/new)

**Conclusion**: sodax-frontend is ahead in all 5 differing files. No files exist where sodax-document has content that sodax-frontend lacks.

---

## File Inventory

### Identical (no changes needed)

| File | Status |
| ---- | ------ |
| `ESTIMATE_GAS.md` | Identical |
| `MONETIZE_SDK.md` | Identical |
| `RELAYER_API_ENDPOINTS.md` | Identical |
| `SOLVER_API_ENDPOINTS.md` | Identical |
| `installation/nextjs.md` | Identical |

### Only in sodax-frontend (not present in sodax-document)

| File | Description |
| ---- | ----------- |
| `BACKEND_API.md` | Backend API documentation |
| `BRIDGE.md` | Bridge feature documentation |
| `INTENT_RELAY_API.md` | Intent Relay API documentation |
| `MIGRATION.md` | Token migration documentation |
| `MONEY_MARKET.md` | Money market feature documentation |
| `STAKING.md` | Staking feature documentation |
| `SWAPS.md` | Swaps feature documentation |

### Files with differences (5)

| File | sodax-frontend is ahead by |
| ---- | -------------------------- |
| `CONFIGURE_SDK.md` | New config sections (sharedConfig, inline examples) |
| `HOW_TO_CREATE_A_SPOKE_PROVIDER.md` | New `constructRawSpokeProvider` helper, 4 new chains |
| `HOW_TO_MAKE_A_SWAP.md` | Link fixes, formatting |
| `STELLAR_TRUSTLINE.md` | New `walletHasSufficientTrustline()` method |
| `WALLET_PROVIDERS.md` | 3 new EVM chains (Ethereum, Redbelly, Kaia) |

---

## Detailed Differences

### 1. CONFIGURE_SDK.md

#### Summary of changes

- **New content**: Added `customSolverConfig` instantiation example after the solver config definition
- **New content**: Added `customMoneyMarketConfig` instantiation example after the money market config definition
- **New section**: "Shared Configuration" — configures internal SDK services (e.g., Stellar RPC URLs via `sharedConfig`)
- **Refactored**: Hub Provider Configuration now shows inline `hubProviderConfig` inside `new Sodax()` constructor instead of a standalone `hubConfig` variable
- **Updated**: Complete Custom Configuration example now includes `sharedConfig` and uses `...` spread notation

#### Unified diff

```diff
--- sodax-document/developers/packages/sdk/docs/CONFIGURE_SDK.md
+++ sodax-frontend/packages/sdk/docs/CONFIGURE_SDK.md
@@ -94,6 +94,10 @@

 // Pre-defined default solver config
 const solverConfig = getSolverConfig(SONIC_MAINNET_CHAIN_ID);
+
+const sodax = new Sodax({
+  swap: customSolverConfig
+});
 ```

 ### Money Market Configuration
@@ -119,6 +123,10 @@

 // Pre-defined default money market config
 const moneyMarketConfig = getMoneyMarketConfig(SONIC_MAINNET_CHAIN_ID);
+
+const sodax = new Sodax({
+  moneyMarket: customMoneyMarketConfig
+});
 ```

 ### Hub Provider Configuration
@@ -127,18 +135,39 @@

 ```typescript
 import {
-  Sodax,
   EvmHubProviderConfig,
   getHubChainConfig,
   SONIC_MAINNET_CHAIN_ID,
 } from '@sodax/sdk';

-const hubConfig: EvmHubProviderConfig = {
-  hubRpcUrl: 'https://rpc.soniclabs.com',
-  chainConfig: getHubChainConfig(SONIC_MAINNET_CHAIN_ID),
-};
+const sodax = new Sodax({
+  hubProviderConfig: {
+    hubRpcUrl: 'https://rpc.soniclabs.com',
+    chainConfig: getHubChainConfig(SONIC_MAINNET_CHAIN_ID),
+  }
+});
 ```

+### Shared Configuration
+
+Configure SDK to use provided configuration when internally invoking things like reading from blockchain etc..
+
+```typescript
+import {
+  STELLAR_MAINNET_CHAIN_ID,
+} from '@sodax/sdk';
+
+const sodax = new Sodax({
+  sharedConfig: { // config used by internal services
+    [STELLAR_MAINNET_CHAIN_ID]: {
+      horizonRpcUrl: 'https://horizon.stellar.org',
+      sorobanRpcUrl: 'https://rpc.ankr.com/stellar_soroban',
+    }
+  }
+});
+
+```
+
 ### Complete Custom Configuration

 Combine all configurations:
@@ -155,10 +184,17 @@
 const sodax = new Sodax({
   swap: getSolverConfig(SONIC_MAINNET_CHAIN_ID),
   moneyMarket: getMoneyMarketConfig(SONIC_MAINNET_CHAIN_ID),
+  ...,
   hubProviderConfig: {
     hubRpcUrl: 'https://rpc.soniclabs.com',
     chainConfig: getHubChainConfig(SONIC_MAINNET_CHAIN_ID),
   },
+  sharedConfig: { // config used by internal services
+    [STELLAR_MAINNET_CHAIN_ID]: {
+      horizonRpcUrl: 'https://horizon.stellar.org',
+      sorobanRpcUrl: 'https://rpc.ankr.com/stellar_soroban',
+    }
+  }
 });
```

---

### 2. HOW_TO_CREATE_A_SPOKE_PROVIDER.md

#### Summary of changes

- **Title**: "Create a Spoke Provider" changed to "How to Create a Spoke Provider"
- **Formatting**: All bullet points changed from `*` to `-` throughout
- **Table formatting**: Simplified markdown table alignment
- **New section**: "Constructing a Raw Spoke Provider from Config" — documents `constructRawSpokeProvider()` helper function with signature, parameters, example code, and usage guidance
- **New chains**: Added Sonic, Ethereum, Redbelly, and Kaia to supported EVM chains list
- **Link fixes**: All internal references updated from deep GitBook paths (e.g., `../../foundation/sdk/functional-modules/swaps.md`) to local paths (e.g., `./SWAPS.md`)
- **Summary section**: Reorganized with `constructRawSpokeProvider(config)` mentioned as a helper; improved list formatting

#### Unified diff

```diff
--- sodax-document/developers/packages/sdk/docs/HOW_TO_CREATE_A_SPOKE_PROVIDER.md
+++ sodax-frontend/packages/sdk/docs/HOW_TO_CREATE_A_SPOKE_PROVIDER.md
@@ -1,4 +1,4 @@
-# Create a Spoke Provider
+# How to Create a Spoke Provider

@@ -6,8 +6,8 @@
-* A **wallet provider** implementation ...
-* A **chain configuration** object ...
+- A **wallet provider** implementation ...
+- A **chain configuration** object ...

@@ -16 +16 @@
-For more information, refer to the [README.md](../../foundation/sdk/#initialising-spoke-provider) section.
+For more information, refer to the [README.md](../README.md#initialising-spoke-provider) section.

@@ -22,24 +22,24 @@
-* **Do not require a wallet provider** ...
-* **Cannot sign transactions** ...
-* **Return raw transaction data** ...
+- **Do not require a wallet provider** ...
+- **Cannot sign transactions** ...
+- **Return raw transaction data** ...

-* **Backend services** ...
-* **Transaction preparation** ...
-* **Gas estimation** ...
-* **Multi-step flows** ...
+- **Backend services** ...
+- **Transaction preparation** ...
+- **Gas estimation** ...
+- **Multi-step flows** ...

 Table formatting simplified (column alignment removed)

+### Constructing a Raw Spoke Provider from Config
+
+When you have a generic config object (e.g. from API or runtime) and want a single
+entry point to build the correct raw spoke provider for any supported chain, use the
+**`constructRawSpokeProvider`** helper.
+
+**Signature**
+
+```typescript
+function constructRawSpokeProvider(config: RawSpokeProviderConfig): RawSpokeProvider
+```
+
+- **Parameter**: `config` — A chain-specific raw spoke provider config ...
+- **Returns**: A `RawSpokeProvider` instance ...
+- **Throws**: `Error` with message `Unsupported chain type: ${chainType}` ...
+
+**Example**
+
+```typescript
+import {
+  constructRawSpokeProvider,
+  spokeChainConfig,
+  ARBITRUM_MAINNET_CHAIN_ID,
+  type RawSpokeProviderConfig,
+  type EvmRawSpokeProviderConfig,
+} from "@sodax/sdk";
+
+const config: EvmRawSpokeProviderConfig = {
+  walletAddress: "0x...",
+  chainConfig: spokeChainConfig[ARBITRUM_MAINNET_CHAIN_ID],
+  rpcUrl: "https://arb1.arbitrum.io/rpc",
+};
+
+const rawSpokeProvider = constructRawSpokeProvider(config);
+```

@@ -50,53 +88,91 @@
-* A wallet provider ... [@wallet-sdk-core](../../connection/wallet-sdk-core.md) ...
+- A wallet provider ... [@wallet-sdk-core](../../wallet-sdk-core/README.md) ...

-EVM chains include Arbitrum, Avalanche, Base, BSC, Optimism, Polygon, Lightlink, and HyperEVM.
+EVM chains include Arbitrum, Avalanche, Base, BSC, Optimism, Polygon, Sonic, Lightlink, HyperEVM, Ethereum, Redbelly, and Kaia.

-* Arbitrum (`ARBITRUM_MAINNET_CHAIN_ID`)
-* Avalanche (`AVALANCHE_MAINNET_CHAIN_ID`)
-* Base (`BASE_MAINNET_CHAIN_ID`)
-* BSC (`BSC_MAINNET_CHAIN_ID`)
-* Optimism (`OPTIMISM_MAINNET_CHAIN_ID`)
-* Polygon (`POLYGON_MAINNET_CHAIN_ID`)
-* Lightlink (`LIGHTLINK_MAINNET_CHAIN_ID`)
-* HyperEVM (`HYPEREVM_MAINNET_CHAIN_ID`)
+- Arbitrum (`ARBITRUM_MAINNET_CHAIN_ID`)
+- Avalanche (`AVALANCHE_MAINNET_CHAIN_ID`)
+- Base (`BASE_MAINNET_CHAIN_ID`)
+- BSC (`BSC_MAINNET_CHAIN_ID`)
+- Optimism (`OPTIMISM_MAINNET_CHAIN_ID`)
+- Polygon (`POLYGON_MAINNET_CHAIN_ID`)
+- Sonic (`SONIC_MAINNET_CHAIN_ID`)
+- Lightlink (`LIGHTLINK_MAINNET_CHAIN_ID`)
+- HyperEVM (`HYPEREVM_MAINNET_CHAIN_ID`)
+- Ethereum (`ETHEREUM_MAINNET_CHAIN_ID`)
+- Redbelly (`REDBELLY_MAINNET_CHAIN_ID`)
+- Kaia (`KAIA_MAINNET_CHAIN_ID`)

 Link fixes throughout footer:
-* [SWAPS.md](../../foundation/sdk/functional-modules/swaps.md)
+- [SWAPS.md](./SWAPS.md)
-* [MONEY_MARKET.md](../../foundation/sdk/functional-modules/money_market.md)
+- [MONEY_MARKET.md](./MONEY_MARKET.md)
-* [BRIDGE.md](../../foundation/sdk/functional-modules/bridge.md)
+- [BRIDGE.md](./BRIDGE.md)
-* [STAKING.md](../../foundation/sdk/functional-modules/staking.md)
+- [STAKING.md](./STAKING.md)

 Summary section adds `constructRawSpokeProvider(config)` to raw spoke provider list.
```

---

### 3. HOW_TO_MAKE_A_SWAP.md

#### Summary of changes

- **Title**: "Make a Swap" changed to "How to Make a Swap"
- **Formatting**: All bullet points changed from `*` to `-` throughout
- **Link fixes**: All internal references updated from deep GitBook paths to local paths:
  - `../../foundation/sdk/functional-modules/swaps.md` to `./SWAPS.md`
  - `../../connection/wallet-sdk-core.md` to `../../wallet-sdk-core/README.md`
  - `../../connection/wallet-sdk-react.md` to `../../wallet-sdk-react/README.md`
  - `../../foundation/sdk/` to `../README.md`
  - `../../foundation/sdk/functional-modules/money_market.md` to `./MONEY_MARKET.md`
  - `../../foundation/sdk/functional-modules/bridge.md` to `./BRIDGE.md`
  - `../../foundation/sdk/functional-modules/staking.md` to `./STAKING.md`
- **Minor text**: Removed `// or 'exact_output'` comment from quote_type example

#### Unified diff

```diff
--- sodax-document/developers/packages/sdk/docs/HOW_TO_MAKE_A_SWAP.md
+++ sodax-frontend/packages/sdk/docs/HOW_TO_MAKE_A_SWAP.md
@@ -1,8 +1,8 @@
-# Make a Swap
+# How to Make a Swap

-For detailed API reference, see [SWAPS.md](../../foundation/sdk/functional-modules/swaps.md).
+For detailed API reference, see [SWAPS.md](./SWAPS.md).

@@ -10,11 +10,11 @@
-* A wallet provider ... [@wallet-sdk-core](../../connection/wallet-sdk-core.md) ...
-* The `@sodax/sdk` package installed
-* Sufficient token balance ...
-* RPC URLs ...
-* Private key ... [@wallet-sdk-react](../../connection/wallet-sdk-react.md) ...
+- A wallet provider ... [@wallet-sdk-core](../../wallet-sdk-core/README.md) ...
+- The `@sodax/sdk` package installed
+- Sufficient token balance ...
+- RPC URLs ...
+- Private key ... [@wallet-sdk-react](../../wallet-sdk-react/README.md) ...

@@ -34,8 +34,8 @@
-* The `new Sodax()` constructor defaults to mainnet ...
-* If you skip `initialize()` ...
+- The `new Sodax()` constructor defaults to mainnet ...
+- If you skip `initialize()` ...

@@ -91,7 +91,7 @@
-... refer to the [README.md](../../foundation/sdk/#initialising-spoke-provider) ...
+... refer to the [README.md](../README.md#initialising-spoke-provider) ...

@@ -143,7 +143,7 @@
-  quote_type: 'exact_input', // or 'exact_output'
+  quote_type: 'exact_input',

@@ -239,10 +239,10 @@
-* Use the quoted amount ...
-* Set appropriate `deadline` ...
-* Ensure `srcAddress` ...
-* Set `dstAddress` ...
+- Use the quoted amount ...
+- Set appropriate `deadline` ...
+- Ensure `srcAddress` ...
+- Set `dstAddress` ...

@@ -427,20 +427,20 @@
 (All bullet points * to - for Status Codes and Polling Behavior)

@@ -800,8 +800,8 @@
-* Learn more ... [SWAPS.md](../../foundation/sdk/functional-modules/swaps.md)
-* Learn how to create ... [HOW\_TO\_CREATE\_A\_SPOKE\_PROVIDER.md](HOW_TO_CREATE_A_SPOKE_PROVIDER.md)
-* Explore ... [Money Market](../../foundation/sdk/functional-modules/money_market.md), [Bridge](../../foundation/sdk/functional-modules/bridge.md), and [Staking](../../foundation/sdk/functional-modules/staking.md)
-* Check the [README.md](../../foundation/sdk/) ...
+- Learn more ... [SWAPS.md](./SWAPS.md)
+- Learn how to create ... [HOW_TO_CREATE_A_SPOKE_PROVIDER.md](./HOW_TO_CREATE_A_SPOKE_PROVIDER.md)
+- Explore ... [Money Market](./MONEY_MARKET.md), [Bridge](./BRIDGE.md), and [Staking](./STAKING.md)
+- Check the [README.md](../README.md) ...
```

---

### 4. STELLAR_TRUSTLINE.md

#### Summary of changes

- **Title**: "Handle Stellar Trustline" changed to "Stellar Trustline Requirements"
- **Formatting**: All bullet points changed from `*` to `-` throughout
- **Updated text**: "The SDK provides two methods" changed to "The SDK provides three methods"
- **New method**: `walletHasSufficientTrustline()` — a static method on `StellarSpokeService` that checks trustlines without requiring a `StellarSpokeProvider` instance. Takes `tokenAddress`, `amount`, `walletAddress`, and `horizonRpcUrl` parameters.
- **Best practices formatting**: Added blank lines between numbered items for readability
- **Link fixes**: All footer references updated from deep GitBook paths to local paths

#### Unified diff

```diff
--- sodax-document/developers/packages/sdk/docs/STELLAR_TRUSTLINE.md
+++ sodax-frontend/packages/sdk/docs/STELLAR_TRUSTLINE.md
@@ -1,4 +1,4 @@
-# Handle Stellar Trustline
+# Stellar Trustline Requirements

@@ -6,10 +6,10 @@
-* **Receive tokens**: ...
-* **Hold tokens**: ...
+- **Receive tokens**: ...
+- **Hold tokens**: ...

-* **Source Chain (Stellar)**: ...
-* **Destination Chain (Stellar)**: ...
+- **Source Chain (Stellar)**: ...
+- **Destination Chain (Stellar)**: ...

@@ -19 +19 @@
-The SDK provides two methods for managing Stellar trustlines:
+The SDK provides three methods for managing Stellar trustlines:

@@ -34,6 +34,23 @@
+### walletHasSufficientTrustline
+
+Checks if a specific Stellar wallet has a sufficient trustline for a given
+token and amount without requiring a `StellarSpokeProvider`.
+
+```typescript
+import { StellarSpokeService } from "@sodax/sdk";
+
+const hasTrustline = await StellarSpokeService.walletHasSufficientTrustline(
+  tokenAddress,    // The Stellar token address
+  amount,          // The amount you need to receive
+  walletAddress,   // The Stellar wallet address to check
+  horizonRpcUrl    // Horizon RPC URL to query account balances
+);
+```
+
+**Returns:** `Promise<boolean>` - `true` if trustline exists and has sufficient limit, `false` otherwise
+
 (All bullet points * to - throughout usage sections for Swaps, Money Market, Bridge, Migration, Staking)

@@ -226,9 +243,13 @@
 1. **Always check trustlines before operations**: ...
+
 2. **Set appropriate trustline limits**: ...
+
 3. **Wait for confirmation**: ...
+
 4. **Handle errors gracefully**: ...
+
 5. **Reuse trustlines**: ...

@@ -277,8 +298,8 @@
-* [Swaps](../../foundation/sdk/functional-modules/swaps.md) ...
-* [Money Market](../../foundation/sdk/functional-modules/money_market.md) ...
-* [Bridge](../../foundation/sdk/functional-modules/bridge.md) ...
-* [Migration](../../foundation/sdk/functional-modules/migration.md) ...
-* [Staking](../../foundation/sdk/functional-modules/staking.md) ...
+- [Swaps](./SWAPS.md) ...
+- [Money Market](./MONEY_MARKET.md) ...
+- [Bridge](./BRIDGE.md) ...
+- [Migration](./MIGRATION.md) ...
+- [Staking](./STAKING.md) ...
```

---

### 5. WALLET_PROVIDERS.md

#### Summary of changes

- **Title**: "Setup Wallet Providers" changed to "Wallet Providers"
- **Formatting**: All bullet points changed from `*` to `-` throughout
- **New chains**: Added Ethereum, Redbelly, and Kaia to the `IEvmWalletProvider` supported chains list
- **Link fix**: `../../connection/wallet-sdk-core.md` changed to `../../wallet-sdk-core/README.md`

#### Unified diff

```diff
--- sodax-document/developers/packages/sdk/docs/WALLET_PROVIDERS.md
+++ sodax-frontend/packages/sdk/docs/WALLET_PROVIDERS.md
@@ -1,4 +1,4 @@
-# Setup Wallet Providers
+# Wallet Providers

@@ -8,12 +8,12 @@
-* `IEvmWalletProvider`: EVM (Arbitrum, Avalanche, Base, BSC, Optimism, Polygon, Sonic, HyperEVM, Lightlink) ✅
-* `ISuiWalletProvider`: Sui ✅
-* `IIconWalletProvider`: ICON ✅
-* `IStellarWalletProvider`: Stellar ✅
-* `ISolanaWalletProvider`: Solana ✅
-* `IInjectiveWalletProvider`: Injective ✅
+- `IEvmWalletProvider`: EVM (Arbitrum, Avalanche, Base, BSC, Optimism, Polygon, Sonic, HyperEVM, Lightlink, Ethereum, Redbelly, Kaia) ✅
+- `ISuiWalletProvider`: Sui ✅
+- `IIconWalletProvider`: ICON ✅
+- `IStellarWalletProvider`: Stellar ✅
+- `ISolanaWalletProvider`: Solana ✅
+- `IInjectiveWalletProvider`: Injective ✅

@@ -32,9 +32,9 @@
-* **Multi-chain Support**: ...
-* **TypeScript Compatibility**: ...
-* **Wallet Provider Interface**: ...
-* **Core Integration**: ...
+- **Multi-chain Support**: ...
+- **TypeScript Compatibility**: ...
+- **Wallet Provider Interface**: ...
+- **Core Integration**: ...

-For more information, see the [@sodax/wallet-sdk-core README](../../connection/wallet-sdk-core.md).
+For more information, see the [@sodax/wallet-sdk-core README](../../wallet-sdk-core/README.md).
```

---

## Change Categories Summary

| Category | Files affected |
| -------- | -------------- |
| **New API methods/sections** | CONFIGURE_SDK.md (sharedConfig), HOW_TO_CREATE_A_SPOKE_PROVIDER.md (constructRawSpokeProvider), STELLAR_TRUSTLINE.md (walletHasSufficientTrustline) |
| **New chain support** | HOW_TO_CREATE_A_SPOKE_PROVIDER.md, WALLET_PROVIDERS.md (Ethereum, Redbelly, Kaia, Sonic) |
| **Link path fixes** | HOW_TO_CREATE_A_SPOKE_PROVIDER.md, HOW_TO_MAKE_A_SWAP.md, STELLAR_TRUSTLINE.md, WALLET_PROVIDERS.md |
| **Title changes** | All 5 files |
| **Formatting (bullet `*` to `-`)** | All 5 files |
| **Code example improvements** | CONFIGURE_SDK.md (inline Sodax constructor patterns) |

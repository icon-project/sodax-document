---
title: SODAX Docs
description: A liquidity and cross-network execution solution. Scope the integration from your own repo before you commit.
---

# Liquidity and execution, across every network

<Note>
**See what integration takes before you commit.** Run the SODAX Builders MCP locally against your own codebase. Your AI assistant reads your repo and maps exactly what a SODAX integration looks like and how light the work is. One integration reaches all networks. No call required. [Try the Builders MCP](https://builders.sodax.com/)
</Note>

***

<Tabs>
  <Tab title="Swap">
    <h3 class="text-lg font-bold mb-2">Cross-network swaps, filled by solvers</h3>

    <p class="text-gray-500 mt-2 mb-5">
      Quote and execute an intent across networks. Solvers on the SODAX marketplace fill it — you don't manage liquidity or routing.
    </p>

    <CardGroup cols={2}>
      <Card title="Lightweight API" icon="key" href="/developers/packages/foundation/swaps-api" horizontal arrow>
        Hosted HTTP client — no SDK install, wire straight into your backend.
      </Card>
      <Card title="Open-source SDK" icon="code" href="/developers/packages/foundation/sdk" horizontal arrow>
        Install `@sodax/sdk` and integrate directly into your codebase.
      </Card>
    </CardGroup>

    <CardGroup cols={2}>
      <Card title="Make a swap" icon="repeat" href="/developers/packages/sdk/docs/HOW_TO_MAKE_A_SWAP" horizontal arrow>
        Full walkthrough: init, quote, execute, error handling.
      </Card>
      <Card title="Swaps module reference" icon="book-open" href="/developers/packages/foundation/sdk/functional-modules/swaps" horizontal arrow>
        Every method on `sodax.swaps`.
      </Card>
    </CardGroup>

    <CodeGroup>
      ```typescript swap.ts
      import { Sodax, ChainKeys } from '@sodax/sdk';

      const sodax = new Sodax();

      const result = await sodax.swaps.swap({
        params: {
          inputToken: '0x2170...f9338',
          outputToken: '0x2f2a...fC5B0f',
          inputAmount: 1_000_000_000_000_000n,
          minOutputAmount: 900_000n,
          deadline: 300n,
          srcChainKey: ChainKeys.BSC_MAINNET,
          dstChainKey: ChainKeys.ARBITRUM_MAINNET,
          srcAddress: await evmWalletProvider.getWalletAddress(),
          dstAddress: '0x...',
        },
        walletProvider: evmWalletProvider,
      });

      if (result.ok) console.log('Swap submitted', result.value);
      ```
    </CodeGroup>
  </Tab>

  <Tab title="Lend & Borrow">
    <h3 class="text-lg font-bold mb-2">One money market, every network</h3>

    <p class="text-gray-500 mt-2 mb-5">
      Supply collateral from any spoke network, borrow against it — the money market itself lives on the Sonic hub.
    </p>

    <CardGroup cols={2}>
      <Card title="Lightweight API" icon="key" href="/contact-form" horizontal arrow>
        No dedicated hosted API yet — reach out and we'll notify you when keys are available.
      </Card>
      <Card title="Open-source SDK" icon="code" href="/developers/packages/foundation/sdk" horizontal arrow>
        Install `@sodax/sdk` and integrate directly into your codebase.
      </Card>
    </CardGroup>

    <Card title="Money Market module reference" icon="sack-dollar" href="/developers/packages/foundation/sdk/functional-modules/money_market" horizontal arrow>
      Supply, borrow, withdraw, repay, and reserve data.
    </Card>

    <CodeGroup>
      ```typescript supply.ts
      import { Sodax, ChainKeys } from '@sodax/sdk';

      const sodax = new Sodax();

      const result = await sodax.moneyMarket.supply({
        params: {
          srcChainKey: ChainKeys.BSC_MAINNET,
          srcAddress: '0x...',
          token: '0x...',
          amount: 1000n,
          action: 'supply',
        },
        walletProvider: evmWalletProvider,
      });

      if (result.ok) console.log('Supplied', result.value);
      ```
    </CodeGroup>
  </Tab>

  <Tab title="Bridge">
    <h3 class="text-lg font-bold mb-2">Move assets, network to network</h3>

    <p class="text-gray-500 mt-2 mb-5">
      Low-level transfer primitives through the hub-and-spoke vault system — for when you need asset movement without the swap logic.
    </p>

    <CardGroup cols={2}>
      <Card title="Lightweight API" icon="key" href="/contact-form" horizontal arrow>
        No dedicated hosted API yet — reach out and we'll notify you when keys are available.
      </Card>
      <Card title="Open-source SDK" icon="code" href="/developers/packages/foundation/sdk" horizontal arrow>
        Install `@sodax/sdk` and integrate directly into your codebase.
      </Card>
    </CardGroup>

    <Card title="Bridge module reference" icon="bridge-suspension" href="/developers/packages/foundation/sdk/functional-modules/bridge" horizontal arrow>
      Spoke → hub, hub → spoke, and spoke → spoke transfers.
    </Card>

    <CodeGroup>
      ```typescript bridge.ts
      import { Sodax, ChainKeys } from '@sodax/sdk';

      const sodax = new Sodax();

      const result = await sodax.bridge.bridge({
        params: {
          srcChainKey: ChainKeys.BASE_MAINNET,
          srcAddress: '0xYourAddress...',
          srcToken: '0x1234...cdef',
          amount: 1_000_000_000_000_000_000n,
          dstChainKey: ChainKeys.POLYGON_MAINNET,
          dstToken: '0xabcd...567890',
          recipient: '0x9876...dcba',
        },
        walletProvider: evmWalletProvider,
      });

      if (result.ok) console.log('Bridged', result.value);
      ```
    </CodeGroup>
  </Tab>

  <Tab title="Yield Integration">
    <h3 class="text-lg font-bold mb-2">Leveraged yield vaults, one swap away</h3>

    <p class="text-gray-500 mt-2 mb-5">
      Enter and exit leverage-yield vault positions as ordinary intent-based swaps — no vault-specific approvals or bespoke deposit calls.
    </p>

    <CardGroup cols={2}>
      <Card title="Lightweight API" icon="key" href="/contact-form" horizontal arrow>
        No dedicated hosted API yet — reach out and we'll notify you when keys are available.
      </Card>
      <Card title="Open-source SDK" icon="code" href="/developers/packages/foundation/sdk" horizontal arrow>
        Install `@sodax/sdk` and integrate directly into your codebase.
      </Card>
    </CardGroup>

    <Card title="Leverage Yield module reference" icon="money-bill-trend-up" href="/developers/packages/foundation/sdk/functional-modules/leverage_yield" horizontal arrow>
      Deposit, withdraw, APR, and position/health-factor data.
    </Card>

    <CodeGroup>
      ```typescript deposit.ts
      import { ChainKeys } from '@sodax/sdk';

      const vault = sodax.leverageYield.getVault('lsodaWEETH');

      const intentResult = await sodax.leverageYield.deposit({
        vault: vault.vault,
        srcChainKey: ChainKeys.ARBITRUM_MAINNET,
        srcAddress: '0xYourArbitrumEOA...',
        inputToken: '0x...weETHonArbitrum',
        inputAmount: 1_000_000_000_000_000_000n,
        minOutputAmount: 900_000_000_000_000_000n,
      });

      if (intentResult.ok) {
        const swapResult = await sodax.leverageYield.vaultSwap({
          ...intentResult.value,
          walletProvider: evmWalletProvider,
        });
      }
      ```
    </CodeGroup>
  </Tab>
</Tabs>

***

<Note>
**Building a frontend?** [`@sodax/dapp-kit`](/developers/packages/experience/dapp-kit) wraps swap, bridge, money market, staking, and migration in React hooks — wallet connection and SDK wiring included.
</Note>

***

<CardGroup cols={2}>
  <Card title="Bitcoin Integration" icon="bitcoin" href="/developers/how-to/bitcoin-integration">
    Integrate Bitcoin as a source or destination network.
  </Card>
  <Card title="Solana quickstart" icon="rocket" href="/solana/quickstart">
    Solana-specific setup, wallets, and swaps.
  </Card>
</CardGroup>

***

### What SODAX gives you

SODAX is a liquidity and cross-network execution solution. Integrate through the open-source SDK or the lightweight hosted API, and your app can exchange, lend, borrow, and settle across blockchain networks as if there were no boundaries.

Most cross-network systems move assets. SODAX coordinates execution: it provides the routing, settlement, and recovery rails so an action started on one network completes predictably on another, even when conditions change mid-flight.

Pick the integration path that fits: the SDK for full control inside your own codebase, or the API for a lighter integration. Either way you keep full control of your user experience, pricing logic, and risk parameters. SODAX handles how execution behaves when networks are slow, fragmented, or partially available.

Three things you get out of one integration:

* **One surface, every network.** Build once — via SDK or API — and reach all 18 connected networks.
* **Execution that settles, not just routes.** Swaps, borrows, and deposits complete across networks under real conditions, with explicit handling for delays and partial completion.
* **Your app stays yours.** You own the UX, the pricing, and the risk parameters. SODAX is infrastructure underneath, not a front end on top.

***

### Go deeper

<CardGroup cols={3}>
  <Card title="The SDK stack" icon="layer-group" href="/home/sdk-stack">
    Foundation, Connection, and Experience — pick the layer that matches how much control you want.
  </Card>
  <Card title="How execution works" icon="gears" href="/home/how-execution-works">
    Intent-based execution, unified liquidity, and smart wallet abstraction.
  </Card>
  <Card title="Why build with SODAX" icon="chart-line" href="/home/why-sodax">
    Proof points, what partners build, and ecosystem reach.
  </Card>
</CardGroup>

***

### Next

* Install [@sodax/sdk](/developers/packages/foundation/sdk) and ship your first cross-network action.
* Or scope it first: run the [Builders MCP](https://builders.sodax.com/) against your repo.

---
title: SODAX Docs
description: One SDK. Every network. Scope the integration from your own repo before you commit.
---

# SODAX for all networks

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

  <Tab title="React dApp">
    <h3 class="text-lg font-bold mb-2">Ship a frontend fast with dapp-kit</h3>

    <p class="text-gray-500 mt-2 mb-5">
      `@sodax/dapp-kit` wraps swap, bridge, money market, staking, and migration in React hooks — wallet connection and SDK wiring included.
    </p>

    <Card title="@sodax/dapp-kit" icon="browser" href="/developers/packages/experience/dapp-kit" horizontal arrow>
      Full hook reference and provider setup.
    </Card>

    <CodeGroup>
      ```tsx SwapButton.tsx
      import { useSwap, useWalletProvider } from '@sodax/dapp-kit';
      import { ChainKeys } from '@sodax/sdk';

      function SwapButton({ intentParams }) {
        const walletProvider = useWalletProvider(ChainKeys.BSC_MAINNET);
        const { mutateAsyncSafe: swap, isPending } = useSwap();

        const handleSwap = async () => {
          if (!walletProvider) return;
          const result = await swap({ params: intentParams, walletProvider });
          if (!result.ok) return alert('Swap failed');
          console.log('Swap submitted!', result.value);
        };

        return (
          <button onClick={handleSwap} disabled={isPending}>
            {isPending ? 'Swapping...' : 'Swap'}
          </button>
        );
      }
      ```
    </CodeGroup>
  </Tab>
</Tabs>

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

SODAX is execution infrastructure for modern money. You integrate one SDK, and your app can exchange, lend, borrow, and settle across blockchain networks as if there were no boundaries.

Most cross-network systems move assets. SODAX coordinates execution: it provides the routing, settlement, and recovery rails so an action started on one network completes predictably on another, even when conditions change mid-flight.

You integrate through a single SDK surface and keep full control of your user experience, pricing logic, and risk parameters. SODAX handles how execution behaves when networks are slow, fragmented, or partially available.

Three things you get out of one integration:

* **One surface, every network.** Build once against @sodax/sdk and reach all 18 connected networks.
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

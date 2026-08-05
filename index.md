---
title: SODAX Docs
description: One SDK. Every network. Scope the integration from your own repo before you commit.
---

# SODAX for all networks

<Note>
**See what integration takes before you commit.** Run the SODAX Builders MCP locally against your own codebase. Your AI assistant reads your repo and maps exactly what a SODAX integration looks like and how light the work is. One integration reaches all networks. No call required. [Try the Builders MCP](https://builders.sodax.com/)
</Note>

***

<CardGroup cols={2}>
  <Card title="Make a swap" icon="repeat" href="/developers/packages/sdk/docs/HOW_TO_MAKE_A_SWAP">
    Integrate swaps to xStocks across 19 networks.
  </Card>
  <Card title="Bitcoin Integration" icon="bitcoin" href="/developers/how-to/bitcoin-integration">
    Integrate Bitcoin as a source or destination network.
  </Card>
</CardGroup>

***

### What SODAX gives you

SODAX is execution infrastructure for modern money. You integrate one SDK, and your app can exchange, lend, borrow, and settle across blockchain networks as if there were no boundaries.

Most cross-network systems move assets. SODAX coordinates execution: it plans liquidity, timing, and recovery so an action started on one network completes predictably on another, even when conditions change mid-flight.

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
* New to Solana? Start with the [Solana quickstart](/solana/quickstart).

---
description: >-
  Reach the users and liquidity of every SODAX network from your Solana
  product, without writing or deploying any smart contracts.
icon: code
cover: .gitbook/assets/hero-aurora.jpg
coverY: 0
---

# SODAX for Solana

{% hint style="success" %}
**No smart contracts to write or deploy.** SODAX's contracts on Solana are already live and [independently audited](https://github.com/icon-project/sodax-sdks/blob/main/Audits/Sodax%20%28Solana%29%20Smart%20Contract%20Audit%20Report%20-%20Final%20Report%20v2%20%281%29.pdf); your entire integration is TypeScript. Your users sign familiar Solana transactions, and SODAX coordinates cross-network execution, routing, and recovery behind the scenes.
{% endhint %}

You keep shipping on Solana. SODAX absorbs the cross-network execution layer, so your product can offer trading and lending against every asset in the SODAX System, 137 across all supported networks as of July 2026, without leaving your stack. Integration happens in TypeScript, at the SDK or React layer. There is nothing to deploy, audit, or maintain on-chain.

Using SODAX is free. Trades carry a fixed 0.1% base fee taken by the protocol, and you set your own platform fee on top. That part is fully yours, both the rate and the revenue. See [Monetize SDK](https://docs.sodax.com/developers/how-to/monetize_sdk).

Not sure where SODAX fits in your product? Paste your protocol's URL into the generator and get a guide written for your stack:

<a href="https://sodax.com/solana" class="button primary">Generate your integration guide</a>

## What you can build

Two SODAX modules are relevant to Solana builders:

<table data-view="cards"><thead><tr><th></th><th></th><th data-hidden data-card-target data-type="content-ref"></th></tr></thead><tbody><tr><td><strong>Swaps</strong></td><td>Intent-based cross-network swaps. Users trade between SPL assets and assets on any supported network with one signed transaction on Solana. Solvers compete to fill; unified pricing across networks.</td><td><a href="swaps.md">swaps.md</a></td></tr><tr><td><strong>Money Market</strong></td><td>Cross-network lending and borrowing. Depositors source collateral from any supported network and settle into positions that back Solana-native flows: supply, borrow, repay, withdraw.</td><td><a href="money-market.md">money-market.md</a></td></tr></tbody></table>

## Choose your integration path

| Path | Best for | Start here |
| --- | --- | --- |
| [`@sodax/sdk`](https://docs.sodax.com/developers/packages/foundation/sdk) | Full control from any TypeScript backend or frontend | [Quickstart](quickstart.md) |
| [`@sodax/dapp-kit`](https://docs.sodax.com/developers/packages/experience/dapp-kit) + [`@sodax/wallet-sdk-react`](https://docs.sodax.com/developers/packages/connection/wallet-sdk-react) | React apps that want hooks and wallet connectivity out of the box | [Wallets](wallets.md) |
| [Builders MCP](https://builders.sodax.com) | Building with AI agents against the full SODAX stack | See below |

## Scope and build with AI

Point your AI coding assistant at the [SODAX Builders MCP](https://builders.sodax.com/) and it gains live access to the whole SODAX System: supported chains and tokens, real swap quotes, money market rates, intent history, and these docs. 40 tools in all, working in Claude, Cursor, VS Code, Windsurf, and any other MCP-capable client.

```json
{
  "mcpServers": {
    "sodax-builders": {
      "url": "https://builders.sodax.com/mcp"
    }
  }
}
```

Use it to scope before you commit: your assistant can read your own codebase, pull real quotes and token lists, and map exactly where SODAX fits in your product. Then let it build against the same live data. Full tool list and per-client setup at [builders.sodax.com](https://builders.sodax.com/).

## In this section

* [Quickstart](quickstart.md): install the SDK, connect a Solana wallet, make your first cross-network swap.
* [Swaps on Solana](swaps.md): how intents work from a Solana perspective, quoting, fees, and settlement.
* [Money Market on Solana](money-market.md): supply, borrow, repay, and withdraw with cross-network collateral.
* [Wallets](wallets.md): Phantom, Backpack, Solflare, and every other network's wallets through one interface.
* [Networks & Assets](networks-and-assets.md): what is live on Solana today and what your users can reach.
* [Solana FAQ](faq.md): the questions Solana engineers actually ask.

## Out in the ecosystem

You will run into us where Solana builders already are: Breakpoint, Superteam events, hackathon season.

<table data-header-hidden><thead><tr><th></th><th></th><th></th></tr></thead><tbody><tr><td><img src=".gitbook/assets/superteam-workshop.jpg" alt="SODAX at a Superteam workshop"></td><td><img src=".gitbook/assets/solana-breakpoint.jpg" alt="SODAX at Solana Breakpoint"></td><td><img src=".gitbook/assets/solana-booth.jpg" alt="SODAX booth at a Solana event"></td></tr></tbody></table>

If you are getting oriented in Solana development more broadly, these are the resources we point builders to:

* [**Superteam**](https://superteam.fun/): the global collective of Solana builders: bounties, grants, local chapters, and the fastest way to find collaborators and your first users.
* [**Colosseum**](https://colosseum.com/hackathon): Solana's flagship online hackathon and accelerator. A cross-network swap or lending feature built on SODAX makes a strong hackathon wedge; ship it in a weekend, entirely in TypeScript.
* [**Solana developer docs**](https://solana.com/developers): the canonical starting point for the runtime, SPL tokens, and tooling.
* [**Anchor**](https://www.anchor-lang.com/): the standard framework for writing Solana smart contracts; a SODAX integration lives alongside it in your TypeScript client, not inside it.
* [**Solana Stack Exchange**](https://solana.stackexchange.com/): where the sharp edges get answered.

***

Building something? Generate a guide at [sodax.com/solana](https://sodax.com/solana), or start with the [Quickstart](quickstart.md).

---
title: SODAX Docs
description: One SDK. Every network. Scope the integration from your own repo before you commit.
---

# SODAX for all networks

<Note>
**See what integration takes before you commit.** Run the SODAX Builders MCP locally against your own codebase. Your AI assistant reads your repo and maps exactly what a SODAX integration looks like and how light the work is. One integration reaches all networks. [Try the Builders MCP](https://builders.sodax.com/)
</Note>

## What SODAX gives you

SODAX is execution infrastructure for modern money. You integrate one SDK, and your app can exchange, lend, borrow, and settle across blockchain networks as if there were no boundaries.

Most cross-network systems move assets. SODAX coordinates execution: it plans liquidity, timing, and recovery so an action started on one network completes predictably on another, even when conditions change mid-flight.

You integrate through a single SDK surface and keep full control of your user experience, pricing logic, and risk parameters. SODAX handles how execution behaves when networks are slow, fragmented, or partially available.

### The SDK stack

The SODAX developer suite is a dependency stack. Integrate at the foundation for maximum control, or use the higher layers for speed.

- **Foundation: @sodax/sdk** — Core logic layer that powers everything else. Raw functional modules to build with SODAX programmatically.
- **Connection: @sodax/wallet-sdk-core & @sodax/wallet-sdk-react** — Multi-chain wallet management for seamless user experience.
- **Experience: @sodax/dapp-kit** — Pre-built React hooks and components that wrap layers 1 and 2 for rapid integration.

Ready to get started? Check out the [Solana integration guide](/get-started/solana/quickstart) or [explore the SDK docs](/developers/packages/foundation/sdk).

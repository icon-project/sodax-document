---
title: How Execution Works
description: Intent-based execution, unified liquidity, and smart wallet abstraction — how SODAX coordinates cross-network actions end to end.
icon: gears
---

# How execution works

Cross-network execution is asynchronous by nature, depends on liquidity fragmented across networks, and is exposed to volatility and partial completion. Asset transfers can succeed while the action they were meant to enable fails: collateral arrives but the borrow does not fill, a quoted price cannot be filled when execution begins.

SODAX is built to coordinate execution across those realities, end to end, so DeFi actions complete predictably. Three components make that possible.

### Intent-based execution

You express an intent, a desired outcome. SODAX routes and settles it; independent solvers fill it. Users do not hand-route transactions.

* **Solver execution.** Solvers on the SODAX marketplace plan fills across networks based on liquidity, pricing, network constraints, and your builder-defined parameters. They decide how to fill; SODAX provides the routing and settlement rails they execute on.
* **Outcome-oriented settlement.** Routes are quoted from coordinated liquidity or external venues based on current conditions, then executed explicitly once approved.
* **Explicit asynchronous handling.** Multi-step execution, partial completion, and recovery paths are handled deliberately, so flows that cannot complete atomically still complete reliably.

### Unified liquidity

SODAX treats liquidity as one system-level inventory, not isolated pools per network.

* **Global execution inventory.** Assets are accounted for across networks and coordinated to fulfill cross-network intents.
* **Solver-accessed at execution time.** Solvers draw on this liquidity when planning and executing fills, then redistribute it to keep the system balanced.
* **Less fragmentation risk.** Execution no longer depends on the right liquidity sitting on a specific network at a specific moment.

### Smart wallet abstraction

SODAX coordinates cross-network account state as part of the execution layer, rather than relying on separate wallets per network.

* **Deterministic execution wallets.** Users get deterministic smart wallets that act as one consistent execution identity across networks.
* **Unified execution account.** Apps execute cross-network actions through a single wallet context, not separate accounts and approvals per network.
* **Simplified coordination.** SODAX handles wallet creation and execution routing, so you focus on what happens after execution.

<CardGroup cols={2}>
  <Card title="Intents architecture" icon="bullseye" href="/developers/technical-overview/intents">
    The contracts behind intent-based execution.
  </Card>
  <Card title="Hub Wallet Abstraction" icon="wallet" href="/developers/technical-overview/hub-wallet-abstraction">
    How deterministic hub wallets work under the hood.
  </Card>
</CardGroup>

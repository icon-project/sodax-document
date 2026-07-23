---
description: The questions Solana engineers actually ask about integrating SODAX.
icon: comment-question
---

# Solana FAQ

#### Do I need to deploy new programs?

No new programs. SODAX's Solana programs are already deployed and audited; your integration is TypeScript against `@sodax/sdk` (or the React packages on top of it). You do not write Anchor code, manage PDAs, or take on program upgrade authority for any part of the flow.

#### How does a swap from Solana actually settle?

Your user signs one Solana transaction that creates an intent. The SODAX relayer carries proof of that transaction to the hub network (Sonic), a solver fills the intent on the destination network, and the output lands at the recipient address there. Swaps into Solana settle as SPL balances at the user's address. If an intent is never filled, it can be cancelled and the funds recovered.

#### Which assets are supported on Solana?

SOL, USDC, and bnUSD today, routed against Raydium V3 liquidity. The list grows; read it from `sodax.config` at runtime or check [Networks & Assets](networks-and-assets.md).

#### Do my users need a new wallet?

No. Phantom, Backpack, Solflare, and other wallet-standard wallets work through `@sodax/wallet-sdk-react` (which wraps `@solana/wallet-adapter`) or directly via `SolanaWalletProvider`. See [Wallets](wallets.md).

#### Is there an approve step before swapping or supplying?

No. Token allowances are an EVM and Stellar concept. On Solana the SDK's `isAllowanceValid` check passes without an on-chain transaction, so the quote-to-action path is a single signature.

#### Can I tune commitment levels and send options?

Yes. `SolanaWalletProvider` accepts `SolanaWalletDefaults`: `connectionCommitment`, `connectionConfig`, `sendOptions`, and `confirmCommitment`. Bring your own RPC endpoint (Helius, Triton, or your own node) via the `endpoint` field.

#### What does it cost?

Using SODAX is free: no license, no integration fee, no SDK cost. Trades carry a fixed 0.1% base fee taken by the protocol; on top of that you set your own platform fee and keep it. Your integration is a revenue line, not a cost center. See [Monetize SDK](../developers/packages/sdk/docs/MONETIZE_SDK.md).

#### How do I know if something went wrong?

Every SDK method returns `Result<T>` rather than throwing. Core swap and money market methods return typed error codes (for example `'RELAY_TIMEOUT'`, `'EXECUTION_FAILED'`) you can branch on, with structured context attached.

#### Where are the audits?

The Solana programs have their own published report: [SODAX (Solana) Smart Contract Audit (Final Report v2)](<../developers/audits/Sodax (Solana) Smart Contract Audit Report - Final Report v2 (1).pdf>). Audits for the rest of the protocol are collected on the [Audits](../developers/audits/Readme.md) page.

#### I want a plan specific to my protocol. Who do I talk to?

Generate a tailored integration guide at [sodax.com/solana](https://sodax.com/solana): paste your protocol's URL and it maps SODAX onto your stack. From there you can reach the BD team directly.

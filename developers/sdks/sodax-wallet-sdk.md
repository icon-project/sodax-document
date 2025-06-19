---
description: >-
  A comprehensive wallet SDK for the Sodax ecosystem that provides unified
  wallet connectivity across multiple blockchain networks.
---

# @sodax/wallet-sdk

### Features

* Seamless wallet connectivity for all supported wallets in the Sodax network
  * EVM Wallets: All browser extensions that support [EIP-6963](https://eips.ethereum.org/EIPS/eip-6963) (Hana Wallet, MetaMask, Phantom, etc.) ✅
  * Sui Wallets: ❌ Coming soon
  * Solana Wallets: ❌ Coming soon
  * Stellar Wallets: ❌ Coming soon
  * Injective Wallets: ❌ Coming soon
  * Havah Wallets: ❌ Coming soon
  * ICON Wallets: ❌ Coming soon
* Address and connection state management
  * EVM (Arbitrum, Avalanche, Base, BSC, Optimism, Polygon) ✅
  * Sui ❌ Coming soon
  * Solana ❌ Coming soon
  * Stellar ❌ Coming soon
  * Injective ❌ Coming soon
  * Havah ❌ Coming soon
  * ICON ❌ Coming soon

### Installation

```bash
# Using npm
npm install @sodax/wallet-sdk

# Using yarn
yarn add @sodax/wallet-sdk

# Using pnpm
pnpm add @sodax/wallet-sdk
```

### Peer Dependencies

This package requires the following peer dependencies:

```json
{
  "react": ">=19",
  "@tanstack/react-query": "latest"
}
```

### Quick Start

```typescript
import { XWagmiProviders, useXConnectors, useXConnect, useXAccount } from '@sodax/wallet-sdk';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

// Create a QueryClient instance
const queryClient = new QueryClient();

// Your wagmi configuration
const wagmiConfig = {
  // ... your wagmi config
};

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <XWagmiProviders
        config={{
          EVM: {
            wagmiConfig: wagmiConfig,
          },
          SUI: {
            isMainnet: true,
          },
          SOLANA: {
            endpoint: 'https://your-rpc-endpoint',
          },
        }}
      >
        <WalletConnect />
      </XWagmiProviders>
    </QueryClientProvider>
  );
}

function WalletConnect() {
  // Get available connectors for EVM chain
  const connectors = useXConnectors('EVM');
  
  // Get connect mutation
  const { mutateAsync: connect } = useXConnect();

  // Get connected account info
  const account = useXAccount('EVM');

  return (
    <div className="space-y-4">
      {/* Display connected wallet address if connected */}
      {account?.address && (
        <div className="p-4 bg-gray-100 rounded-lg">
          <p className="text-sm text-gray-600">Connected Wallet:</p>
          <p className="font-mono">{account.address}</p>
        </div>
      )}

      {/* Display available connectors */}
      <div className="space-y-2">
        {connectors.map((connector) => (
          <button
            key={connector.id}
            onClick={() => connect(connector)}
            className="flex items-center gap-2 p-2 border rounded-lg hover:bg-gray-50"
          >
            <img 
              src={connector.icon} 
              alt={connector.name} 
              width={24} 
              height={24} 
              className="rounded-md" 
            />
            <span>Connect {connector.name}</span>
          </button>
        ))}
      </div>
    </div>
  );
}
```

This example demonstrates:

1. Setting up the required providers (`QueryClientProvider` and `XWagmiProviders`)
2. Using `useXConnectors` to get available wallet connectors
3. Using `useXConnect` to handle wallet connections
4. Using `useXAccount` to display the connected wallet address
5. A basic UI to display and connect to available wallets

### Requirements

* Node.js >= 18.0.0
* React >= 19
* TypeScript

### API Reference

#### Components

* `XWagmiProviders` - Main provider component for wallet connectivity

#### Hooks

**Core Wallet Hooks**

* `useXConnectors` - Get available wallet connectors
* `useXConnect` - Connect to a wallet
* `useXAccount` - Get account information
* `useXDisconnect` - Disconnect from a wallet

**Chain-Specific Hooks**

* `useEvmSwitchChain` - Switch between EVM chains

**Balance Hooks**

* `useXBalances` - Fetch token balances

**Service Hooks**

* `useXService` - Access chain-specific service

#### Types

**Core Types**

* `XAccount` - Wallet account type
* `XConnection` - Wallet connection type
* `XConnector` - Wallet connector type
* `XToken` - Cross-chain token type

#### Classes

**XConnector**

* `XConnector` - Base class for wallet connectors
* `EvmXConnector` - EVM wallet connector
* `SolanaXConnector` - Solana wallet connector
* `SuiXConnector` - Sui wallet connector
* `StellarXConnector` - Stellar wallet connector
* `InjectiveMetamaskXConnector` - Injective MetaMask connector
* `InjectiveKelprXConnector` - Injective Keplr connector
* `HavahXConnector` - Havah wallet connector
* `IconXConnector` - ICON wallet connector

### Contributing

We welcome contributions! Please see our Contributing Guide for details.

### Development

```bash
# Install dependencies
pnpm install

# Build the package
pnpm build      

# Run in development mode
pnpm dev

# Run type checking
pnpm checkTs

# Format code
pnpm pretty

# Lint code
pnpm lint
```

### License

MIT

### Support

* [GitHub Issues](https://github.com/icon-project/sodax-frontend/issues)
* [Discord Community](https://discord.gg/sodax-formerly-icon-880651922682560582)

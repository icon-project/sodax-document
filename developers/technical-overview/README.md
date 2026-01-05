# 📖 Technical Overview

### Overview

This repository contains ICON's crosschain infrastructure and dapps built on it.

<figure><img src="../../.gitbook/assets/image (1).png" alt=""><figcaption></figcaption></figure>

### Infra Goals

* Any EVM dapp should be able to access any user on any connected chain without changes
* Any EVM dapp should be able to access any token on any connected chain without changes
* Any token should be able to be bridged to any other connected chain
* Crosschain messaging should be simple and reliable with little overhead

### App Goals

* Build a money market such that we can delegate liquidity to many different products and services
* Establish a new HUB for current ICON tokens

### Bridging

#### **AssetManager**

The **AssetManager** serves two primary functions:

1. **Value Transfer**: It facilitates the transfer of assets between different blockchains, enabling users to move value seamlessly across ecosystems.
2. **Hooks**: The bridge can act on behalf of the caller using the transferred tokens, allowing for complex, multi-chain user interactions and actions.

For more detailed specifications regarding the **AssetManager**, please refer to the full documentation [here](asset-manager.md).

#### **Hub Token Management**

With crosschain dapps there is usually lot of fragmentation. Same token represented on many chains or tokens priced very closely together such as wBTC and tBTC.\
So we need contract and logic to unify this fragmentation in a composable way. This can be done by a Tokenized Vault built to comply with the ICON crosschain token standard. Giving us full flexibility in solving liquidity fragmentation while also being able to take any token crosschain.

<figure><img src="../../.gitbook/assets/image (1) (1).png" alt=""><figcaption></figcaption></figure>

For more detailed specifications regarding the **Hub Token Management**, please refer to the full documentation [here](vault-token.md).

### Wallet Abstraction

The Wallet abstraction module's goal is to map each user on each chain to a wallet on the HUB. Making it a default entry point for users interacting from different ecosystems. This also gives us a flexible tool to integrate other interop solutions or bridges to use in our ecosystem, by giving them access to integrate into the wallet implementation.

For more detailed specifications regarding the **Wallet Abstraction**, please refer to the full documentation here.

### Intents

The **Intent** infrastructure is another key component of ICON's crosschain capabilities. Built on top of GMP, the Intent system resolves crosschain intents efficiently, enabling swapping and solving across any chain.

<figure><img src="../../.gitbook/assets/image (2).png" alt=""><figcaption></figcaption></figure>

For more detailed specifications regarding the **Intents**, please refer to the full documentation [here](intents.md).

### GMP (General Messaging Protocol)

The General Messaging Protocol (GMP) is a fundamental component designed to enable seamless communication between different blockchains and decentralized systems. Its primary objective is to maintain simplicity while offering maximum flexibility for building upon it.

The message structure in GMP contains all essential data:

* **srcChainId**: The identifier of the source blockchain
* **dstChainId**: The identifier of the destination blockchain
* **fromAddress**: The address from which the message is being sent
* **toAddress**: The address to which the message is being sent
* **data**: The payload or data being transferred between the two chains

#### Connection

The **Connection** verifies incoming messages and acts as a gateway for chains to send messages to any other connected chain. For more detailed specifications, please refer to the full documentation [here](generalized-messaging-protocol.md).

#### Relayer

The **Relayer** verifies and delivers messages across blockchains, confirming events and providing necessary signatures.

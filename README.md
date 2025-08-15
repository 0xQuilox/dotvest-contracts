# Dotvest Contracts
This repository contains a comprehensive suite of Solidity smart contracts designed to form a complete decentralized application (dApp) ecosystem. The contracts cover various core functionalities, including NFT minting, a token for company shares, a decentralized exchange (DEX) with an Automated Market Maker (AMM), secure access control, and integrations with off-chain data and services.

This documentation serves as a guide to the project's architecture, individual components, and their interactions.

## 🏗️ Project Components
The project is built around a modular architecture, with each contract serving a specific purpose. This design improves security, maintainability, and reusability.

Core Contracts
CompanyToken.sol: An ERC20 token representing company shares with a fixed initial supply of 1 million.

MintingController.sol: An ERC721 NFT contract for managing token minting. It supports allowlist and public sales, with pausing and ownership controls.

AMMPool.sol: An Automated Market Maker (AMM) pool for two ERC20 tokens, enabling decentralized swapping and liquidity provision.

ExchangeRouter.sol: The central entry point for users to interact with AMM pools. It handles liquidity management and token swaps.

StockPriceOracle.sol: An oracle contract for securely storing and providing a stock price feed to other on-chain contracts.

IdentityRegistry.sol: A registry for verified identities (KYC), allowing a trusted group of verifiers to manage a list of approved addresses.

OwnableAndRoles.sol: A custom access control contract that combines the security of a single owner with the flexibility of role-based permissions.

BackendProxy.sol: A secure proxy contract that acts as a gatekeeper, allowing only trusted backend services to execute certain on-chain actions.

Utility & Interface Contracts
SafeERC20.sol: A library that provides safe and robust functions for interacting with various ERC20 tokens.

ICompanyToken.sol: An interface for the CompanyToken contract, defining its external functions for other contracts to interact with.

IMintingController.sol: An interface for the MintingController NFT contract.

IExchangeRouter.sol: An interface for the ExchangeRouter contract.

IKYC.sol: An interface for the IdentityRegistry contract.

IOracle.sol: A generic interface for any oracle contract.

## ⚙️ Core Functionality & Architecture
The contracts are designed to work together to form a cohesive system. Here's a look at how the key components interact:

Access Control
The entire ecosystem relies on OwnableAndRoles.sol for access control. Instead of a single owner, this contract allows for a flexible, role-based system.

The DEFAULT_ADMIN_ROLE is granted to the contract deployer, who can then grant more specific roles.

MintingController.sol and StockPriceOracle.sol can be extended with roles like MINTER_ROLE or PRICE_UPDATER_ROLE to delegate specific administrative tasks without giving away full ownership.

Token and NFT Contracts
The CompanyToken.sol is a standard ERC20 token. It is the core financial asset of the project.

The MintingController.sol is the NFT collection. It can have different phases (allowlist, public) and uses a Merkle Tree for efficient on-chain verification of the allowlist.

Decentralized Exchange (DEX)
The DEX is built on two primary contracts:

AMMPool.sol: The core liquidity pool that uses the constant product formula (x⋅y=k). It allows users to provide liquidity and earn fees from swaps.

ExchangeRouter.sol: This contract acts as the public-facing API for the DEX. Users interact with the router to add/remove liquidity and swap tokens without needing to know the specific pool addresses. It also provides a function to create new pools.

SafeERC20.sol is crucial here, as it ensures all token transfers and approvals are handled safely, especially when dealing with non-standard ERC20 tokens.

Off-Chain Integration
The StockPriceOracle.sol provides a trust-based mechanism to bring off-chain data on-chain. An entity with the PRICE_UPDATER_ROLE can push new price data to the contract.

The IdentityRegistry.sol is a KYC system. An entity with the VERIFIER_ROLE can mark addresses as verified, which can then be checked by other contracts.

The BackendProxy.sol is the secure bridge between a trusted backend service and the smart contracts. A service with the BACKEND_ROLE can trigger functions on other contracts (e.g., calling updatePrice on the oracle) through this single, auditable entry point.

## 🛠️ Dependencies
This project relies on the following OpenZeppelin contracts for security and standardization:

@openzeppelin/contracts/token/ERC20/ERC20.sol

@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol

@openzeppelin/contracts/access/Ownable.sol (imported by OwnableAndRoles)

@openzeppelin/contracts/access/AccessControl.sol (imported by OwnableAndRoles)

@openzeppelin/contracts/security/ReentrancyGuard.sol

@openzeppelin/contracts/security/Pausable.sol

@openzeppelin/contracts/utils/cryptography/MerkleProof.sol

@openzeppelin/contracts/utils/Context.sol

@openzeppelin/contracts/utils/Address.sol

## 🚀 Setup and Deployment
Prerequisites: Install Node.js, npm, and a development environment like Hardhat or Foundry.

Install OpenZeppelin: Run npm install @openzeppelin/contracts.

Compile Contracts: Run npx hardhat compile or forge build.

Deploy: Use a deployment script to deploy the contracts in the correct order:

Deploy OwnableAndRoles.sol first.

Deploy CompanyToken.sol and other tokens.

Deploy AMMPool.sol and ExchangeRouter.sol.

Deploy MintingController.sol, StockPriceOracle.sol, IdentityRegistry.sol, and BackendProxy.sol.

Use the deployed addresses to link the contracts together as needed.

## 🤝 Contributing
Contributions are welcome! Please feel free to open issues or submit pull requests.

## 📜 License
This project is licensed under the MIT License.
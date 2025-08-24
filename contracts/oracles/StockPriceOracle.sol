// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../access/OwnableAndRoles.sol";

/**
 * @title StockPriceOracle
 * @dev An oracle contract that stores and provides the price of a stock.
 * This contract is designed to be a central data source for other smart contracts
 * that need to reference a stock's price, such as for tokenized assets, collateral,
 * or derivatives. The price is pushed on-chain by a trusted entity.
 *
 * This contract uses a role-based access control system to restrict
 * who can update the price, ensuring a high degree of security and trust.
 */
contract StockPriceOracle is OwnableAndRoles {
    // ==================
    // === State Variables ===
    // ==================

    // Stores the latest stock price.
    // The price is stored as an integer and uses a precision of 10^18 (18 decimal places),
    // similar to how ERC20 tokens handle decimals, to avoid floating-point errors.
    uint256 public stockPrice;
    
    // The timestamp when the price was last updated. This is critical for
    // consumers of the data to verify its freshness.
    uint256 public lastUpdated;
    
    // A constant to represent the role of the price updater.
    bytes32 public constant PRICE_UPDATER_ROLE = keccak256("PRICE_UPDATER_ROLE");

    // ==================
    // === Events ===
    // ==================

    /**
     * @dev Emitted when the stock price is successfully updated.
     * @param newPrice The new price of the stock.
     * @param timestamp The timestamp of the update.
     * @param updater The address that pushed the update.
     */
    event PriceUpdated(uint256 newPrice, uint256 timestamp, address indexed updater);

    // ==================
    // === Constructor ===
    // ==================

    /**
     * @dev Initializes the contract and grants the PRICE_UPDATER_ROLE
     * to the contract's deployer. This allows the deployer to immediately
     * start pushing price updates.
     */
    constructor() {
        _grantRole(PRICE_UPDATER_ROLE, _msgSender());
    }

    // ==================
    // === Price Update Function ===
    // ==================

    /**
     * @dev Allows an authorized address to update the stock price.
     * This function is restricted to addresses that have been granted the
     * PRICE_UPDATER_ROLE. It updates the price and the timestamp.
     * @param newPrice The new price to be set.
     */
    function updatePrice(uint256 newPrice) public onlyRole(PRICE_UPDATER_ROLE) {
        stockPrice = newPrice;
        lastUpdated = block.timestamp;
        
        emit PriceUpdated(newPrice, block.timestamp, _msgSender());
    }

    // ==================
    // === Price Retrieval Functions ===
    // ==================

    /**
     * @dev Returns the latest stock price and the timestamp of its last update.
     * This is the recommended function for consuming contracts as it provides
     * all necessary data to verify freshness.
     * @return price The latest stock price.
     * @return timestamp The timestamp of the last update.
     */
    function getLatestPrice() public view returns (uint256 price, uint256 timestamp) {
        return (stockPrice, lastUpdated);
    }
}

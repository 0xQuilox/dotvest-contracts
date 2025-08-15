// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IOracle
 * @dev A generic interface for a data oracle contract.
 * This interface defines a standard function for retrieving data and a
 * timestamp, making it easy for other contracts to interact with
 * any oracle implementation in a consistent manner.
 */
interface IOracle {
    // ==================
    // === Events ===
    // ==================

    /**
     * @dev Emitted when the data provided by the oracle is updated.
     * @param newData The new data being stored.
     * @param timestamp The timestamp of the update.
     * @param updater The address that pushed the update.
     */
    event DataUpdated(uint256 newData, uint256 timestamp, address indexed updater);

    // ==================
    // === Functions ===
    // ==================

    /**
     * @dev Returns the latest data from the oracle and the timestamp
     * of its last update.
     * @return data The latest data value.
     * @return timestamp The timestamp of the last update.
     */
    function getLatestData() external view returns (uint256 data, uint256 timestamp);
}
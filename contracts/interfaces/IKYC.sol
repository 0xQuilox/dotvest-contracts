// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IKYC
 * @dev An interface for a Know Your Customer (KYC) registry.
 * This interface defines the standard functions for a contract that tracks
 * the verification status of user addresses. It allows other contracts to
 * easily check if an address is verified in a modular and secure way.
 */
interface IKYC {
    // ==================
    // === Events ===
    // ==================

    /**
     * @dev Emitted when an address is added to the verified registry.
     * @param account The address that has been verified.
     * @param verifier The address that performed the verification.
     */
    event IdentityVerified(address indexed account, address indexed verifier);

    /**
     * @dev Emitted when an address is removed from the verified registry.
     * @param account The address that has been unverified.
     * @param verifier The address that performed the unverification.
     */
    event IdentityUnverified(address indexed account, address indexed verifier);

    // ==================
    // === Functions ===
    // ==================

    /**
     * @dev Checks if an address is a verified identity.
     * @param account The address to check.
     * @return A boolean indicating if the address is verified.
     */
    function checkIdentity(address account) external view returns (bool);
}

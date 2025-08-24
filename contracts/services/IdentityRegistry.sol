// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../access/OwnableAndRoles.sol";

/**
 * @title IdentityRegistry
 * @dev A contract for managing a registry of verified identities.
 * This contract uses a role-based access control system to allow
 * a trusted set of "verifiers" to register and unregister addresses
 * as verified identities. This is useful for projects that require
 * a form of on-chain KYC or whitelisting.
 */
contract IdentityRegistry is OwnableAndRoles {
    // ==================
    // === Role Identifiers ===
    // ==================

    // A constant to represent the role of a trusted verifier.
    // Only addresses with this role can add or remove identities.
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");

    // ==================
    // === State Variables ===
    // ==================

    // A mapping to store the verification status of an address.
    mapping(address => bool) private isVerified;

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
    // === Constructor ===
    // ==================
    
    /**
     * @dev Initializes the contract and grants the DEFAULT_ADMIN_ROLE
     * to the contract's deployer. The deployer can then grant the
     * VERIFIER_ROLE to other addresses.
     */
    constructor() {
        // The OwnableAndRoles constructor handles granting the initial admin role.
    }

    // ==================
    // === Registry Management Functions ===
    // ==================

    /**
     * @dev Adds an address to the registry of verified identities.
     * This function is restricted to addresses with the VERIFIER_ROLE.
     * @param account The address to be verified.
     */
    function addVerifiedIdentity(address account) public onlyRole(VERIFIER_ROLE) {
        // Ensure the address is not already verified.
        require(!isVerified[account], "Identity already verified");
        
        isVerified[account] = true;
        
        emit IdentityVerified(account, _msgSender());
    }

    /**
     * @dev Removes an address from the registry of verified identities.
     * This function is restricted to addresses with the VERIFIER_ROLE.
     * @param account The address to be unverified.
     */
    function removeVerifiedIdentity(address account) public onlyRole(VERIFIER_ROLE) {
        // Ensure the address is currently verified.
        require(isVerified[account], "Identity not verified");
        
        isVerified[account] = false;
        
        emit IdentityUnverified(account, _msgSender());
    }

    // ==================
    // === Public View Functions ===
    // ==================

    /**
     * @dev Checks if an address is a verified identity.
     * @param account The address to check.
     * @return A boolean indicating if the address is verified.
     */
    function checkIdentity(address account) public view returns (bool) {
        return isVerified[account];
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @title OwnableAndRoles
 * @dev A smart contract that combines the concepts of ownership with role-based access control.
 * This contract uses OpenZeppelin's AccessControl to define and manage different roles,
 * allowing for a more granular permission system than a single owner.
 * The deployer of this contract automatically receives the DEFAULT_ADMIN_ROLE.
 * * This contract is designed to be inherited by other contracts that need
 * advanced access control, such as a minting contract or a token contract.
 */
contract OwnableAndRoles is Context, AccessControl {
    // ==================
    // === Role Identifiers ===
    // ==================
    
    // The DEFAULT_ADMIN_ROLE is automatically granted to the deployer.
    // This role has the power to grant and revoke all other roles.

    // MINTER_ROLE is intended for addresses that are allowed to mint new tokens.
    // This role is especially useful for contracts like MintingController.sol.
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // PAUSER_ROLE is intended for addresses that can pause or unpause the contract.
    // This provides a safety mechanism for emergencies without requiring full admin access.
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    // ==================
    // === Constructor ===
    // ==================

    /**
     * @dev Initializes the contract by granting the DEFAULT_ADMIN_ROLE
     * to the address that deploys the contract.
     * This address can then grant other roles as needed.
     */
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    // ==================
    // === Role Management Functions ===
    // ==================
    
    /**
     * @dev Grants a role to an address.
     * Only an address with the DEFAULT_ADMIN_ROLE can call this function.
     * @param role The identifier of the role to grant.
     * @param account The address to which the role will be granted.
     */
    function grantRole(bytes32 role, address account) public virtual override {
        // Enforce that only an admin can grant roles.
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "AccessControl: sender must be an admin to grant");
        _grantRole(role, account);
    }
    
    /**
     * @dev Revokes a role from an address.
     * Only an address with the DEFAULT_ADMIN_ROLE can call this function.
     * @param role The identifier of the role to revoke.
     * @param account The address from which the role will be revoked.
     */
    function revokeRole(bytes32 role, address account) public virtual override {
        // Enforce that only an admin can revoke roles.
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "AccessControl: sender must be an admin to revoke");
        _revokeRole(role, account);
    }

    /**
     * @dev Renounces a role. The sender will lose the role and the action cannot be undone.
     * @param role The identifier of the role to renounce.
     * @param account The address renouncing the role (must be msg.sender).
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        _renounceRole(role, account);
    }

    // ==================
    // === Utility Functions ===
    // ==================

    /**
     * @dev Checks if an address has a specific role.
     * @param role The identifier of the role to check.
     * @param account The address to check.
     * @return A boolean indicating if the address has the role.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return AccessControl.hasRole(role, account);
    }
}
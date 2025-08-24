// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../access/OwnableAndRoles.sol";
import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @title BackendProxy
 * @dev A proxy contract that provides a secure, single point of entry
 * for off-chain backend services to interact with on-chain contracts.
 * This contract uses a role-based access control system to define
 * which backend services are trusted to make calls.
 *
 * This contract does not hold any funds or implement core logic, but rather
 * serves as a trusted intermediary to forward requests to other contracts.
 */
contract BackendProxy is OwnableAndRoles {
    // ==================
    // === Role Identifiers ===
    // ==================
    
    // A constant to represent the role of a trusted backend service.
    // Only addresses with this role can make calls through the proxy.
    bytes32 public constant BACKEND_ROLE = keccak256("BACKEND_ROLE");

    // ==================
    // === Events ===
    // ==================

    /**
     * @dev Emitted when a call is successfully forwarded by a trusted backend.
     * @param caller The address of the backend service that initiated the call.
     * @param target The address of the contract the call was forwarded to.
     * @param data The calldata used in the forwarded call.
     */
    event CallForwarded(address indexed caller, address indexed target, bytes data);

    // ==================
    // === Constructor ===
    // ==================

    /**
     * @dev Initializes the contract and grants the DEFAULT_ADMIN_ROLE
     * to the contract's deployer. The deployer is responsible for granting
     * the BACKEND_ROLE to trusted services.
     */
    constructor() {
        // The OwnableAndRoles constructor handles granting the initial admin role.
    }

    // ==================
    // === Proxy Function ===
    // ==================

    /**
     * @dev Forwards a call to a target contract.
     * This function is restricted to addresses with the BACKEND_ROLE.
     * It uses a low-level call to execute a function on a target contract,
     * which is useful for interacting with multiple contracts without
     * needing a specific function for each one.
     * @param target The address of the contract to call.
     * @param data The calldata for the function to be executed on the target contract.
     * @return success A boolean indicating if the low-level call was successful.
     * @return result The return data from the low-level call.
     */
    function forwardCall(
        address target,
        bytes memory data
    ) public onlyRole(BACKEND_ROLE) returns (bool success, bytes memory result) {
        // Ensure the target is a contract and not a regular address.
        require(target.code.length > 0, "Target is not a contract");

        // Use a low-level call to forward the data to the target contract.
        // This is a powerful but dangerous pattern; it's why the function
        // is protected by a role-based access control.
        (success, result) = target.call(data);

        // Revert if the call to the target contract failed.
        if (!success) {
            // Forward the revert reason from the target contract.
            if (result.length > 0) {
                assembly {
                    revert(add(32, result), mload(result))
                }
            } else {
                revert("BackendProxy: call failed");
            }
        }

        emit CallForwarded(_msgSender(), target, data);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title SafeERC20
 * @dev A library for interacting with ERC20 token contracts in a safe manner.
 * This library provides wrapper functions for standard ERC20 functions like
 * `transfer`, `transferFrom`, and `approve`. It handles tokens that either
 * revert or return a boolean value to indicate success or failure.
 *
 * This is especially useful for older or non-compliant tokens that don't
 * adhere to the full ERC20 specification, preventing unexpected behavior.
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev A safe wrapper for IERC20.transfer().
     * It ensures the call is successful and reverts if it is not.
     * @param token The address of the ERC20 token.
     * @param to The address to send tokens to.
     * @param value The amount of tokens to send.
     */
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev A safe wrapper for IERC20.transferFrom().
     * It ensures the call is successful and reverts if it is not.
     * @param token The address of the ERC20 token.
     * @param from The address to transfer tokens from.
     * @param to The address to transfer tokens to.
     * @param value The amount of tokens to transfer.
     */
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev A safe wrapper for IERC20.approve().
     * It ensures the call is successful and reverts if it is not.
     * The `safeApprove` function is particularly important as many older tokens
     * do not handle the "approve race condition" properly, and this wrapper helps
     * prevent that by requiring the current allowance to be zero before setting.
     * @param token The address of the ERC20 token.
     * @param spender The address to approve.
     * @param value The amount to approve.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // Solves the approve race condition by resetting the allowance to 0 first.
        (bool success, bytes memory returndata) = address(token).call(
            abi.encodeWithSelector(token.approve.selector, spender, 0)
        );
        require(success, "SafeERC20: approve failed");
        
        // Then, set the new allowance.
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev A safe wrapper for IERC20.increaseAllowance().
     * It ensures the call is successful and reverts if it is not.
     * @param token The address of the ERC20 token.
     * @param spender The address whose allowance to increase.
     * @param value The amount to add to the allowance.
     */
    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.increaseAllowance.selector, spender, value));
    }
    
    /**
     * @dev A safe wrapper for IERC20.decreaseAllowance().
     * It ensures the call is successful and reverts if it is not.
     * @param token The address of the ERC20 token.
     * @param spender The address whose allowance to decrease.
     * @param value The amount to subtract from the allowance.
     */
    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.decreaseAllowance.selector, spender, value));
    }

    /**
     * @dev Internal function to handle a low-level call to an ERC20 token contract.
     * It checks for both reverts and boolean return values to determine success.
     * @param token The address of the ERC20 token.
     * @param data The ABI-encoded function call data.
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // Perform a low-level call to the token contract.
        (bool success, bytes memory returndata) = address(token).call(data);
        
        // Ensure the call was successful.
        require(success, "SafeERC20: low-level call failed");

        // If the call returns data, ensure it's a single boolean 'true'.
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
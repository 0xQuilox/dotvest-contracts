// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ICompanyToken
 * @dev An interface for the CompanyToken.sol contract.
 * This interface defines the external functions of the CompanyToken,
 * including all standard ERC20 functions and the custom minting function.
 * Other contracts can import this interface to interact with a deployed
 * CompanyToken contract without needing its full code.
 */
interface ICompanyToken {
    // ==================
    // === ERC20 Standard Functions ===
    // ==================

    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the number of decimals used to get its user representation.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     * @param to The address to receive the tokens.
     * @param amount The number of tokens to transfer.
     * @return A boolean indicating whether the operation succeeded.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` is allowed to spend
     * on behalf of `owner`. This is zero by default.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     * @param spender The address to approve.
     * @param amount The number of tokens approved.
     * @return A boolean indicating whether the operation succeeded.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the allowance mechanism.
     * `amount` is then deducted from the caller's allowance.
     * @param from The address to transfer from.
     * @param to The address to transfer to.
     * @param amount The number of tokens to transfer.
     * @return A boolean indicating whether the operation succeeded.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    // ==================
    // === Custom Functions ===
    // ==================
    
    /**
     * @dev Mints `amount` new tokens and assigns them to `to`.
     * This function is intended to be protected by an access control mechanism
     * (like `onlyOwner`) in the actual `CompanyToken.sol` implementation.
     * @param to The address to receive the newly minted tokens.
     * @param amount The number of tokens to mint.
     */
    function mint(address to, uint256 amount) external;
}
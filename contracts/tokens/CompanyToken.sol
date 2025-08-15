// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title CompanyToken
 * @dev An ERC20 token contract designed to represent company shares.
 * It is initialized with a fixed total supply of 1,000,000 tokens
 * and includes a minting function for future issuance, which is restricted
 * to the contract owner.
 */
contract CompanyToken is ERC20, Ownable {
    // The total supply of tokens is set in the constructor.
    // ERC20 tokens typically use 18 decimal places, so 1,000,000 shares
    // is represented as 1,000,000 * 10^18.
    uint256 private constant INITIAL_SUPPLY = 1_000_000 * 10**18;

    /**
     * @dev Initializes the contract.
     * The name is set to "Company Shares" and the symbol to "COMP".
     * The initial supply of 1,000,000 shares is minted to the contract deployer.
     * @param initialOwner The address of the initial contract owner, who will receive all initial tokens.
     */
    constructor(address initialOwner) ERC20("Company Shares", "COMP") Ownable(initialOwner) {
        // Mint the total initial supply to the owner's address.
        _mint(initialOwner, INITIAL_SUPPLY);
    }

    /**
     * @dev Allows the contract owner to mint new tokens and assign them to an address.
     * This can be used for future capital increases or new share issuance.
     * @param to The address to receive the newly minted tokens.
     * @param amount The number of tokens (in their smallest unit) to mint.
     */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
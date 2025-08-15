// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IMintingController
 * @dev An interface for the MintingController.sol contract.
 * This interface defines all external functions for managing NFT minting,
 * including public and allowlist sales, as well as administrative functions.
 * Contracts can import and use this interface to safely interact with a
 * deployed MintingController contract.
 */
interface IMintingController {
    // ==================
    // === Events ===
    // ==================

    /**
     * @dev Emitted when the Merkle root for the allowlist is updated.
     * @param newMerkleRoot The new Merkle root hash.
     */
    event NewMerkleRoot(bytes32 newMerkleRoot);

    /**
     * @dev Emitted when the base URI for the token metadata is updated.
     * @param newBaseURI The new base URI string.
     */
    event NewBaseURI(string newBaseURI);

    // ==================
    // === Minting Functions ===
    // ==================

    /**
     * @dev Allows an authorized address to mint tokens for a specific recipient.
     * @param to The address to receive the tokens.
     * @param amount The number of tokens to mint.
     */
    function ownerMint(address to, uint256 amount) external;

    /**
     * @dev Allows an allowlist member to mint tokens.
     * @param amount The number of tokens to mint.
     * @param proof The Merkle proof for the caller's address.
     */
    function mintAllowlist(uint256 amount, bytes32[] calldata proof) external payable;

    /**
     * @dev Allows anyone to mint tokens during the public sale.
     * @param amount The number of tokens to mint.
     */
    function mintPublic(uint256 amount) external payable;

    // ==================
    // === Administrative Functions ===
    // ==================

    /**
     * @dev Allows an authorized address to set the Merkle root for the allowlist sale.
     * @param newMerkleRoot_ The new Merkle root hash.
     */
    function setMerkleRoot(bytes32 newMerkleRoot_) external;

    /**
     * @dev Allows an authorized address to set the base URI for the token metadata.
     * @param baseURI_ The new base URI string.
     */
    function setBaseURI(string memory baseURI_) external;

    /**
     * @dev Allows an authorized address to set the public mint price.
     * @param newPublicMintPrice The new price for a single NFT in wei.
     */
    function setPublicMintPrice(uint256 newPublicMintPrice) external;

    /**
     * @dev Allows an authorized address to withdraw all funds from the contract.
     */
    function withdraw() external;

    /**
     * @dev Pauses all minting and transfers.
     */
    function pause() external;

    /**
     * @dev Unpauses the contract, allowing minting and transfers to resume.
     */
    function unpause() external;
}
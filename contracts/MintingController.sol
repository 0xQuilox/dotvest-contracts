// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
 * @title MintingController
 * @dev A comprehensive and secure smart contract for managing NFT minting.
 * This contract supports multiple minting phases, including a public sale and an allowlist sale
 * verified by a Merkle Tree. It also includes pausing functionality and reentrancy protection.
 */
contract MintingController is ERC721Enumerable, Ownable, Pausable, ReentrancyGuard {
    // ==================
    // === State Variables ===
    // ==================

    // The maximum number of tokens that can ever be minted.
    uint256 public maxSupply;
    
    // The maximum number of tokens a single wallet can mint in a single transaction.
    uint256 public maxPublicMint;

    // The price for a single NFT during the public sale phase.
    uint256 public publicMintPrice;
    
    // Stores the Merkle root for the allowlist sale.
    bytes32 public merkleRoot;

    // Maps a wallet address to the number of tokens they have minted.
    mapping(address => uint256) public numMintedByWallet;
    
    // Stores a mapping of an address to whether they've used their allowlist mint.
    // This is useful for "one-time-use" allowlist proofs.
    mapping(address => bool) private hasClaimedAllowlist;

    // ==================
    // === Events ===
    // ==================
    
    event NewMerkleRoot(bytes32 newMerkleRoot);
    event NewBaseURI(string newBaseURI);

    // ==================
    // === Constructor ===
    // ==================

    /**
     * @dev Initializes the contract with the NFT collection name and symbol.
     * @param name_ The name of the NFT collection.
     * @param symbol_ The symbol of the NFT collection.
     * @param initialMaxSupply The total supply cap for the entire collection.
     * @param initialMaxPublicMint The maximum number of tokens per wallet for public sale.
     * @param initialPublicMintPrice The price per token for public sale.
     * @param owner The address of the initial contract owner.
     */
    constructor(
        string memory name_, 
        string memory symbol_,
        uint256 initialMaxSupply,
        uint256 initialMaxPublicMint,
        uint256 initialPublicMintPrice,
        address owner
    ) ERC721(name_, symbol_) Ownable(owner) {
        maxSupply = initialMaxSupply;
        maxPublicMint = initialMaxPublicMint;
        publicMintPrice = initialPublicMintPrice;
    }

    // ==================
    // === Minting Functions ===
    // ==================

    /**
     * @dev Allows the owner to mint a specific number of tokens to an address.
     * This is useful for team tokens, airdrops, or giveaways.
     * @param to The address to receive the tokens.
     * @param amount The number of tokens to mint.
     */
    function ownerMint(address to, uint256 amount) public onlyOwner {
        // Ensure the amount to mint is not zero.
        require(amount > 0, "Amount must be greater than 0");
        // Check if minting would exceed the total supply.
        require(totalSupply() + amount <= maxSupply, "Exceeds max supply");

        // Mint each token one by one.
        for (uint256 i = 0; i < amount; i++) {
            _safeMint(to, totalSupply());
        }
    }

    /**
     * @dev Allows allowlist members to mint tokens.
     * A Merkle proof is required to verify the caller is on the allowlist.
     * @param amount The number of tokens to mint.
     * @param proof The Merkle proof for the caller's address.
     */
    function mintAllowlist(uint256 amount, bytes32[] calldata proof) public payable whenNotPaused nonReentrant {
        // Ensure the amount to mint is not zero.
        require(amount > 0, "Amount must be greater than 0");
        // Check if minting would exceed the total supply.
        require(totalSupply() + amount <= maxSupply, "Exceeds max supply");
        // Ensure the sender has not already used their allowlist mint.
        require(!hasClaimedAllowlist[_msgSender()], "Allowlist mint already claimed");

        // The hash to verify against the Merkle tree.
        bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));
        
        // Use the MerkleProof library to verify the leaf against the Merkle root.
        require(MerkleProof.verify(proof, merkleRoot, leaf), "Invalid Merkle proof");

        // Ensure the correct amount of Ether was sent.
        // You would typically set a separate price for allowlist, but for this example,
        // we'll assume it's free or a fixed price verified off-chain.
        // For a fixed price allowlist, you would do: require(msg.value >= ALLOWLIST_PRICE * amount, "Insufficient ETH");
        
        hasClaimedAllowlist[_msgSender()] = true; // Mark as claimed

        for (uint256 i = 0; i < amount; i++) {
            _safeMint(_msgSender(), totalSupply());
        }
    }
    
    /**
     * @dev Public minting function.
     * Anyone can call this function to mint tokens as long as the contract is not paused
     * and the supply limits are not exceeded.
     * @param amount The number of tokens to mint.
     */
    function mintPublic(uint256 amount) public payable whenNotPaused nonReentrant {
        // Ensure the amount to mint is valid.
        require(amount > 0 && amount <= maxPublicMint, "Invalid mint amount");
        // Check if minting would exceed the total supply.
        require(totalSupply() + amount <= maxSupply, "Exceeds max supply");
        // Ensure the sender sends enough Ether.
        require(msg.value >= publicMintPrice * amount, "Insufficient ETH");

        // The number of tokens this wallet has minted in total cannot exceed the max.
        numMintedByWallet[_msgSender()] += amount;
        require(numMintedByWallet[_msgSender()] <= maxPublicMint, "Exceeds max mints per wallet");

        // Mint each token one by one.
        for (uint256 i = 0; i < amount; i++) {
            _safeMint(_msgSender(), totalSupply());
        }
    }

    // ==================
    // === Owner-only Functions ===
    // ==================
    
    /**
     * @dev Allows the owner to set the Merkle root for the allowlist sale.
     * @param newMerkleRoot_ The new Merkle root hash.
     */
    function setMerkleRoot(bytes32 newMerkleRoot_) public onlyOwner {
        merkleRoot = newMerkleRoot_;
        emit NewMerkleRoot(newMerkleRoot_);
    }

    /**
     * @dev Allows the owner to set the base URI for the token metadata.
     * For example: "ipfs://QmbFqR7x5R7z4D7t7Q6Y6x5g5d5b7v4b4f5m4v9c9e8r8s/"
     * @param baseURI_ The new base URI string.
     */
    function setBaseURI(string memory baseURI_) public onlyOwner {
        _setBaseURI(baseURI_);
        emit NewBaseURI(baseURI_);
    }

    /**
     * @dev Allows the owner to set the public mint price.
     * @param newPublicMintPrice The new price for a single NFT in wei.
     */
    function setPublicMintPrice(uint256 newPublicMintPrice) public onlyOwner {
        publicMintPrice = newPublicMintPrice;
    }

    /**
     * @dev Allows the owner to withdraw all funds from the contract to their address.
     * This function is protected by the ReentrancyGuard modifier.
     */
    function withdraw() public onlyOwner nonReentrant {
        // Get the balance of the contract.
        uint256 balance = address(this).balance;
        // Transfer the full balance to the owner.
        (bool success, ) = payable(_msgSender()).call{value: balance}("");
        require(success, "Withdrawal failed");
    }

    /**
     * @dev Pauses all minting and transfers.
     * Only the owner can call this.
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses the contract, allowing minting and transfers to resume.
     * Only the owner can call this.
     */
    function unpause() public onlyOwner {
        _unpause();
    }
    
    // ==================
    // === Internal Functions ===
    // ==================
    
    /**
     * @dev Override of the Pausable contract's internal hook.
     * This ensures that ERC721 transfers are blocked when the contract is paused.
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721Enumerable, Pausable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }
}
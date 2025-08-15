// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./AMMPool.sol"; // Assuming AMMPool is in the same directory

/**
 * @title IExchangeRouter
 * @dev A simple interface for the AMM pool contract.
 * This is good practice to ensure type safety when interacting with pools.
 */
interface IExchangePool {
    function tokenA() external view returns (IERC20);
    function tokenB() external view returns (IERC20);
    function addLiquidity(uint256 amountA, uint256 amountB) external;
    function removeLiquidity(uint256 shares) external returns (uint256 amountA, uint256 amountB);
    function swapAForB(uint256 amountIn) external returns (uint256 amountOut);
    function swapBForA(uint256 amountIn) external returns (uint256 amountOut);
}

/**
 * @title ExchangeRouter
 * @dev A router contract for swapping tokens and managing liquidity across AMM pools.
 * This contract simplifies user interactions by providing a single point of entry
 * for all trading and liquidity provision activities.
 *
 * NOTE: This is a basic implementation and does not yet support multi-hop swaps.
 * It assumes a direct pool exists for any two tokens being swapped.
 */
contract ExchangeRouter {
    // ==================
    // === State Variables ===
    // ==================
    
    // A factory contract would typically create pools, but for this example,
    // we use a mapping to store a reference to pools.
    mapping(address => mapping(address => address)) public getPool;

    // A mapping to store a list of all tokens for a given pool
    mapping(address => address) public poolToTokenA;
    mapping(address => address) public poolToTokenB;

    // ==================
    // === Events ===
    // ==================

    event PoolCreated(address indexed tokenA, address indexed tokenB, address indexed pool);

    // ==================
    // === Public Functions ===
    // ==================

    /**
     * @dev Creates a new AMM pool for two tokens.
     * This function is intended to be called by a factory contract, but for simplicity,
     * it's included here. It prevents duplicate pools for the same pair.
     * @param tokenA The address of the first ERC20 token.
     * @param tokenB The address of the second ERC20 token.
     * @param swapFee The fee for swaps in the new pool (e.g., 3 for 0.3%).
     * @return pool The address of the newly created AMM pool.
     */
    function createPool(
        address tokenA, 
        address tokenB, 
        uint256 swapFee
    ) public returns (address pool) {
        // Ensure tokens are not the same and not the zero address.
        require(tokenA != address(0) && tokenB != address(0) && tokenA != tokenB, "Invalid tokens");
        
        // Ensure a pool for this pair does not already exist.
        require(getPool[tokenA][tokenB] == address(0), "Pool already exists");

        // Use the smaller address as tokenA to standardize pool creation.
        (address _tokenA, address _tokenB) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);

        // Deploy the new AMMPool contract.
        pool = address(new AMMPool(_tokenA, _tokenB, swapFee));

        // Store the pool address in the mapping.
        getPool[_tokenA][_tokenB] = pool;
        getPool[_tokenB][_tokenA] = pool;

        emit PoolCreated(_tokenA, _tokenB, pool);
    }
    
    /**
     * @dev Provides liquidity to a pool.
     * The user must have approved the router to spend their tokens.
     * @param tokenA The address of the first ERC20 token.
     * @param tokenB The address of the second ERC20 token.
     * @param amountA The amount of tokenA to add.
     * @param amountB The amount of tokenB to add.
     */
    function addLiquidity(
        address tokenA, 
        address tokenB, 
        uint256 amountA, 
        uint256 amountB
    ) public {
        // Find the pool for the token pair.
        address poolAddress = getPool[tokenA][tokenB];
        require(poolAddress != address(0), "Pool does not exist");
        IExchangePool pool = IExchangePool(poolAddress);

        // Transfer tokens from the sender to the router.
        require(IERC20(tokenA).transferFrom(_msgSender(), address(this), amountA), "TokenA transfer failed");
        require(IERC20(tokenB).transferFrom(_msgSender(), address(this), amountB), "TokenB transfer failed");

        // The router approves the pool to spend the tokens, then calls addLiquidity.
        require(IERC20(tokenA).approve(poolAddress, amountA), "TokenA approval failed");
        require(IERC20(tokenB).approve(poolAddress, amountB), "TokenB approval failed");

        pool.addLiquidity(amountA, amountB);
    }
    
    /**
     * @dev Removes liquidity from a pool.
     * @param tokenA The address of the first ERC20 token.
     * @param tokenB The address of the second ERC20 token.
     * @param shares The number of liquidity shares to burn.
     * @return amountA The amount of tokenA returned to the provider.
     * @return amountB The amount of tokenB returned to the provider.
     */
    function removeLiquidity(
        address tokenA, 
        address tokenB, 
        uint256 shares
    ) public returns (uint256 amountA, uint256 amountB) {
        // Find the pool for the token pair.
        address poolAddress = getPool[tokenA][tokenB];
        require(poolAddress != address(0), "Pool does not exist");
        IExchangePool pool = IExchangePool(poolAddress);

        // Call the pool's removeLiquidity function.
        (amountA, amountB) = pool.removeLiquidity(shares);
    }

    /**
     * @dev Swaps tokens through a direct pool.
     * This is a simplified version and does not support multi-hop swaps.
     * The user must approve the router to spend tokens before calling.
     * @param tokenIn The token being sent by the user.
     * @param tokenOut The token the user wants to receive.
     * @param amountIn The amount of tokenIn to swap.
     * @return amountOut The amount of tokenOut received.
     */
    function swap(
        address tokenIn, 
        address tokenOut, 
        uint256 amountIn
    ) public returns (uint256 amountOut) {
        // Find the pool for the token pair.
        address poolAddress = getPool[tokenIn][tokenOut];
        require(poolAddress != address(0), "Pool does not exist");
        IExchangePool pool = IExchangePool(poolAddress);
        
        // Transfer tokens from the sender to the router.
        require(IERC20(tokenIn).transferFrom(_msgSender(), address(this), amountIn), "TokenIn transfer failed");

        // The router approves the pool to spend the tokens.
        require(IERC20(tokenIn).approve(poolAddress, amountIn), "TokenIn approval failed");
        
        // Call the appropriate swap function on the pool.
        if (pool.tokenA() == IERC20(tokenIn)) {
            amountOut = pool.swapAForB(amountIn);
        } else {
            amountOut = pool.swapBForA(amountIn);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IExchangeRouter
 * @dev An interface for the ExchangeRouter.sol contract.
 * This interface defines all external functions for managing liquidity and swapping
 * tokens across AMM pools. Contracts can import and use this interface to
 * safely interact with a deployed ExchangeRouter.
 */
interface IExchangeRouter {
    // ==================
    // === Events ===
    // ==================

    /**
     * @dev Emitted when a new AMM pool is successfully created by the router.
     * @param tokenA The address of the first token in the new pool.
     * @param tokenB The address of the second token in the new pool.
     * @param pool The address of the newly created AMM pool contract.
     */
    event PoolCreated(address indexed tokenA, address indexed tokenB, address indexed pool);

    // ==================
    // === Functions ===
    // ==================

    /**
     * @dev Returns the address of the pool for a given pair of tokens.
     * @param tokenA The address of the first token.
     * @param tokenB The address of the second token.
     * @return The address of the corresponding AMM pool contract.
     */
    function getPool(address tokenA, address tokenB) external view returns (address);

    /**
     * @dev Creates a new AMM pool for two tokens.
     * @param tokenA The address of the first ERC20 token.
     * @param tokenB The address of the second ERC20 token.
     * @param swapFee The fee for swaps in the new pool (e.g., 3 for 0.3%).
     * @return The address of the newly created AMM pool.
     */
    function createPool(
        address tokenA, 
        address tokenB, 
        uint256 swapFee
    ) external returns (address);

    /**
     * @dev Provides liquidity to a pool.
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
    ) external;

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
    ) external returns (uint256 amountA, uint256 amountB);

    /**
     * @dev Swaps tokens through a direct pool.
     * @param tokenIn The token being sent by the user.
     * @param tokenOut The token the user wants to receive.
     * @param amountIn The amount of tokenIn to swap.
     * @return amountOut The amount of tokenOut received.
     */
    function swap(
        address tokenIn, 
        address tokenOut, 
        uint256 amountIn
    ) external returns (uint256 amountOut);
}
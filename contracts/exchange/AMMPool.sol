// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./access/OwnableAndRoles.sol";

/**
 * @title AMMPool
 * @dev An Automated Market Maker (AMM) pool for two ERC20 tokens.
 * This contract uses the constant product formula x * y = k to determine swap prices.
 * It also includes liquidity provision and removal, as well as a swap fee.
 */
contract AMMPool is OwnableAndRoles, ReentrancyGuard {
    // ==================
    // === State Variables ===
    // ==================
    
    // The two ERC20 tokens in the pool.
    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;
    
    // The fixed swap fee, e.g., 0.3% is 3.
    // The fee is stored as an integer, multiplied by a fee precision.
    uint256 public immutable swapFee;
    uint256 public immutable feePrecision;
    
    // Total liquidity shares issued.
    uint256 public totalLiquidity;
    
    // Mapping of an address to their liquidity shares.
    mapping(address => uint256) public liquidityShares;

    // ==================
    // === Events ===
    // ==================
    
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 sharesMinted);
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB, uint256 sharesBurned);
    event Swapped(address indexed swapper, address fromToken, address toToken, uint256 amountIn, uint256 amountOut);

    // ==================
    // === Constructor ===
    // ==================
    
    /**
     * @dev Initializes the AMM pool with two tokens and a swap fee.
     * @param _tokenA The address of the first ERC20 token.
     * @param _tokenB The address of the second ERC20 token.
     * @param _swapFee The swap fee, e.g., 3 for 0.3%.
     */
    constructor(
        address _tokenA, 
        address _tokenB, 
        uint256 _swapFee
    ) {
        require(_tokenA != address(0) && _tokenB != address(0) && _tokenA != _tokenB, "Invalid token addresses");
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        swapFee = _swapFee;
        feePrecision = 10000; // Represents 100%, so 3 is 0.03%
    }
    
    // ==================
    // === Public Functions ===
    // ==================
    
    /**
     * @dev Provides liquidity to the pool.
     * Tokens must be approved to be spent by this contract beforehand.
     * @param amountA The amount of tokenA to add.
     * @param amountB The amount of tokenB to add.
     */
    function addLiquidity(uint256 amountA, uint256 amountB) public nonReentrant {
        // Ensure amounts are non-zero.
        require(amountA > 0 && amountB > 0, "Amounts must be greater than zero");

        // Get current reserves.
        uint256 reserveA = tokenA.balanceOf(address(this));
        uint256 reserveB = tokenB.balanceOf(address(this));
        
        uint256 sharesToMint;

        if (totalLiquidity == 0) {
            // First liquidity provider sets the initial ratio.
            sharesToMint = amountA;
        } else {
            // Check if the ratio of the new liquidity matches the pool's ratio.
            require(reserveA * amountB == reserveB * amountA, "Amounts must match pool ratio");
            sharesToMint = (amountA * totalLiquidity) / reserveA;
        }
        
        // Transfer tokens from the liquidity provider to the pool.
        require(tokenA.transferFrom(_msgSender(), address(this), amountA), "TokenA transfer failed");
        require(tokenB.transferFrom(_msgSender(), address(this), amountB), "TokenB transfer failed");

        // Mint liquidity shares to the provider.
        totalLiquidity += sharesToMint;
        liquidityShares[_msgSender()] += sharesToMint;

        emit LiquidityAdded(_msgSender(), amountA, amountB, sharesToMint);
    }
    
    /**
     * @dev Removes liquidity from the pool by burning shares.
     * @param shares The number of liquidity shares to burn.
     * @return amountA The amount of tokenA returned to the provider.
     * @return amountB The amount of tokenB returned to the provider.
     */
    function removeLiquidity(uint256 shares) public nonReentrant returns (uint256 amountA, uint256 amountB) {
        // Ensure the provider has enough shares to burn.
        require(shares > 0 && shares <= liquidityShares[_msgSender()], "Invalid shares amount");

        // Get current reserves.
        uint256 reserveA = tokenA.balanceOf(address(this));
        uint256 reserveB = tokenB.balanceOf(address(this));
        
        // Calculate the proportion of the reserves to return.
        amountA = (reserveA * shares) / totalLiquidity;
        amountB = (reserveB * shares) / totalLiquidity;
        
        // Ensure the amounts are non-zero.
        require(amountA > 0 && amountB > 0, "Amounts must be greater than zero");

        // Update liquidity shares.
        totalLiquidity -= shares;
        liquidityShares[_msgSender()] -= shares;
        
        // Transfer the tokens back to the provider.
        require(tokenA.transfer(_msgSender(), amountA), "TokenA transfer failed");
        require(tokenB.transfer(_msgSender(), amountB), "TokenB transfer failed");

        emit LiquidityRemoved(_msgSender(), amountA, amountB, shares);
    }

    /**
     * @dev Swaps tokenA for tokenB.
     * @param amountIn The amount of tokenA to swap.
     * @return amountOut The amount of tokenB received.
     */
    function swapAForB(uint256 amountIn) public nonReentrant returns (uint256 amountOut) {
        return _swap(tokenA, tokenB, amountIn);
    }

    /**
     * @dev Swaps tokenB for tokenA.
     * @param amountIn The amount of tokenB to swap.
     * @return amountOut The amount of tokenA received.
     */
    function swapBForA(uint256 amountIn) public nonReentrant returns (uint256 amountOut) {
        return _swap(tokenB, tokenA, amountIn);
    }

    // ==================
    // === Internal Functions ===
    // ==================

    /**
     * @dev Internal function to handle the core swap logic.
     * @param fromToken The token to be sent to the pool.
     * @param toToken The token to be received from the pool.
     * @param amountIn The amount of fromToken to swap.
     * @return amountOut The amount of toToken received.
     */
    function _swap(IERC20 fromToken, IERC20 toToken, uint256 amountIn) private returns (uint256 amountOut) {
        // Ensure amount is non-zero.
        require(amountIn > 0, "Amount must be greater than zero");
        
        // Transfer tokens from the swapper to the pool.
        require(fromToken.transferFrom(_msgSender(), address(this), amountIn), "Token transfer failed");

        // Get reserves after the transfer.
        uint256 reserveIn = fromToken.balanceOf(address(this));
        uint256 reserveOut = toToken.balanceOf(address(this));
        
        // Calculate amount to deduct for fees.
        uint256 amountWithFee = amountIn * (feePrecision - swapFee);
        
        // Apply the constant product formula: (reserveIn + amountWithFee) * (reserveOut - amountOut) = reserveIn * reserveOut
        // Rearranging for amountOut: amountOut = (reserveOut * amountWithFee) / (reserveIn + amountWithFee)
        amountOut = (reserveOut * amountWithFee) / (reserveIn + amountWithFee);

        // Ensure the swap is not a complete loss.
        require(amountOut > 0, "Insufficient liquidity");
        
        // Transfer tokens from the pool to the swapper.
        require(toToken.transfer(_msgSender(), amountOut), "Token transfer failed");

        emit Swapped(_msgSender(), address(fromToken), address(toToken), amountIn, amountOut);
    }
}
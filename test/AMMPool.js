// Import modules for testing
import { expect } from "chai";
import { ethers } from "hardhat";

describe("AMMPool Integration", function () {
    let tokenA;
    let tokenB;
    let ammpool;
    let owner;
    let user;

    const initialLiquidity = ethers.parseUnits("1000", 18);

    beforeEach(async function () {
        // Get the signers
        [owner, user] = await ethers.getSigners();

        // Deploy two ERC20 tokens for the pool
        const TokenFactory = await ethers.getContractFactory("CompanyToken");
        tokenA = await TokenFactory.deploy();
        tokenB = await TokenFactory.deploy();

        // Deploy the AMM pool
        const AMMPoolFactory = await ethers.getContractFactory("AMMPool");
        ammpool = await AMMPoolFactory.deploy(tokenA.address, tokenB.address);

        // Mint and approve tokens for the liquidity provider (owner)
        await tokenA.transfer(user.address, initialLiquidity);
        await tokenB.transfer(user.address, initialLiquidity);

        // The user must approve the AMMPool contract to spend their tokens
        await tokenA.connect(user).approve(ammpool.address, initialLiquidity);
        await tokenB.connect(user).approve(ammpool.address, initialLiquidity);
    });

    it("should allow a user to add initial liquidity and mint LP tokens", async function () {
        // Add initial liquidity
        await ammpool.connect(user).addLiquidity(initialLiquidity, initialLiquidity);

        // Check the reserves in the pool
        const reserveA = await tokenA.balanceOf(ammpool.address);
        const reserveB = await tokenB.balanceOf(ammpool.address);
        expect(reserveA).to.equal(initialLiquidity);
        expect(reserveB).to.equal(initialLiquidity);

        // Check the liquidity tokens minted for the user
        const liquidityTokens = await ammpool.balanceOf(user.address);
        expect(liquidityTokens).to.be.gt(0); // Should be a positive value
    });

    it("should allow a user to swap tokens and update pool reserves", async function () {
        // First, add initial liquidity
        await ammpool.connect(user).addLiquidity(initialLiquidity, initialLiquidity);

        // Approve the pool for a swap
        const swapAmount = ethers.parseUnits("100", 18);
        await tokenA.connect(user).approve(ammpool.address, swapAmount);

        // Perform the swap
        await ammpool.connect(user).swap(tokenA.address, swapAmount);

        // Check the new balances
        const userTokenABalance = await tokenA.balanceOf(user.address);
        const userTokenBBalance = await tokenB.balanceOf(user.address);
        
        // We can't know the exact new balance due to the AMM formula,
        // but we can check if the balances have changed as expected
        expect(userTokenABalance).to.be.lt(initialLiquidity);
        expect(userTokenBBalance).to.be.gt(0);
        
        // Check that the pool's token A reserve has increased
        const finalReserveA = await ammpool.getReserveA();
        expect(finalReserveA).to.be.gt(initialLiquidity);
    });
});
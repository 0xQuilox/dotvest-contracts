// Import the necessary modules for testing
import { expect } from "chai";
import { ethers } from "hardhat";
describe("CompanyToken", function () {
    // A variable to hold the deployed contract instance
    let CompanyToken;
    let owner;
    let addr1;
    let addr2;

    const initialSupply = 1000000;

    // This block runs before each test case
    beforeEach(async function () {
        // Get the contract factory and signers
        const CompanyTokenFactory = await ethers.getContractFactory("CompanyToken");
        [owner, addr1, addr2] = await ethers.getSigners();

        // Deploy the contract
        CompanyToken = await CompanyTokenFactory.deploy();
    });

    // Test the deployment and initial state
    it("should deploy with the correct total supply and assign it to the owner", async function () {
        const ownerBalance = await CompanyToken.balanceOf(owner.address);
        expect(await CompanyToken.totalSupply()).to.equal(ownerBalance);
        expect(ownerBalance).to.equal(ethers.parseUnits(String(initialSupply), 18));
    });

    // Test a basic transfer of tokens
    it("should allow a user to transfer tokens to another address", async function () {
        // Transfer 100 tokens from owner to addr1
        await CompanyToken.transfer(addr1.address, ethers.parseUnits("100", 18));
        const addr1Balance = await CompanyToken.balanceOf(addr1.address);
        expect(addr1Balance).to.equal(ethers.parseUnits("100", 18));
    });

    // Test a negative case where a transfer should fail
    it("should revert if an account tries to transfer more than its balance", async function () {
        // Try to transfer 2 million tokens, which is more than the total supply
        const amount = ethers.parseUnits("2000000", 18);
        await expect(CompanyToken.transfer(addr1.address, amount)).to.be.revertedWithCustomError(
            CompanyToken,
            "ERC20InsufficientBalance"
        );
    });
});
const { expect } = require("chai");
const { formatEther } = require("ethers");
const { ethers } = require("hardhat");

let lendingProtocolAddress;

describe("LendingProtocol", function () {
  let lendingProtocol;
  let token;
  let deployer, user1, user2;

  beforeEach(async function () {
    // Get signers
    [deployer, user1, user2] = await ethers.getSigners();

    // Deploy LPToken contract
    const Token = await ethers.getContractFactory("LPToken");
    token = await Token.deploy();
    // console.log("Token address:", await token.getAddress());
    const tokenAddress = await token.getAddress();

    // Deploy LendingProtocol contract
    const LendingProtocol = await ethers.getContractFactory("LendingProtocol");
    lendingProtocol = await LendingProtocol.deploy(tokenAddress);
    console.log("LendingProtocol address:", await lendingProtocol.getAddress());
    lendingProtocolAddress = await lendingProtocol.getAddress();

    //send 500000 LPT from the deployer of the LPToken contract to the protocol
    const amountToSend = ethers.parseEther("500000");
    await token
      .connect(deployer)
      .transfer(lendingProtocolAddress, amountToSend);
  });

  it("the protocol should have 500000 tokens in the pool", async function () {
    const totalLPTokens = await token.balanceOf(lendingProtocolAddress);
    expect(totalLPTokens).to.equal(ethers.parseEther("500000"));
    //we can do this by callig a view function also
    const totalLPtokensViaFunctionCall =
      await lendingProtocol.getTotalLiquidity();
    expect(totalLPtokensViaFunctionCall).to.equal(ethers.parseEther("500000"));
  });
  //testing the depositETH function
  it("does not accept zero amount", async function () {
    await expect(
      lendingProtocol.connect(user1).depositETH(0)
    ).to.be.revertedWith("Amount must be greater than 0");
  });

  it("accepts a non-zero ETH deposit", async function () {
    const amountToDeposit = 10; // Or any other non-zero amount

    // Use try-catch to handle potential errors and ensure a successful transaction
    try {
      await lendingProtocol.connect(user1).depositETH(amountToDeposit);
    } catch (error) {
      // If there's an error, fail the test
      console.error("Transaction failed:", error);
      return expect(false).to.be.true; // Explicitly fail the test
    }

    // If the transaction succeeds, no error will be thrown, and the test will continue

    // Verify that the deposit was successful (optional):
    // - Check updated ETH balance or LP token balance
    // - Assert relevant events emitted by the contract
  });

  it("user should be able to deposit ETH to the protocol", async function () {
    //  connect to user1 and deposit 1 eth to the protocol
    const depositAmount = 10000;
    await lendingProtocol
      .connect(user1)
      .depositETH(depositAmount, { value: depositAmount });

    //  Wait for one block
    await ethers.provider.send("evm_mine", []);

    const ethInPool = await lendingProtocol.getTotalEthLocked();

    await ethers.provider.send("evm_mine", []);

    expect(ethInPool).to.equal(depositAmount);
  });

  //  these brackets belong to describe statement
});

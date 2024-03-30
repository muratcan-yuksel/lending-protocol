const { expect } = require("chai");
const { formatEther } = require("ethers");
const { ethers } = require("hardhat");

let lendingProtocolAddress;

describe("LendingProtocol", function () {
  let lendingProtocol;
  let token;
  let deployer, user1, user2;

  // Shared setup function**
  async function setupContracts() {
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
  }

  //we're writing this as a function so that we can reuse it in our test cases
  async function depositETH(user, amount) {
    // const depositAmount = 10;
    await lendingProtocol.connect(user).depositETH(amount, { value: amount });
  }

  beforeEach(async function () {
    //call the setup function
    await setupContracts();
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
    await expect(depositETH(user1, 0)).to.be.revertedWith(
      "Amount must be greater than 0"
    );
  });

  it("accepts a non-zero amount", async function () {
    const amountToDeposit = 10; // Or any other non-zero amount

    // Use try-catch to handle potential errors and ensure a successful transaction
    try {
      await depositETH(user1, amountToDeposit);
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

  it("user should be able to deposit ETH to the protocol and the ETH pool in the protocol increases", async function () {
    // Connect to user1 and deposit 10 ETH to the protocol
    const initialEthInPool = await lendingProtocol.getTotalEthLocked(); // Get initial ETH in pool

    const depositAmount = 10;
    await depositETH(user1, depositAmount); // Call the depositETH function with user1 and deposit amount

    const ethInPool = await lendingProtocol.getTotalEthLocked();

    // Convert ethInPool to BigInt
    const initialEthInPoolBigInt = BigInt(initialEthInPool);
    const ethInPoolBigInt = BigInt(ethInPool);

    // Check if the ETH in pool has increased by the deposit amount
    expect(ethInPoolBigInt).to.equal(
      initialEthInPoolBigInt + BigInt(depositAmount)
    );
  });

  it("gives the user correct amount of LP tokens after depositing ETH", async function () {
    // Connect to user1 and deposit 10 ETH to the protocol
    //remember we defined the "token" as the LPToken contract
    const initialLPBalance = await token.balanceOf(user1.address);
    await depositETH(user1, 1);

    //wait for one block
    await ethers.provider.send("evm_mine", []);

    const finalLPBalance = await token.balanceOf(user1.address);

    //1 ETH is 3000 LPTokens in our scenario
    const expectedLPBalance = 2400;

    expect(finalLPBalance).to.equal(
      initialLPBalance + BigInt(expectedLPBalance)
    );
  });

  it("changes the total liquidity after user deposits ETH", async function () {
    // Connect to user1 and deposit 1 ETH to the protocol
    const initialTotalLiquidity = await lendingProtocol.getTotalLiquidity();
    await depositETH(user1, 1);
    //wait for one block
    await ethers.provider.send("evm_mine", []);
    //considering 1 eth is 3000 LPT
    const finalTotalLiquidity = await lendingProtocol.getTotalLiquidity();
    expect(finalTotalLiquidity).to.equal(initialTotalLiquidity - BigInt(2400));
  });

  it("updates user/borrower info", async function () {
    // Connect to user1 and deposit 1 ETH to the protocol
    await depositETH(user1, 1);
    //wait for one block
    await ethers.provider.send("evm_mine", []);
    //considering 1 eth is 3000 LPT and the collateral ratio is 80
    const borrower = await lendingProtocol.getBorrowerInfo(user1.address);
    expect(borrower.ehtDeposited).to.equal(1);
    expect(borrower.collateralValue).to.equal(2400);
  });

  //  these brackets belong to describe statement
});

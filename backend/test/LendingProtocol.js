const { expect } = require("chai");
const { formatEther } = require("ethers");
const { ethers } = require("hardhat");

let lpTokenAddress;

describe("LendingProtocol", function () {
  let lendingProtocol;
  const initialInterestRate = 5; // Example interest rate
  let lpToken;
  let owner, user1, user2;

  beforeEach(async function () {
    // Get signers
    [owner, user1, user2] = await ethers.getSigners();

    // Deploy lpToken contract first
    const LPToken = await ethers.getContractFactory("LPToken");
    lpToken = await LPToken.deploy();
    console.log("LPToken address:", await lpToken.getAddress());
    lpTokenAddress = await lpToken.getAddress();

    //get how much token the deployer has
    // lpToken = await ethers.getContractAt("LPToken", lpTokenAddress);
    const balance = await lpToken.balanceOf(owner.address);
    //parse the balance
    const parsedBalance = ethers.formatEther(balance);
    console.log("LPToken balance:", parsedBalance);

    // Deploy lendingProtocol contract
    const LendingProtocol = await ethers.getContractFactory("LendingProtocol");
    lendingProtocol = await LendingProtocol.deploy(
      lpTokenAddress,
      initialInterestRate
    );
    console.log("LendingProtocol address:", await lendingProtocol.getAddress());
    return lendingProtocol, lpToken;
  });

  it("should deploy the contract with the correct initial state values", async function () {
    expect(await lendingProtocol.lpToken()).to.equal(lpTokenAddress);
    expect(await lendingProtocol.interestRate()).to.equal(initialInterestRate);
  });

  it("should deposit lp tokens to the contract", async function () {
    const depositAmount = ethers.parseEther("20");
    //allow the deployer to deposit
    await lpToken
      .connect(owner)
      .approve(await lendingProtocol.getAddress(), depositAmount);

    await lendingProtocol.connect(owner).depositLPTokens(depositAmount);

    //check lendingprotocol balance
    const balance = await lpToken.balanceOf(await lendingProtocol.getAddress());
    const parsedBalance = ethers.formatEther(balance);
    expect(parsedBalance).to.equal("20.0");
  });

  it("user should be able to deposit ETH", async function () {
    const depositAmount = ethers.parseEther("20");
    //allow the deployer to deposit
    await lendingProtocol.connect(user1).depositETH(depositAmount);

    // Check the ethLocked mapping of user1
    const user1EthLocked = await lendingProtocol.ethLocked(user1.address);
    const parsedUser1EthLocked = ethers.formatEther(user1EthLocked);
    expect(parsedUser1EthLocked).to.equal("20.0");
  });

  it("user should be able to borrow LPTokens", async function () {
    const depositAmount = ethers.parseEther("20");
    //allow the deployer to deposit
    await lpToken
      .connect(owner)
      .approve(await lendingProtocol.getAddress(), depositAmount);

    await lendingProtocol.connect(owner).depositLPTokens(depositAmount);

    // user should deposit ETH
    const depositAmountEth = ethers.parseEther("10");
    await lendingProtocol.connect(user1).depositETH(depositAmountEth);
    await ethers.provider.send("evm_mine", []);

    const borrowAmount = ethers.parseEther("2");
    //allow the deployer to deposit
    await lendingProtocol.connect(user1).borrowLPTokens(borrowAmount);

    // Wait for one block
    await ethers.provider.send("evm_mine", []);

    console.log(
      formatEther(
        await lendingProtocol.getIndividualLPTokenBalance(user1.address)
      ),
      "user lptoken balance"
    );

    console.log(
      formatEther(await lendingProtocol.getIndividualEthLocked(user1.address))
    );

    // Get the user's LP token balance
    const userLpTokenBalance =
      await lendingProtocol.getIndividualLPTokenBalance(user1.address);

    // Get the user's ETH locked balance
    const userEthLockedBalance = await lendingProtocol.getIndividualEthLocked(
      user1.address
    );

    // Expect the user's LP token balance to be 8
    expect(userLpTokenBalance).to.equal(ethers.parseEther("20"));

    // Expect the user's ETH locked balance to be 8
    expect(userEthLockedBalance).to.equal(ethers.parseEther("8"));
  });
});

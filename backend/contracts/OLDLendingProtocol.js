const { expect } = require("chai");
const { ethers } = require("hardhat");

let lpTokenAddress;

describe("OLDLendingProtocol", function () {
  let lendingProtocol;
  const initialInterestRate = 5; // Example interest rate
  const initialCollateralizationRatio = 150; // Example collateralization ratio
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
      initialInterestRate,
      initialCollateralizationRatio
    );
    console.log("LendingProtocol address:", await lendingProtocol.getAddress());
    return lendingProtocol, lpToken;
  });

  it("should deploy the contract with the correct initial state values", async function () {
    expect(await lendingProtocol.lpToken()).to.equal(lpTokenAddress);
    expect(await lendingProtocol.interestRate()).to.equal(initialInterestRate);
    expect(await lendingProtocol.collateralizationRatio()).to.equal(
      initialCollateralizationRatio
    );
  });

  it("users should be able to deposit ether into the contract", async function () {
    // Define the amount of ETH to deposit
    const depositAmount = ethers.parseEther("1.0");

    // Send a transaction to deposit ETH
    await lendingProtocol.connect(user1).depositETH(depositAmount);

    // Check the updated ethBalances mapping for the user
    const userBalance = await lendingProtocol.ethBalances(user1.address);

    // Verify that the balance has been updated correctly
    expect(userBalance).to.equal(depositAmount);
  });

  it("the deployer should have lp tokens", async function () {
    const balance = await lpToken.balanceOf(owner.address);
    const parsedBalance = ethers.formatEther(balance);
    expect(parsedBalance).to.equal("1000.0");
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

  it("user should be able to borrow LPTokens", async function () {
    //first deposit ether as user1
    // Define the amount of ETH to deposit
    const depositAmount = ethers.parseEther("10.0");

    // Send a transaction to deposit ETH
    await lendingProtocol.connect(user1).depositETH(depositAmount);

    const borrowAmount = ethers.parseEther("1");
    await lendingProtocol.connect(user1).borrowLP(borrowAmount);

    const balance = await lendingProtocol.lpTokenBalances(user1.address);
    const parsedBalance = ethers.formatEther(balance);
    expect(parsedBalance).to.equal("1.0");

    //check interest rate via ethbalances mapping
    //console.log eth balances of user1
    const userBalance = await lendingProtocol.ethBalances(user1.address);
    const parsedUserBalance = ethers.formatEther(userBalance);
    console.log("user1 eth balance:", parsedUserBalance);
  });

  it("user should be able to repay LPTokens", async function () {
    //first deposit ether as user1
    // Define the amount of ETH to deposit
    const depositAmount = ethers.parseEther("10.0");

    // Send a transaction to deposit ETH
    await lendingProtocol.connect(user1).depositETH(depositAmount);

    const borrowAmount = ethers.parseEther("1");
    await lendingProtocol.connect(user1).borrowLP(borrowAmount);

    const repayAmount = ethers.parseEther("0.2");
    await lendingProtocol.connect(user1).repayLP(repayAmount);

    const balance = await lendingProtocol.lpTokenBalances(user1.address);
    const parsedBalance = ethers.formatEther(balance);

    expect(parsedBalance).to.equal("0.8");

    //check interest rate via ethbalances mapping
    //console.log eth balances of user1
    const userBalance = await lendingProtocol.ethBalances(user1.address);
    const parsedUserBalance = ethers.formatEther(userBalance);
    console.log("user1 eth balance after repay LPTokens:", parsedUserBalance);
  });

  it("user should be able to withdraw the ETH plus interest from the contract", async function () {
    //first deposit ether as user1
    // Define the amount of ETH to deposit
    const depositAmount = ethers.parseEther("10.0");

    // Send a transaction to deposit ETH for both users
    await lendingProtocol.connect(user1).depositETH(depositAmount);
    await lendingProtocol.connect(user2).depositETH(depositAmount);

    const borrowAmount = ethers.parseEther("1");
    await lendingProtocol.connect(user1).borrowLP(borrowAmount);

    const repayAmount = ethers.parseEther("0.5");
    await lendingProtocol.connect(user1).repayLP(repayAmount);

    //check the user1 balance
    const user1Balance = await lendingProtocol.ethBalances(user1.address);
    const parsedUser1Balance = ethers.formatEther(user1Balance);
    console.log("user1 eth balance:", parsedUser1Balance);

    //check user2 eth balance
    const user2Balance = await lendingProtocol.ethBalances(user2.address);
    const parsedUser2Balance = ethers.formatEther(user2Balance);
    console.log("user2 eth balance:", parsedUser2Balance);
  });
});

const { expect } = require("chai");
const { ethers } = require("hardhat");

let lpTokenAddress;

describe("LendingProtocol", function () {
  let lendingProtocol;
  const initialInterestRate = 5; // Example interest rate
  const initialCollateralizationRatio = 150; // Example collateralization ratio
  let lpToken;

  beforeEach(async function () {
    // Deploy lpToken contract first
    const LPToken = await ethers.getContractFactory("LPToken");
    lpToken = await LPToken.deploy();
    console.log("LPToken address:", await lpToken.getAddress());
    lpTokenAddress = await lpToken.getAddress();

    // Deploy lendingProtocol contract
    const LendingProtocol = await ethers.getContractFactory("LendingProtocol");
    lendingProtocol = await LendingProtocol.deploy(
      lpTokenAddress,
      initialInterestRate,
      initialCollateralizationRatio
    );
    console.log("LendingProtocol address:", await lendingProtocol.getAddress());

    // Get signers
    [owner] = await ethers.getSigners();
  });

  it("should deploy the contract with the correct initial state values", async function () {
    expect(await lendingProtocol.lpToken()).to.equal(lpTokenAddress);
    expect(await lendingProtocol.interestRate()).to.equal(initialInterestRate);
    expect(await lendingProtocol.collateralizationRatio()).to.equal(
      initialCollateralizationRatio
    );
  });
});

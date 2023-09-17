const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

let token, owner;

beforeEach(async function () {
  // Deploy contract
  const Token = await ethers.getContractFactory("LPToken");
  token = await Token.deploy();
  // console.log("Token address:", await token.getAddress());

  // Get signers
  [owner] = await ethers.getSigners();
});

it("Has correct name and symbol", async function () {
  expect(await token.name()).to.equal("LPToken");
  expect(await token.symbol()).to.equal("LPT");
});

it("Mints initial supply to owner", async function () {
  const supply = await token.totalSupply();
  const ownerBal = await token.balanceOf(owner.address);
  expect(supply).to.equal(ownerBal);
});

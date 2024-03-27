// const { expect } = require("chai");
// const { formatEther } = require("ethers");
// const { ethers } = require("hardhat");

// let lendingProtocolAddress;

// describe("LendingProtocol", function () {
//   let lendingProtocol;
//   let lpToken;
//   let user1, user2;

//   beforeEach(async function () {
//     // Get signers
//     [user1, user2] = await ethers.getSigners();

//     // Deploy LendingProtocol contract first
//     //because the LPToken contract will need the LendingProtocol contract address to send some initial tokens to it
//     const LendingProtocol = await ethers.getContractFactory("LendingProtocol");
//     lendingProtocol = await LendingProtocol.deploy();
//     console.log("LendingProtocol address:", await lendingProtocol.getAddress());
//     lendingProtocolAddress = await lendingProtocol.getAddress();
//   });
// });

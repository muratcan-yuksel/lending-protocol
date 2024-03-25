// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import "./LPToken.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract LendingProtocol is ReentrancyGuard {
    //variables
    //put lptoken contract into a variable
    LPToken public lpToken;
    uint256 public totalLiquidity;
    uint256 public totalEthLocked;
    uint256 public collateralizationRatio;
    uint8 public liquidationThreshold = 80;
    uint8 public interestRate; //annual interest rate (in percentage)
    //oracle address
    address public oracle;

    //mappings
}

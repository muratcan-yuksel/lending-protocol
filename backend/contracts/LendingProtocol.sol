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

    mapping(address => Deposit) public deposits;

    //structs
    //ETH deposits
    struct Deposit {
        uint256 amount;
        uint256 collateralValue; //USD value of deposited ETH at the time of deposit.
        uint256 depositTime;
    }

    //functions

    function depositETH(uint256 _amount) public payable {
        require(_amount > 0, "Amount must be greater than 0");

        // Fetch ETH price from Chainlink oracle
        // Calculate USD value of deposited ETH
    }
}

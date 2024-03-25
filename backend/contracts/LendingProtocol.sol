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
    //mock ETH price
    uint16 public ethPrice = 3000;
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

        // Normally we'd fetch ETH price from Chainlink oracle
        //But here we'll use a mock value

        // Calculate USD value of deposited ETH
        uint256 depositValueUSD = _amount * ethPrice;

        //1 LPT= 1 USD
        //1 ETH = 3000 USD
        uint256 lptAmount = depositValueUSD;

        // Mint LP tokens
        //here we're calling our own custom "mint" function in LPToken.sol contract
        //which states that only the owner, that is, this very contract, can mint LPTokens
        lpToken.mint(msg.sender, lptAmount);
    }
}

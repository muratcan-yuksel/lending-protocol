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
    uint256 public totalLiquidity; //lpToken.balanceOf(address(this));
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

    constructor(address _lpToken) {
        lpToken = LPToken(_lpToken); // Set the LPToken address during deployment
        totalLiquidity = 0; // Assuming zero initial liquidity
    }

    //functions

    //view functions
    function getTotalLiquidity() public view returns (uint256) {
        // Recalculate totalLiquidity every time this function is called
        return lpToken.balanceOf(address(this));
    }

    function depositETH(uint256 _amount) public payable {
        require(_amount > 0, "Amount must be greater than 0");

        // Normally we'd fetch ETH price from Chainlink oracle
        //But here we'll use a mock value

        //

        // Calculate USD value of deposited ETH
        //Question: Does the amount comes in ETH or in wei? What's the conversion?
        uint256 ethAmount = _amount / 1e18; // Divide by 1e18 (10^18) to convert wei to ETH
        uint256 depositValueUSD = ethAmount * ethPrice;

        //1 LPT= 1 USD
        //1 ETH = 3000 USD
        uint256 lptAmount = depositValueUSD;

        // send the user LPTokens using ERC20's transfer function
        lpToken.transfer(msg.sender, lptAmount);

        //update user's deposit information
        deposits[msg.sender].amount += _amount;
        deposits[msg.sender].collateralValue += depositValueUSD;
        deposits[msg.sender].depositTime = block.timestamp;

        //update totalLiquidity
        totalLiquidity -= lptAmount;
        //update totalEthLocked
        totalEthLocked += _amount;
    }
}

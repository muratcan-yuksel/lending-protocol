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
    // uint256 public totalEthLocked; //unncessary in our case since we can query the contract balance directly
    uint256 public collateralRatio;
    uint8 public liquidationThreshold = 80;
    uint8 public interestRate; //annual interest rate (in percentage)
    //mock ETH price
    uint16 public ethPrice = 3000;
    //oracle address
    address public oracle;

    //mappings

    //borrowers give ETH and borrow LPT
    //lenders lend LPT and earn interest

    mapping(address => BorrowerInfo) public borrowers;

    //structs
    //ETH deposits
    struct BorrowerInfo {
        uint256 ehtDeposited;
        uint256 collateralValue; //USD value of deposited ETH at the time of deposit.
        uint256 depositTime;
    }

    constructor(address _lpToken) {
        lpToken = LPToken(_lpToken); // Set the LPToken address during deployment
        totalLiquidity = 0; // Assuming zero initial liquidity
        collateralRatio = 80;
    }

    //functions

    //view functions
    function getTotalLiquidity() public view returns (uint256) {
        // Recalculate totalLiquidity every time this function is called
        return lpToken.balanceOf(address(this));
    }

    function getTotalEthLocked() public view returns (uint256) {
        // Recalculate totalEthLocked every time this function is called
        uint256 ethBalance = address(this).balance;
        console.log("ETH balance of the contract:", ethBalance);
        return ethBalance;
    }

    function getBorrowerInfo(
        address _user
    ) public view returns (BorrowerInfo memory) {
        return borrowers[_user];
    }

    //helper functions for depositETH function starts

    function calculateLPTokensToUser(
        uint256 _ethAmount
    ) internal view returns (uint256) {
        // Normally we'd fetch ETH price from Chainlink oracle
        //But here we'll use a mock value

        // Calculate USD value of deposited ETH (ETH price being 3k)
        // console.log("ETH amount:", _ethAmount);
        uint256 depositValueUSD = _ethAmount * ethPrice;
        //only 80% of the deposited ETH can be used by the user
        console.log("Deposit value in USD:", depositValueUSD);
        //lptAmount returns 0 if I don't use safemath
        uint256 lptAmount = (depositValueUSD * collateralRatio) / 100;
        console.log("LPTokens to be minted:", lptAmount);
        console.log("collateral ratio:", collateralRatio);
        return lptAmount;
    }

    function transferLPTtoUser(
        address _user,
        uint256 _ethAmountDeposited
    ) internal {
        //1 LPT= 1 USD
        //1 ETH = 3000 USD
        uint256 lptAmount = (calculateLPTokensToUser(_ethAmountDeposited));
        console.log("LPToken amount to be minted:", lptAmount);

        // send the user LPTokens using ERC20's transfer function
        lpToken.transfer(_user, lptAmount);
    }

    function updateBorrowerInfo(address _user, uint256 _amount) internal {
        borrowers[_user].ehtDeposited += _amount;
        borrowers[_user].collateralValue += (calculateLPTokensToUser(_amount));
        borrowers[_user].depositTime = block.timestamp;
    }

    //helper functions for depositETH function ends

    function depositETH(uint256 _amount) public payable {
        require(_amount > 0, "Amount must be greater than 0");
        // console.log("deposited amount", _amount);

        //call function to transfer LPTokens to user
        transferLPTtoUser(msg.sender, _amount);

        //call function to update user's deposit information
        updateBorrowerInfo(msg.sender, _amount);
    }

    function depositLPT() public {}

    fallback() external payable {
        depositETH(msg.value);
    }

    receive() external payable {
        depositETH(msg.value);
    }
}

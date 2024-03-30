// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import "./LPToken.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
//import safemath
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract LendingProtocol is ReentrancyGuard {
    using SafeMath for uint256; //use safemath for all uin256 variables
    //variables

    //put lptoken contract into a variable
    LPToken public lpToken;
    uint256 public totalLiquidity; //lpToken.balanceOf(address(this));
    // uint256 public totalEthLocked; //unncessary in our case since we can query the contract balance directly
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

    function getTotalEthLocked() public view returns (uint256) {
        // Recalculate totalEthLocked every time this function is called
        uint256 ethBalance = address(this).balance;
        console.log("ETH balance of the contract:", ethBalance);
        return ethBalance;
    }

    //helper functions for depositETH function starts

    function convertETHtoLPT(
        uint256 _ethAmount
    ) internal view returns (uint256) {
        // Normally we'd fetch ETH price from Chainlink oracle
        //But here we'll use a mock value

        // Calculate USD value of deposited ETH (ETH price being 3k)
        // console.log("ETH amount:", _ethAmount);
        uint256 depositValueUSD = _ethAmount * ethPrice;
        return depositValueUSD;
    }

    function transferLPTtoUser(
        address _user,
        uint256 _ethAmountDeposited
    ) internal {
        //1 LPT= 1 USD
        //1 ETH = 3000 USD
        uint256 lptAmount = (convertETHtoLPT(_ethAmountDeposited));
        console.log("LPToken amount to be minted:", lptAmount);

        // send the user LPTokens using ERC20's transfer function
        lpToken.transfer(_user, lptAmount);
    }

    function updateUserInfo(address _user, uint256 _amount) internal {
        deposits[_user].amount += _amount;
        deposits[_user].collateralValue += (convertETHtoLPT(_amount));
        deposits[_user].depositTime = block.timestamp;
    }

    //helper functions for depositETH function ends

    function depositETH(uint256 _amount) public payable {
        require(_amount > 0, "Amount must be greater than 0");
        // console.log("deposited amount", _amount);

        //call function to transfer LPTokens to user
        transferLPTtoUser(msg.sender, _amount);

        //call function to update user's deposit information
        updateUserInfo(msg.sender, _amount);
    }

    function deposit() public payable {}

    fallback() external payable {
        depositETH(msg.value);
    }

    receive() external payable {
        depositETH(msg.value);
    }
}

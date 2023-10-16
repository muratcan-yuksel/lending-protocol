// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import "./LPToken.sol";

contract LendingProtocol {
    LPToken public lpToken;
    uint256 public totalLpTokens;
    uint256 public totalEthLocked;
    address public owner;
    uint256 public interestRate; //annual interest rate (in percentage)

    address[] public lenders;
    address[] public borrowers;
    mapping(address => uint256) public lendersInterestBalance;
    mapping(address => uint256) public ethLocked;
    mapping(address => uint256) public lpTokenBalances;

    uint256 public totalInterest;

    constructor(address _lpTokenAddress, uint256 _interestRate) {
        lpToken = LPToken(_lpTokenAddress);
        owner = msg.sender;
        interestRate = _interestRate;
    }

    function getTotalLPTokens() public view returns (uint256) {
        return lpToken.totalSupply();
    }

    function getTotalEthLocked() public view returns (uint256) {
        return totalEthLocked;
    }

    function getLPTokenBalance(address _lender) public view returns (uint256) {
        return lpTokenBalances[_lender];
    }

    function getLenders() public view returns (address[] memory) {
        return lenders;
    }

    function getBorrowers() public view returns (address[] memory) {
        return borrowers;
    }

    function getIndividualLPTokenBalance(
        address _lender
    ) public view returns (uint256) {
        return lpToken.balanceOf(_lender);
    }

    function getIndividualEthLocked(
        address _lender
    ) public view returns (uint256) {
        return ethLocked[_lender];
    }

    function depositLPTokens(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(
            lpToken.transferFrom(msg.sender, address(this), _amount),
            "Transaction failed"
        );
        lpTokenBalances[msg.sender] += _amount;
        lenders.push(msg.sender);
        totalLpTokens += _amount;
        //console.log(lpToken.balanceOf(address(this)));
    }

    function depositETH(uint256 _amount) public payable {
        require(_amount > 0, "Amount must be greater than 0");
        ethLocked[msg.sender] += _amount;
        totalEthLocked += _amount;
        borrowers.push(msg.sender);
    }

    function borrowLPTokens(uint256 _amount) external payable {
        require(_amount > 0, "Amount must be greater than 0");

        console.log(lpToken.balanceOf(address(this)));

        // Check if the contract has enough tokens to lend
        require(
            lpToken.balanceOf(address(this)) >= _amount * 10,
            "Not enough tokens in the contract"
        );

        //check if the borrower has enough ETH deposited to borrow
        require(
            ethLocked[msg.sender] >= _amount / 10,
            "Not enough ETH deposited"
        );

        // Check that the totalEthLocked variable is not negative before decrementing it
        require(
            totalEthLocked >= _amount,
            "Not enough ETH locked in the contract"
        );

        // Update the totalEthLocked balance
        totalEthLocked -= _amount;

        // Update the borrower's ETH locked balance
        ethLocked[msg.sender] -= _amount;

        // Transfer LP tokens to the borrower (msg.sender) from the contract
        require(
            lpToken.transfer(msg.sender, _amount * 10),
            "Token transfer failed"
        );

        // Update balances
        lpTokenBalances[msg.sender] += _amount * 10;
        borrowers.push(msg.sender);
        // ethLocked[msg.sender] -= _amount;
        // totalEthLocked -= msg.value;
    }

    fallback() external payable {
        depositETH(msg.value);
    }

    receive() external payable {
        depositETH(msg.value);
    }
}

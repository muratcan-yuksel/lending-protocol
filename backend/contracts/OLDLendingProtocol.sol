// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import "./LPToken.sol";

contract OLDLendingProtocol {
    LPToken public lpToken;
    address public owner;
    uint256 public interestRate; //annual interest rate (in percentage)
    uint256 public collateralizationRatio; // Collateralization ratio (e.g., 150%)

    mapping(address => uint256) public lpTokenBalances;
    mapping(address => uint256) public ethBalances;
    address[] public lpTokenDepositors;

    constructor(
        address _lpTokenAddress,
        uint256 _interestRate,
        uint256 _collateralizationRatio
    ) {
        lpToken = LPToken(_lpTokenAddress);
        owner = msg.sender;
        interestRate = _interestRate;
        collateralizationRatio = _collateralizationRatio;
    }

    function distributeInterest(uint256 _interestEarned) internal {
        // Distribute interest proportionally to LP token depositors
        uint256 totalLPBalances;
        for (uint256 i = 0; i < lpTokenDepositors.length; i++) {
            totalLPBalances += lpTokenBalances[lpTokenDepositors[i]];
        }

        if (totalLPBalances > 0) {
            for (uint256 i = 0; i < lpTokenDepositors.length; i++) {
                uint256 share = (lpTokenBalances[lpTokenDepositors[i]] *
                    _interestEarned) / totalLPBalances;
                ethBalances[lpTokenDepositors[i]] += share;
            }
        }
    }

    // Function to allow users to deposit ETH
    function depositETH(uint256 _amount) external payable {
        require(_amount > 0, "Amount must be greater than 0");
        ethBalances[msg.sender] += _amount;
    }

    function depositLPTokens(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(
            lpToken.transferFrom(msg.sender, address(this), _amount),
            "Transaction failed"
        );
        lpTokenBalances[msg.sender] += _amount;
        //add msg.sender to lpTokenDepositors
        lpTokenDepositors.push(msg.sender);
    }

    function borrowLP(uint256 _amount) external payable {
        require(_amount > 0, "Amount must be greater than 0");
        uint256 maxBorrow = (ethBalances[msg.sender] * collateralizationRatio) /
            100;
        require(
            _amount <= maxBorrow,
            "Amount exceeds the maximum borrow limit"
        );

        // Calculate and record interest earned by LP token depositors
        uint256 interestEarned = (_amount * interestRate) / 100;
        distributeInterest(interestEarned);

        // Update balances
        lpTokenBalances[msg.sender] += _amount;
        ethBalances[msg.sender] -= msg.value;
    }

    function repayLP(uint256 _amount) external payable {
        require(_amount > 0, "Amount must be greater than zero");
        require(
            lpTokenBalances[msg.sender] >= _amount,
            "Insufficient LP token balance"
        );

        // Calculate and record interest earned by LP token depositors
        uint256 interestEarned = (_amount * interestRate) / 100;
        distributeInterest(interestEarned);

        // Update balances
        lpTokenBalances[msg.sender] -= _amount;
        ethBalances[msg.sender] += interestEarned;
    }

    function withdrawETHBalance() external {
        uint256 ethBalance = ethBalances[msg.sender];

        require(ethBalance > 0, "No ETH balance to withdraw");

        // Set the user's ETH balance to zero to prevent reentrancy
        ethBalances[msg.sender] = 0;

        // Transfer the ETH balance to the user
        payable(msg.sender).transfer(ethBalance);
    }

    fallback() external payable {}

    receive() external payable {}
}

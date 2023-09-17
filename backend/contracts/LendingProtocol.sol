// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import "./LPToken.sol";

contract LendingProtocol {
    LPToken public lpToken;
    address public owner;
    uint256 public interestRate; //annual interest rate (in percentage)
    uint256 public collateralizationRatio; // Collateralization ratio (e.g., 150%)

    mapping(address => uint256) public lpTokenBalances;
    mapping(address => uint256) public ethBalances;

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
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//This contract will be deployed after lendingprotocol.sol//

contract LPToken is ERC20, Ownable {
    // constructor() ERC20("LPToken", "LPT") {
    //     _mint(msg.sender, 1000000 * 10 ** 18);
    // }
    address public lendingProtocol; // Address of the lending protocol contract

    constructor(
        string memory name,
        string memory symbol,
        address _lendingProtocol
    ) ERC20(name, symbol) {
        lendingProtocol = _lendingProtocol;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        //while the above "mint" function is named by us,
        //this "_mint" function comes from openzeppelin's ERC20
        //the idea with this function is to let the mint function be called as many times but only by the owner
        //which will translate into people depositing eth and the lendingprotocol.sol contract minting lp tokens FOR THEM
        //so the lendingprotocol contract will be the owner
        _mint(to, amount);
    }
}

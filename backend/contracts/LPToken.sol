// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//This contract will be deployed after lendingprotocol.sol//

contract LPToken is ERC20, Ownable {
    // address public lendingProtocol; // Address of the lending protocol contract

    constructor() ERC20("LPToken", "LPT") {
        _mint(msg.sender, 1000000 * 10 ** 18);
        // _mint(lendingProtocol, 250000 * 10 ** 18);
    }
}
// pragma solidity ^0.8.9;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";

// //This contract will be deployed after lendingprotocol.sol//

// contract LPToken is ERC20, Ownable {
//     address public lendingProtocol; // Address of the lending protocol contract

//     modifier onlyOwnerOrProtocol() {
//         require(
//             msg.sender == owner() || msg.sender == lendingProtocol,
//             "Not authorized"
//         );
//         _;
//     }

//     constructor(address _lendingProtocol) ERC20("LPToken", "LPT") {
//         lendingProtocol = _lendingProtocol;
//         _mint(msg.sender, 1000000 * 10 ** 18);
//         _mint(lendingProtocol, 2500000 * 10 ** 18);
//     }

//     function mint(
//         address account,
//         uint256 amount
//     ) external onlyOwnerOrProtocol {
//         _mint(account, amount);
//     }
// }

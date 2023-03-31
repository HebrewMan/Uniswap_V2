// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract YOHO is ERC20 {
    constructor() ERC20("MyToken YOHO", "YOHO") {
        _mint(msg.sender, 100000000 * 10 ** decimals());
    }
}
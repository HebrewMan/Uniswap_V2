// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDT is ERC20 {
    constructor() ERC20("MyToken USDT", "USDT") {
        _mint(msg.sender, 100000000 * 10 ** decimals());
    }
}
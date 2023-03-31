// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WYOHO is ERC20, Ownable {

    mapping(address => bool) public whiteList;

    constructor() ERC20("MyToken WYOHO", "WYOHO") {
        _mint(msg.sender, 100000000 * 10 ** decimals());
    }


    modifier onlyWhiteList(){
        require(whiteList[msg.sender],"WYOHO: Only WhiteList.");
        _;
    }

    function setWhiteList(address _addr)external onlyOwner {
        whiteList[_addr] = true;
    }
 
    function transfer(address to, uint256 amount) public onlyWhiteList virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

}
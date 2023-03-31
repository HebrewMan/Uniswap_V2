
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Donation is Ownable {
    //USDT 
    IERC20 public ERC20 = IERC20(0x4B6b9F3695205C8468ddf9AB4025ec2A09bDfF1a);// 0x5179897e068B85C21526666AB6d44e1cb2Dc7Ed9

    uint public ratio = 1000000;
    uint public max = 2000 * 10 **18;

    address public financial;
    address public admin;

    uint public startTime = 1679294537;
    uint public endTime = 1679630400;//1711180800 2024

    mapping(address => uint) public quota;
    
    event DonationEvent(address addr, uint amount);

    modifier onlyAdmin(){
        require(msg.sender == admin,"Donation: Only admin.");
        _;
    }

    constructor(address _financial){
        financial = _financial;
    }

    function donation(uint amount)external{
        require(endTime > block.timestamp,"Donation: Have not started.");
        require(startTime <= block.timestamp,"Donation: Donation time has ended.");
        require(amount + quota[msg.sender]<= max,"Donation: No more donations.");
        ERC20.transferFrom(msg.sender,financial,amount);
        quota[msg.sender]+=amount;//10*10**18
        emit DonationEvent(msg.sender,amount);
    }
    

    function getSwapYohoAmount(address _addr)external view returns(uint){
        return quota[_addr] * ratio;
    }

    function setERC20(IERC20 _ERC20)external onlyOwner {
        ERC20 = _ERC20;
    }

    function setRatio(uint _ratio)external onlyOwner {
        ratio = _ratio;
    }

    function setMax(uint _max)external onlyOwner {
        max = _max;
    }

    function setEndTime(uint _time)external onlyOwner {
        endTime = _time;
    }

    function setAdmin(address _admin)external onlyOwner {
        admin = _admin;
    }

    function subQuateBySwap(address _addr,uint _amount)public onlyAdmin{
        quota[_addr] -= _amount;
    }


}


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

interface IDonation{
    function getSwapYohoAmount(address addr)external view returns(uint);
    function subQuateBySwap(address addr,uint amount)external returns(uint);
}

contract WYOHO is ERC20,Ownable{

    uint max = 100000000 * 10 ** 18;

    IDonation public Donation = IDonation(0x4B6b9F3695205C8468ddf9AB4025ec2A09bDfF1a);

    address public uniswapRouter = 0xE8963DC0599e063a1dC42051d6282D3Fb873EA92;//test
    address public usdtToken = 0x4B6b9F3695205C8468ddf9AB4025ec2A09bDfF1a;
    address public yohoToken;

    constructor( address _yohoToken)  ERC20("MyToken", "WYOHO") {
        _mint(msg.sender, 100000000 * 10 ** decimals());
        yohoToken = _yohoToken;
    }

    function _getPathForUSDTtoWYOHO() private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = usdtToken;
        path[1] = address(this);
        return path;
    }

    function _getPathForWYOHOtoUSDT() private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdtToken;
        return path;
    }

    function setMax(uint _max)external onlyOwner {
        max = _max;
    }

    function setDonation(IDonation _donation)external onlyOwner {
        Donation = _donation;
    }

    //path[wyoho,usdt]
    function yohoSwapBuy(address[] calldata path,uint _amount)public {
        //usdt to address(this)
        TransferHelper.safeTransferFrom(usdtToken,msg.sender, address(this), _amount);
        //WYOHO of usdt approve to uniswap router
        TransferHelper.safeApprove(usdtToken,uniswapRouter,_amount);
        //swap USDT to router WYOHO to here
        uint256[] memory amounts = _swap(path,_amount,address(this));
        //1:1 WYHO => YOHO to user(caller)
        TransferHelper.safeTransfer(yohoToken,msg.sender, amounts[1]);
    }

    //授权yoho 和 WYOHO
    //path[usdt,wyoho]
    function yohoSwapSell(address[] calldata path,uint _amount) public{
        //user approve yoho to address(this)
        uint userMax = Donation.getSwapYohoAmount(msg.sender);

        require(_amount <= userMax,"WYOHO: The maximum single amount is 100,000,000."); //max check
        require(_amount <= max,"WYOHO: The maximum single amount is 100,000,000.");
       
        TransferHelper.safeTransferFrom(yohoToken,msg.sender, address(this), _amount); //1:1 yoho => wyoho
        

        _swap(path,_amount,msg.sender);//swap USDT to router WYOHO to here
        
        Donation.subQuateBySwap(msg.sender,_amount);//sub quota
    }

     function _swap( address[] calldata path,uint256 amountIn,address to) private returns(uint256[] memory amounts){
        //address(this) approve origin token to router
        TransferHelper.safeApprove(path[0],uniswapRouter,amountIn);
        amounts = IUniswapV2Router02(uniswapRouter).swapExactTokensForTokens(
            amountIn,
            0,
            path,
            to,
            block.timestamp
        );
    }

}
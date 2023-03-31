// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

interface IDonation{
    function getSwapYohoAmount(address addr)external view returns(uint);
    function subQuateBySwap(address addr,uint amount)external;
}

contract Swap is Ownable{

    uint public max = 5000 ether;
    //==========bsc test===========
    // usdt 0xd59874d28Cedf1B30DA32165505D7a4dA6701247
    // yoho 0x534BDbf072F26b46664F5FCC64b4A60FFd9AAfFf
    // wyoho 0x1Dc68b16062FB9b0Cac4bB9F11076e8C8c61b2Fe
    // donation 0x09B2731870B347446a3aBC50f19011Bf96F357dc
    // uniswapV2Router 0xCDe540d7eAFE93aC5fE6233Bee57E1270D3E330F

    //==========aitd test===========
    // usdt 0x4B6b9F3695205C8468ddf9AB4025ec2A09bDfF1a
    // yoho 0x2fC0eBefDD68134809Ee359BBC8A5576c3788120
    // wyoho 0x7176A3c502942AA6Cdb8CD12005C1733a8141d69
    // donation 0x5003AbDcF10A5332a4093B0753a2E874B9C7d48c
    // uniswapV2Router 0xE8963DC0599e063a1dC42051d6282D3Fb873EA92
    IUniswapV2Router02 public Router = IUniswapV2Router02(0xE8963DC0599e063a1dC42051d6282D3Fb873EA92);
    IDonation public Donation = IDonation(0x5003AbDcF10A5332a4093B0753a2E874B9C7d48c);

    address public yohoToken = 0x2fC0eBefDD68134809Ee359BBC8A5576c3788120;
    address public wyohoToken = 0x7176A3c502942AA6Cdb8CD12005C1733a8141d69;

    modifier checkLength(address[] calldata _path){
        require(_path.length==2,"Swap:Path length fail.");
        _;
    }

    function setMax(uint _max)external onlyOwner {
        max = _max;
    }

    function setDonation(IDonation _donation)external onlyOwner {
        Donation = _donation;
    }


     /**
     * @dev need enough wyoho token
     * user's yoho\usdt need approve to this contract for transferFrom 
     * contract wyoho need approve to router
     * usdt transfer to address(this)
     * this contract transfer wyoho and usdt to uniswap yoho => wyoho
     * uniswap transfer lp (wyoho/usdt) to user.
     */

    function addLiquidity(address[] calldata _path,uint256 _amount0, uint256 _amount1) external checkLength(_path){

        IERC20(_path[0]).transferFrom(msg.sender, address(this), _amount0);
        IERC20(_path[1]).transferFrom(msg.sender, address(this), _amount1);
        IERC20(_path[0]).approve(address(Router), _amount0);
        IERC20(_path[1]).approve(address(Router), _amount1);

        Router.addLiquidity(_path[0], _path[1], _amount0, _amount1, 0, 0, msg.sender, block.timestamp);
    }

     /**
     * @dev path[wyoho usdt]
     * @dev user need approve and transfer lp token (wyoho/usdt) to this contract.
     * contract lp token need approve to router
     * usdt transfer to address(this)
     * remove after uniswap transfer wyoho and usdt to this contract
     * this contract transfer yoho to user.  wyoho => yoho
     */

    function removeLiquidity(address[] calldata _path, uint256 _liquidity) external checkLength(_path){

        IUniswapV2Factory factory = IUniswapV2Factory(Router.factory());
        address pair = factory.getPair(_path[0],_path[1]);
        require(pair != address(0),"Swap: Pair address is empty.");
      
        IERC20(pair).transferFrom(msg.sender, address(this), _liquidity);
        IERC20(pair).approve(address(Router),_liquidity);

        (uint256 amount0, uint256 amount1) = Router.removeLiquidity(_path[0], _path[1], _liquidity, 0, 0, address(this), block.timestamp);
        IERC20(yohoToken).transfer(msg.sender, amount0);//yoho
        IERC20(_path[1]).transfer(msg.sender, amount1);//usdt
    }

    /**
     * usdt => yoho [usdt wyoho]
     * @dev need enough yoho
     * payToken approve to this
     * usdt transfer to address(this)
     * swap usdt => wyoho
     * transfer wyoho amounts of yoho to user
     */

    function BuyYoho(address[] calldata _path,uint _amount)public {
        uint yohoAmount = IERC20(yohoToken).balanceOf(address(this));
        require(yohoAmount >= _amount,"Swap: Yoho insufficient funds.");

        IERC20(_path[0]).transferFrom(msg.sender, address(this), _amount);
        IERC20(_path[0]).approve(address(Router),_amount);

        uint256[] memory amounts = Router.swapExactTokensForTokens(_amount, 0, _path, address(this), block.timestamp);
        IERC20(yohoToken).transfer(msg.sender,amounts[1]);
    }

     /**
     * yoho => usdt [wyoho usdt]
     * @dev need enough wyoho
     * user's yohoToken need approve to this contract for transferFrom 
     * contract wyohoToken need approve to router
     * usdt transfer to address(this)
     * swap wyoho => usdt
     * transfer wyoho amounts of usdt to user
     */

     function sellYoho(address[] calldata _path,uint _amount) public checkLength(_path){
        //user approve yoho to address(this)
        uint userMax = Donation.getSwapYohoAmount(msg.sender);

        require(userMax > 0,"Swap: You are not qualified."); //max check
        require(_amount <= userMax,"Swap: Exceeded your HO quota."); //max check
        require(_amount <= max,"Swap: The maximum single amount is 100,000,000.");

        uint wyohoAmount = IERC20(_path[0]).balanceOf(address(this));
        require(wyohoAmount >= _amount,"Swap: Insufficient funds.");

        IERC20(_path[0]).transferFrom(msg.sender, address(this), _amount);
        IERC20(_path[0]).approve(address(Router),_amount);

        Router.swapExactTokensForTokens(_amount, 0, _path, msg.sender, block.timestamp);
        Donation.subQuateBySwap(msg.sender,_amount);//sub quota
    }



}
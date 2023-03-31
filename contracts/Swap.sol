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
//invalid**
contract Swap is Ownable{

    uint public max = 5000 ether;

    IUniswapV2Router02 public Router = IUniswapV2Router02(0xE8963DC0599e063a1dC42051d6282D3Fb873EA92);
    IDonation public Donation = IDonation(0x5003AbDcF10A5332a4093B0753a2E874B9C7d48c);

    address public usdtToken = 0x4B6b9F3695205C8468ddf9AB4025ec2A09bDfF1a;
    address public yohoToken = 0x2fC0eBefDD68134809Ee359BBC8A5576c3788120;
    address public wyohoToken = 0x7176A3c502942AA6Cdb8CD12005C1733a8141d69;

    function setMax(uint _max)external onlyOwner {
        max = _max;
    }

    function setDonation(IDonation _donation)external onlyOwner {
        Donation = _donation;
    }


    /**
     * @dev need enough yoho
     * usdtToken approve to this
     * usdt transfer to address(this)
     * swap usdt => wyoho
     * transfer wyoho amounts of yoho to user
     */

    function BuyYoho(uint _amount)public {

        uint yohoAmount = IERC20(yohoToken).balanceOf(address(this));
        require(yohoAmount >= _amount,"Swap: Yoho insufficient funds.");

        IERC20(usdtToken).transferFrom(msg.sender, address(this), _amount);
        IERC20(usdtToken).approve(address(Router),_amount);

        uint256[] memory amounts = Router.swapExactTokensForTokens(_amount, 0, _getPathForUSDTToWyoho(), address(this), block.timestamp);
        IERC20(yohoToken).transfer(msg.sender,amounts[1]);
    }

     /**
     * @dev need enough wyoho
     * user's yohoToken need approve to this contract for transferFrom 
     * contract wyohoToken need approve to router
     * usdt transfer to address(this)
     * swap wyoho => usdt
     * transfer wyoho amounts of usdt to user
     */
    function sellYoho(uint _amount) public{
        //user approve yoho to address(this)
        uint userMax = Donation.getSwapYohoAmount(msg.sender);

        require(userMax > 0,"WYOHO: You are not qualified."); //max check
        require(_amount <= userMax,"WYOHO: The maximum single amount is 100,000,000."); //max check
        require(_amount <= max,"WYOHO: The maximum single amount is 100,000,000.");

        uint wyohoAmount = IERC20(wyohoToken).balanceOf(address(this));
        require(wyohoAmount >= _amount,"Swap: Insufficient funds.");

        IERC20(yohoToken).transferFrom(msg.sender, address(this), _amount);
        IERC20(wyohoToken).approve(address(Router),_amount);
        
        Router.swapExactTokensForTokens(_amount, 0, _getPathForWyohoToUSDT(), msg.sender, block.timestamp);
        Donation.subQuateBySwap(msg.sender,_amount);//sub quota
    }


     /**
     * @dev need enough wyoho token
     * user's yoho\usdt need approve to this contract for transferFrom 
     * contract wyoho need approve to router
     * usdt transfer to address(this)
     * this contract transfer wyoho and usdt to uniswap yoho => wyoho
     * uniswap transfer lp (wyoho/usdt) to user.
     */

    function addLiquidity(uint256 _usdtAmount, uint256 _yohoAmount) external {

        IERC20(usdtToken).transferFrom(msg.sender, address(this), _usdtAmount);
        IERC20(yohoToken).transferFrom(msg.sender, address(this), _yohoAmount);
        IERC20(usdtToken).approve(address(Router), _usdtAmount);
        IERC20(wyohoToken).approve(address(Router), _yohoAmount);

        Router.addLiquidity(usdtToken, wyohoToken, _usdtAmount, _yohoAmount, 0, 0, msg.sender, block.timestamp);
    }

     /**
     * @dev user need approve and transfer lp token (wyoho/usdt) to this contract.
     * contract lp token need approve to router
     * usdt transfer to address(this)
     * remove after uniswap transfer wyoho and usdt to this contract
     * this contract transfer yoho to user.  wyoho => yoho
     */

    function removeLiquidity(uint256 _liquidity) external {

        IUniswapV2Factory factory = IUniswapV2Factory(Router.factory());
        address pair = factory.getPair(usdtToken,wyohoToken);
        require(pair != address(0),"Swap: Pair address is empty.");
      
        IERC20(pair).transferFrom(msg.sender, address(this), _liquidity);
        IERC20(pair).approve(address(Router),_liquidity);

        (uint256 amount0, uint256 amount1) = Router.removeLiquidity(usdtToken, wyohoToken, _liquidity, 0, 0, address(this), block.timestamp);
        IERC20(usdtToken).transfer(msg.sender, amount0);
        IERC20(yohoToken).transfer(msg.sender, amount1);
    }


     function _getPathForUSDTToWyoho() private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = usdtToken;
        path[1] = wyohoToken;
        return path;
    }

    function _getPathForWyohoToUSDT() private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = wyohoToken;
        path[1] = usdtToken;
        return path;
    }


}
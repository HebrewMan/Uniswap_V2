import { ethers } from 'hardhat';
import {abi} from '../artifacts/contracts/tokens/USDT.sol/USDT.json';

async function addLiquidity() {
  const provider = new ethers.providers.JsonRpcProvider('http://http-testnet.aitd.io');
  const privateKey = '12c0a8354bd561fd0fbc7f160ebb7a7435b2d6e17083704d99f305fa3cf3e9b4';
  
  const signer = new ethers.Wallet(privateKey, provider);
  // Connect to the Uniswap pair
  const uniswapPairAddress = '0xE8963DC0599e063a1dC42051d6282D3Fb873EA92';
  const uniswapPair = IUniswapV2Pair__factory.connect(uniswapPairAddress, (await ethers.getSigners())[0]);

  // Get the USDT and WYOHO tokens
  const usdtTokenAddress = '0x4B6b9F3695205C8468ddf9AB4025ec2A09bDfF1a';
  const wyohoTokenAddress = '0x7176A3c502942AA6Cdb8CD12005C1733a8141d69';
  const yohoAddress = '0x1B3B817591b4C9CAc3dA3Af172CA4cE42311A193';

  const YOHO = await ethers.getContractFactory("YOHO");

  const yohoToken = YOHO.connect(signer);


  const usdtToken = ERC20__factory.connect(usdtTokenAddress, (await ethers.getSigners())[0]);
  const wyohoToken = ERC20__factory.connect(wyohoTokenAddress, (await ethers.getSigners())[0]);

  // Approve the Uniswap pair to spend the tokens
  const usdtAllowance = ethers.utils.parseUnits('2000', 18); // Approve 2000 USDT
  const wyohoAllowance = ethers.utils.parseUnits('2000', 18); // Approve 2000 WYOHO

  await usdtToken.approve(uniswapPairAddress, usdtAllowance);
  await wyohoToken.approve(uniswapPairAddress, wyohoAllowance);

  // Add liquidity
  const amountADesired = ethers.utils.parseUnits('2000', 18);
  const amountBDesired = ethers.utils.parseUnits('2000', 18);
  const amountAMin = ethers.utils.parseUnits('1900', 18);
  const amountBMin = ethers.utils.parseUnits('1900', 18);
  const deadline = Math.floor(Date.now() / 1000) + 100000;

  await uniswapPair.addLiquidity(
    usdtTokenAddress,
    wyohoTokenAddress,
    amountADesired,
    amountBDesired,
    amountAMin,
    amountBMin,
    await ethers.getSigner().getAddress(),
    deadline
  );

  console.log('Liquidity added successfully');
}

// Run the addLiquidity function
addLiquidity().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});




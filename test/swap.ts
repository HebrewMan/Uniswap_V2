//address _uniswapV2Factory = _uniswapV2Router.factory();
//uniswapV2Pair = IUniswapV2Factory(_uniswapV2Factory).createPair(usdtAddress, address(this));

import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers }  from "hardhat";

describe("Lock", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployOneYearLockFixture() {
    // const provider = new ethers.providers.JsonRpcProvider('http://http-testnet.aitd.io');

    // Contracts are deployed using the first signer/account by default
    const [owner ,otherAccount] =  await ethers.getSigners();

    const YOHO = await ethers.getContractFactory("YOHO");
    const yoho:any = await YOHO.deploy();

    const WYOHO = await ethers.getContractFactory("WYOHO");
    const wyoho:any = await WYOHO.deploy(yoho.address);
    return {YOHO,yoho,WYOHO, wyoho,  owner,otherAccount };
  }

  describe("Deployed YOHO and WYOHO", function () {
    it("Balance should be right", async function () {
      const { WYOHO, wyoho,YOHO,yoho ,owner} = await loadFixture(deployOneYearLockFixture);
    
        console.log('owner:=>',owner.address)
        console.log('yoho:=>',yoho.address)

        console.log('====yoho========')
        console.log(yoho)
        console.log('=======WYOHO=====')
        console.log(WYOHO)

    //   expect(await lock.unlockTime()).to.equal(unlockTime);
    });

  });

});

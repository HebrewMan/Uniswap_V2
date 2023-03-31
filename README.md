# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

# 捐款和swap 的交互流程

1. 部署 USDT YOHO WYOHO 合约
2. 部署捐款合约
3. 部署swap合约
4. 调用捐款合约 设置 admin 为 swap合约、
5. 向swap合约打入足够的 YOHO 和 WYOHO 用于用户的兑换
6. 授权 USDT 给捐款合约进行捐款获取兑换 YOHO 额度
7. 卖 ~ YOHO 授权 YOHO 给swap 合约
8. 买 ~ YOHO 授权 USDT 给 swap 合约
9. 添加 WYOHO/USDT的流动性 授权 usdt yoho 给 swap 合约 
10. 移除 WYOHO/USDT的流动性 检查用户的lptoken 余额够不够 授权lp token 给swap 合约 用户将得到USDT和 yoho

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.ts
```

import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
const account7926 = '12c0a8354bd561fd0fbc7f160ebb7a7435b2d6e17083704d99f305fa3cf3e9b4'
const account9282 = '362a2dcce38e3670b959dd115694407bd6c40c8b7451300f9f4761b4f552d9aa'
const config: HardhatUserConfig = {
  networks: {
    aitdTest: {
      chainId:1320,
      gasPrice: 1000000000,
      url: "http://http-testnet.aitd.io",
      accounts: [account7926, account9282]
    },
  },
  solidity: {
    compilers: [
      {
        version: "0.8.18",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      }
    ],
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    }
  },
};

export default config;

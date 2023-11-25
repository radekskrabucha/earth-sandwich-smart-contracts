import { HardhatUserConfig } from "hardhat/config"
import "@nomicfoundation/hardhat-toolbox"

require("dotenv").config()

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    lukso: {
      url: "https://rpc.testnet.lukso.network",
      accounts: [`0x${process.env.PRIVATE_KEY}`]
    }
  }
}

export default config

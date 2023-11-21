import { HardhatUserConfig } from "hardhat/config"
import "@nomicfoundation/hardhat-toolbox"

require("dotenv").config()

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  networks: {
    lukso: {
      url: "https://rpc.l14.lukso.network/",
      accounts: [`0x${process.env.PRIVATE_KEY}`]
    }
  }
}

export default config

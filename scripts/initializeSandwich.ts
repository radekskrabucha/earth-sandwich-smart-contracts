import { ethers } from "hardhat"

async function main() {
  const contractAddress = "0xc408Fe764c6a903cE046036B14A87F7280024541" // Replace with your contract address
  const EarthSandwichNFT = await ethers.getContractAt(
    "EarthSandwichNFT",
    contractAddress
  )

  const sandwichName = "Hello Sandwich" // Replace with your sandwich name
  const participantAddresses = ["0xc975653D6C35463732ce93cE98e010D48f39ff19"] // Replace with your participant addresses

  const transaction = await EarthSandwichNFT.initiateSandwich(
    sandwichName,
    participantAddresses
  )
  await transaction.wait()

  console.log(`Sandwich '${sandwichName}' initiated`)
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error)
    process.exit(1)
  })

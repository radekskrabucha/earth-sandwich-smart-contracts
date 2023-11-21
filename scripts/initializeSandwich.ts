import { ethers } from "hardhat"

async function main() {
  const [deployer] = await ethers.getSigners()
  const contractAddress = "0xC51C514a5e082A59ed94Eb92947cd7cad26b93fc"
  const EarthSandwichNFT = await ethers.getContractAt(
    "EarthSandwichNFT",
    contractAddress
  )

  const sandwichId = ethers.id("some random string")

  const sandwichName = "Hello Sandwich"
  const participantAddresses = ["0xc975653D6C35463732ce93cE98e010D48f39ff19"]

  const transaction = await EarthSandwichNFT.initiateSandwich(
    sandwichName,
    sandwichId,
    participantAddresses
  )
  await transaction.wait()

  console.log(`Sandwich '${sandwichName}' initiated with ID: ${sandwichId}`)
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error)
    process.exit(1)
  })

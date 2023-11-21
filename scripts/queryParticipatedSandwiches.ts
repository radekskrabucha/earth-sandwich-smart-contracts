import { ethers } from "hardhat"

async function main() {
  const [deployer] = await ethers.getSigners()
  const contractAddress = "0xC51C514a5e082A59ed94Eb92947cd7cad26b93fc"
  const EarthSandwichNFT = await ethers.getContractAt(
    "EarthSandwichNFT",
    contractAddress
  )

  const participatedSandwiches = await EarthSandwichNFT.getParticipatedSandwiches(
    deployer.address
  )
  console.log("Participated Sandwiches:", participatedSandwiches)
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error)
    process.exit(1)
  })

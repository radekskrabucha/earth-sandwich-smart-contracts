import { ethers } from 'hardhat'

async function main() {
  const contractAddress = "0xC51C514a5e082A59ed94Eb92947cd7cad26b93fc"
  const sandwichId = '0x57c65f1718e8297f4048beff2419e134656b7a856872b27ad77846e395f13ffe'
  const EarthSandwichNFT = await ethers.getContractAt(
    "EarthSandwichNFT",
    contractAddress
  )

  const sandwichDetails = await EarthSandwichNFT.getSandwichDetails(sandwichId)

  console.log("Sandwich Details:", sandwichDetails)
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error)
    process.exit(1)
  })
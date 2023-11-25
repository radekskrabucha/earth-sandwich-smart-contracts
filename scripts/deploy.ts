import { ethers } from 'hardhat'

async function main() {
    const [deployer] = await ethers.getSigners();
    const EarthSandwichNFTFactory = await ethers.getContractFactory("EarthSandwichNFT");
    const earthSandwichNFT = await EarthSandwichNFTFactory.deploy(deployer.address);

    await earthSandwichNFT.waitForDeployment();

    console.log(`Deployed to ${earthSandwichNFT.target}`);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

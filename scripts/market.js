const { ethers } = require("hardhat")

async function main() {
    const Market = await ethers.getContractFactory("NFTMarketplace");
    console.log("Deploying contract...");
    const market = await Market.deploy();
    await market.deployed();
    console.log(`Deployed contract  at ${market.address}`)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
const { ethers } = require("hardhat")
const fs = require("fs");
async function main() {
    const Market = await ethers.getContractFactory("NFTMarketplace");
    console.log("Deploying contract...");
    const market = await Market.deploy();
    await market.deployed();
    console.log(`Deployed contract  at ${market.address}`)


    const data = {
        address:market.address,
        abi: JSON.parse(market.interface.format('json'))
    }
    fs.writeFileSync('./src/Marketplace.json',JSON.stringify(data))
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
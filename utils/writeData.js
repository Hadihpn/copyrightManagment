const fs = require("fs");
const writeData = async (contractAddress,abi) => {
 
    const data = {
        address:contractAddress,
        abi: JSON.parse(abi.format('json'))
    }
    fs.writeFileSync('./src/Marketplace.json',JSON.stringify(data))
}

module.exports = { writeData }
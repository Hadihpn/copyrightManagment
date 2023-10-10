require("@nomiclabs/hardhat-waffle");
require("solidity-coverage");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20",
};
// module.exports = {
//   solidity: {
//     version: "0.8.19",
//     settings: {
//       optimizer: {
//         enabled: true,
//         runs: 1000,
//       },
//     },
//   },
// };
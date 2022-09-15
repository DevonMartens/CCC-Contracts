require("@nomiclabs/hardhat-ethers");
require('dotenv').config()

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  networks: {
    testnet: {
      url: 'https://api.s0.b.hmny.io',
      accounts: [process.env.PRIVATE_KEY],
      saveDeployments: true,
    },
        mainnet: {
            url: 'https://api.harmony.one',
            accounts: [process.env.PRIVATE_KEY],
            saveDeployments: true,
        }
    },
  solidity: "0.8.4",
};

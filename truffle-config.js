require("dotenv").config();

const path = require("path");
const HDWalletProvider = require('truffle-hdwallet-provider');
const fs = require('fs');

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  contracts_build_directory: path.join(__dirname, "client/src/contracts"),
  networks: {
    kovan: {
      networkCheckTimeout: 100000,
      provider: function() {
        return new HDWalletProvider(process.env.MNEMONIC, process.env.INFURA_API_URL);
      },
      network_id: 42
    }
  },
// Configure your compilers
  compilers: {
    solc: {
      version: "pragma",       // Fetch exact version from solc-bin (default: truffle's version)
      docker: false,        // Use "0.5.1" you've installed locally with docker (default: false)
      settings: {          // See the solidity docs for advice about optimization and evmVersion
       optimizer: {
         enabled: false,
         runs: 200
       },
       evmVersion: "byzantium"
      }
    }
  },
  development: {
    port: 8545,
    network_id: 42,
    accounts: 5,
    defaultEtherBalance: 500,
    blockTime: 3
  }
};

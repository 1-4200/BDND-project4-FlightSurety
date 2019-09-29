var HDWalletProvider = require("truffle-hdwallet-provider");
const infuraKey = "92159d9ed16b4601a5c33e71ad5ba363";

const fs = require('fs');
const mnemonic = fs.readFileSync(".secret").toString().trim();

module.exports = {
  networks: {

    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: '*',
      gas: 4712388,
      gasPrice: 100000000000,
    },

    truffle_dev: {
      host: "127.0.0.1",
      port: 9545,
      network_id: '*',
      gas: 6721975,
      gasPrice: 20000000000,
    },
    rinkeby: {
      provider: function () {
        return new HDWalletProvider(mnemonic, `https://rinkeby.infura.io/v3/${infuraKey}`)
      },
      network_id: '4',
      gas: 4500000,
      gasPrice: 10000000000,
    }
  },
};
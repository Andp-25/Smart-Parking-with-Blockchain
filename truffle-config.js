require('@babel/register');

module.exports = {
  networks: {
    development: {
      host: 'localhost',     // Ganache host
      port: 7545,            // Ganache default port
      network_id: 5777       // Ganache default network id
    }
  },
  compilers: {
    solc: {
      version: "0.4.25",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        }
      }
    }
  }
};

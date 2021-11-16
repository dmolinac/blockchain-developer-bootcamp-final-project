var MetaturfNFT = artifacts.require("./MetaturfNFT.sol");

module.exports = function(deployer) {
  deployer.deploy(MetaturfNFT);
  //deployer.deploy(MetaturfNFT, { gas: 50000000 })
};

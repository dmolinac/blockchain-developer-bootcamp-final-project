var Base64 = artifacts.require("./Base64.sol");

module.exports = function(deployer) {
  deployer.deploy(Base64);
};

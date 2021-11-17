var strings = artifacts.require("./strings.sol");

module.exports = function(deployer) {
  deployer.deploy(strings);
};

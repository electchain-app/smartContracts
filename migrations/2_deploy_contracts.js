const ballot = artifacts.require("ballot");

module.exports = function(deployer) {
  deployer.deploy(ballot, ['0x4d616e6f6c6f00000000000000000000', '0x4d616e6f6c6f00000000000000000000']);
};

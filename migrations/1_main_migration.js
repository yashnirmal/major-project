var MainContract = artifacts.require("./Main.sol")

module.exports = function(deployer){
    deployer.deploy(MainContract);
}
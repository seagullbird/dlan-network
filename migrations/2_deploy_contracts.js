const Address = artifacts.require("./libs/Address.sol");
const Counters = artifacts.require("./libs/Counters.sol");
const SafeMath = artifacts.require("./libs/SafeMath.sol");
const NFT = artifacts.require("./NFT.sol");
const DlanCore = artifacts.require("./DlanCore.sol");
const DappToken = artifacts.require("./DappToken.sol");

module.exports = function (deployer) {
    deployer.deploy(DappToken, 1000000).then(function () {
        deployer.deploy(Address);
        deployer.deploy(SafeMath);
        deployer.link(SafeMath, Counters);
        deployer.deploy(Counters);
        deployer.link(Address, NFT);
        deployer.link(Counters, NFT);
        deployer.link(SafeMath, NFT);
        deployer.deploy(NFT);
        deployer.link(NFT, DlanCore);
        return deployer.deploy(DlanCore, DappToken.address);
    });
};

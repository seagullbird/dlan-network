pragma solidity ^0.5.0;

import "./NFT.sol";
import "./DappToken.sol";

contract DlanCore is NFT {
    event Deposited(
        uint256 nftTokenId,
        uint256 _numberOfDlanTokens,
        address indexed owner
    );
    DappToken public dappTokenContract;
    uint256 nextTokenId = 0;
    mapping(uint256 => uint256) public nftValue;

    constructor (DappToken _dappTokenContract) public {
        dappTokenContract = _dappTokenContract;
    }

    // Before calling this, call DappToken.approve(<address of DlanCore>, _numberOfDlanTokens)
    function deposit(uint256 _numberOfDlanTokens) public returns (uint256) {
        require(balanceOf(_msgSender()) == 0, "User already has an NFT token");
        require(dappTokenContract.transferFrom(_msgSender(), address(this), _numberOfDlanTokens), "Unable to transfer DLAN tokens");

        uint256 newTokenId = nextTokenId;
        _mint(_msgSender(), newTokenId);
        nextTokenId += 1;
        nftValue[newTokenId] = _numberOfDlanTokens;

        emit Deposited(newTokenId, _numberOfDlanTokens, _msgSender());
        return newTokenId;
    }
}
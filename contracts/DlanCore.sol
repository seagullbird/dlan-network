pragma solidity ^0.5.0;

import "./NFT.sol";
import "./DappToken.sol";
import "./libs/ECDSA.sol";

contract DlanCore is NFT {
    using ECDSA for bytes32;
    // Contracts
    DappToken public dappTokenContract;

    // Data structures
    struct Channel {
        address owner;
        uint256 nftTokenId;
        uint256 v;
        uint256 bal;  // v-a; user's balance, start decresing from v
        bool exiting;
    }
    mapping(address => Channel) public channels;
    // TODO: hardcode operator address here
    address operatorAddr = address(0x010cBc9930C71f60cA18159A9B250F9Ed416129B);

    // Events
    event Deposited(
        address indexed owner,
        uint256 _numberOfDlanTokens
    );

    event Exiting(
        address indexed owner,
        uint256 bal
    );

    constructor (DappToken _dappTokenContract) public {
        dappTokenContract = _dappTokenContract;
    }

    // Before calling this, call DappToken.approve(<address of DlanCore>, _numberOfDlanTokens)
    function deposit(uint256 _numberOfDlanTokens) public {
        require(balanceOf(_msgSender()) == 0, "User already has an NFT token");
        require(dappTokenContract.transferFrom(_msgSender(), address(this), _numberOfDlanTokens),
        "Unable to transfer DLAN tokens");

        // use the user address as token id because each user
        // can hold only one NFT token
        uint256 newTokenId = uint256(_msgSender());
        _mint(_msgSender(), newTokenId);
        channels[_msgSender()] = Channel({
            owner: _msgSender(),
            nftTokenId: newTokenId,
            v: _numberOfDlanTokens,
            bal: _numberOfDlanTokens,
            exiting: false
        });

        emit Deposited(_msgSender(), _numberOfDlanTokens);
    }

    function start_exit(uint256 bal) public {
        require(channels[_msgSender()].owner != address(0), "User doesn't have an NFT token");
        require(!channels[_msgSender()].exiting, "User is already in exiting state");
        require(bal <= channels[_msgSender()].v, "Cannot exit with an a value larger than v");
        // set exit state
        channels[_msgSender()].bal = bal;
        channels[_msgSender()].exiting = true;

        emit Exiting(_msgSender(), bal);
        // start waiting
        // https://github.com/pipermerriam/ethereum-alarm-clock-docs/blob/master/docs/scheduling.rst
    }

    function challenge(address owner, uint256 bal, bytes memory sig) public {
        require(_msgSender() == operatorAddr, "Chanllenge can only be done by the operator");
        require(channels[owner].owner != address(0), "Challenged user doesn't have an NFT token");
        require(channels[owner].exiting, "Challenged user isn't exiting");
        require(bal <= channels[owner].v, "Cannot exit with an a value larger than v");

        // if the operator is challenging with the same value the user is exiting,
        // no signature verification is required;
        // This is because in this case the operator might not have a valid signature for
        // this value (e.g, when a user deposit v1 then exit with v1, the operator won't have
        // a signature on v1 to perform this challenge)
        if (channels[owner].bal == bal) {
            close_exit(owner);
            return;
        }

        // verify signature
        // reference: https://yos.io/2018/11/16/ethereum-signatures/
        bytes32 messageHash = keccak256(abi.encodePacked(bal)).toEthSignedMessageHash();
        address signer = messageHash.recover(sig);
        require(signer == owner, "Signature doesn't match");

        // update exit
        channels[owner].bal = bal;

        // close exit (Temporary)
        // this requires operator to call challenge every time he receives an Exiting event
        // this set up will be replaced by the timer mechanism next round
        close_exit(owner);
    }

    function close_exit(address owner) private {
        // user gets back bal
        dappTokenContract.transfer(owner, channels[owner].bal);
        // operator gets v - bal
        dappTokenContract.transfer(operatorAddr, channels[owner].v - channels[owner].bal);
        // burn the NFT token
        // token id is the owner's address
        _burn(owner, uint256(owner));
    }
}
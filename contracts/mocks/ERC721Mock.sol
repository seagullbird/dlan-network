pragma solidity ^0.5.0;

import "../NFT.sol";

/**
 * @title ERC721Mock
 * This mock just provides a public safeMint, mint, and burn functions for testing purposes
 */
contract ERC721Mock is NFT {
    function safeMint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
    }

    function safeMint(address to, uint256 tokenId, bytes memory _data) public {
        _safeMint(to, tokenId, _data);
    }

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }

    function burn(address owner, uint256 tokenId) public {
        _burn(owner, tokenId);
    }

    function burn(uint256 tokenId) public {
        _burn(tokenId);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
contract DANIELNFT is ERC721URIStorage{
    uint private _tokenIdCounter;
    address auctionAddress;
    constructor(address _auctionAddress) ERC721("Daniel", "DAN") {
        auctionAddress = _auctionAddress;
    }

     function safeMint(string memory TokenUri) public {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter ++;
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, TokenUri);
        setApprovalForAll(auctionAddress, true);
    }
    

}
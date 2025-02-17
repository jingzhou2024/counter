// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BaseERC20, IERC20Receiver} from "./token.sol";

interface IERC721 {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract NFTMarket is IERC20Receiver {
    struct Listing {
        address seller;
        uint256 price;
        bool isListed;
    }

    mapping(uint256 => Listing) public listings;
    IERC721 public nftContract;
    BaseERC20 public tokenContract;

    event Listed(uint256 indexed tokenId, address indexed seller, uint256 price);
    event Bought(uint256 indexed tokenId, address indexed buyer, address indexed seller, uint256 price);

    constructor(address _nftContract, address _tokenContract) {
        nftContract = IERC721(_nftContract);
        tokenContract = BaseERC20(_tokenContract);
    }

    function list(uint256 tokenId, uint256 price) external {
        require(nftContract.ownerOf(tokenId) == msg.sender, "Not the owner");
        require(price > 0, "Price must be greater than 0");

        listings[tokenId] = Listing({
            seller: msg.sender,
            price: price,
            isListed: true
        });

        emit Listed(tokenId, msg.sender, price);
    }

    function buyNFT(uint256 tokenId) external {
        Listing memory listing = listings[tokenId];
        require(listing.isListed, "NFT not listed");
        require(tokenContract.balanceOf(msg.sender) >= listing.price, "Insufficient balance");

        tokenContract.transferFrom(msg.sender, listing.seller, listing.price);
        nftContract.safeTransferFrom(listing.seller, msg.sender, tokenId);

        delete listings[tokenId];

        emit Bought(tokenId, msg.sender, listing.seller, listing.price);
    }

    function tokensReceived(
        address _from,
        uint256 _value,
        bytes memory _data
    ) external override {
        require(msg.sender == address(tokenContract), "Only accept BaseERC20 tokens");
        require(_data.length == 32, "Invalid data length");

        uint256 tokenId = abi.decode(_data, (uint256));
        Listing memory listing = listings[tokenId];
        require(listing.isListed, "NFT not listed");
        require(_value >= listing.price, "Insufficient payment");

        tokenContract.transferFrom(_from, listing.seller, listing.price);
        nftContract.safeTransferFrom(listing.seller, _from, tokenId);

        delete listings[tokenId];

        emit Bought(tokenId, _from, listing.seller, listing.price);
    }
}
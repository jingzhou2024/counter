// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20Receiver, BaseERC20} from "./token.sol";

contract NFTMarket is IERC20Receiver {
    constructor() {}
 
    function list(address nft, uint tokenid, uint price, address token) public {

    }

    function buyNFT(address nft, uint tokenid, uint amount) public {}

    function tokensReceived(
        address _from,
        uint256 _value,
        bytes memory _data
    ) external {}
}

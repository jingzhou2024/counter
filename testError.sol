// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Example111 {
    error InsufficientBalance(uint256 available, uint256 required);

    constructor() payable{}

    receive() external payable {}

    function transfer(uint256 amount) public pure {
        uint256 balance = 100;
        if (amount > balance) {
            revert InsufficientBalance(balance, amount);
        }
    }
}

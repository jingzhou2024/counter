// SPDX-License-Identifier: MIT

// 编写一个简单的合约，该合约包含一个名为greet的public函数，该函数返回固定的字符串Hello, World!。

pragma solidity ^0.8.0;

contract Greeter {
    // greet
    function greet() public pure returns (string memory) {
        return "Hello, World!";
    }
}
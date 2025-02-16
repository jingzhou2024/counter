// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract A {
    uint public constant b = 123;
    uint public immutable a;
    constructor () {
        a = 1;
    }
}
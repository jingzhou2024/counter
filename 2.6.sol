// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ArrayDataType {
    // numbers;
    uint[] numbers;


    constructor() {}

    function addNumber(uint x) public {
        numbers.push(x);
    }

    function getLength() public view returns (uint) {
        //
        return numbers.length;
    }

    function getNumberAt(uint idx) public view returns (uint) {
        // require(idx > 0 && idx < numbers.length, "idx wrong" );
        return numbers[idx];
    }

    function removeNumber() public {
        numbers.pop();
    }
}

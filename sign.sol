// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Strings.sol";

contract HashExample {
    function hashPersonal(bytes memory message) public pure returns (bytes32) {
        return keccak256(bytes.concat("\x19Ethereum Signed Message:\n", 
            bytes(Strings.toString(message.length)), message));
    }
}
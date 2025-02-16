pragma solidity ^0.8.0;

contract GasOptimization {
    function example(bytes data) external {
        data[0] = 0x01;
    }
}

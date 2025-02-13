pragma solidity ^0.8.0;
/* 
编写一个public pure函数pureFunc，
它接收两个uint参数a和b，并返回它们的和，确保此函数不会修改或读取合约的状态。

编写一个public view函数viewFunc，它接收两个uint参数a和b，并返回a、b以及当前区块号的和。
*/

contract FucStateVariability {
    // pureFunc
    function pureFunc(uint a, uint b) public pure returns (uint) {
        return a + b;
    }
    //viewFunc
    function viewFunc(uint a, uint b) public view returns (uint) {
        return a + b + block.number;
    }
}

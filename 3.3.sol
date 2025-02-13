pragma solidity ^0.8.0;
/*
编写一个名为multiplyByTwo的public函数，
接收一个uint类型的参数并返回这个数字乘以2的结果。


*/

contract Multiplier {
    // multiplyByTwo
    function multiplyByTwo(uint a) public pure returns (uint) {
        return a * 2;
    } 
}
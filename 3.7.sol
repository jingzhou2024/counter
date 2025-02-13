pragma solidity ^0.8.0;

/*
函数修饰器是 Solidity 的重要组成部分，
在以声明方式改变函数行为方面被广泛使用。
要求：

添加isOwner修饰器修饰withdraw()方法，确保只有合约的拥有者可以执行该函数。
当非拥有者调用时，报Only owner错误 
*/

contract ModifierExample {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // isOwner

    function withdraw() public {
        // 函数体可以留空 
    }
}
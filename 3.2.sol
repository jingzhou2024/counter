pragma solidity ^0.8.0;
/*
编写一个合约，
包含一个名为owner的address类型的public状态变量，
使用一个构造函数来设置这个地址为部署合约的地址。
*/
contract ConstructorExample {
    // owner
    address public owner;
    // constructor
    constructor()  {
        owner = msg.sender;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//完成Car合约的构造函数，初始化基类的数据
// 补充完整move函数，重载父类的方法

abstract contract Vehicle {
    string public name;

    constructor(string memory _name) {
        name = _name;
    }

    // 抽象函数，要求继承的子类实现具体功能
    function move() public pure virtual returns (string memory);
}

contract Car is Vehicle {
    // 使用构造函数来初始化基类的数据
    constructor(string memory _name) Vehicle(_name) {} 

    // 重载父类的抽象方法
    function move() public pure override returns(string memory) {
        return "Car drives on the road";
    }
}

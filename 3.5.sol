// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
可见性关键字如public、private、internal、以及external控制着变量和函数能被哪些其它合约或外部调用者访问

定义一个 private uint类型变量privateVar，并赋值为 10
定义一个 internal uint类型变量 internalVar，并赋值为 20
定义一个 public uint类型变量 publicVar，并赋值为 30
定义一个 public函数getPrivateVar返回privateVar变量值
定义一个 public函数getInternalVar返回internalVar变量值
定义一个 external函数externalFunction返回publicVar变量值
定义一个 public函数getPublicVar，内部调用externalFunction方法 
*/
contract Visibility {
    // privateVar
    uint256 private privateVar = 10;
    // internalVar
    uint256 internal internalVar = 20;
    // publicVar
    uint256 public publicVar = 30;

    // getPrivateVar()
    function getPrivateVar() public view returns (uint256) {
        return privateVar;
    }

    // getInternalVar()
    function getInternalVar() public view returns (uint256) {
        return internalVar;
    }

    // getPublicVar()
    function getPublicVar() public {
        this.externalFunction();
    }

    // externalFunction()
    function externalFunction() external view returns (uint256) {
        return publicVar;
    }
}

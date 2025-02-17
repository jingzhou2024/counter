// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/*
编写一个 TokenBank 合约，可以将自己的 Token 存入到 TokenBank， 和从 TokenBank 取出。

TokenBank 有两个方法：

deposit() : 需要记录每个地址的存入数量；
withdraw（）: 用户可以提取自己的之前存入的 token。
*/

// 导入BaseERC20合约
import {BaseERC20} from "./token.sol";

contract TokenBank {
    mapping(address => uint256) public deposits; // 记录每个地址的存款数量
    BaseERC20 public token; // Token合约实例
    event DepositTransaction(address user, uint amount);
    constructor(address _tokenAddress) {
        token = BaseERC20(_tokenAddress); // 初始化token合约实例
    }

    function deposit(uint256 _amount) public {
        require(_amount > 0, "Amount must be greater than zero");
        bool success = token.transferFrom(msg.sender, address(this), _amount);
        require(success, "Transfer failed"); // 从用户账户转移token到TokenBank合约
        deposits[msg.sender] += _amount; // 更新存款记录
    }

    function withdraw(uint256 _amount) public {
        require(_amount > 0, "Amount must be greater than zero");
        require(deposits[msg.sender] >= _amount, "Insufficient balance"); // 检查余额是否足够
        require(token.transfer(msg.sender, _amount), "Transfer failed"); // 从TokenBank合约转移token到用户账户
        deposits[msg.sender] -= _amount; // 更新存款记录
    }

    // 添加一个查询余额的函数，方便用户查看在Bank的token数量
    function balanceOf(address _user) public view returns (uint256) {
        return deposits[_user];
    }
}

contract TokenBankVTwo is TokenBank {
    constructor(address _tokenAddress) TokenBank(_tokenAddress) {}

    function depositWithCallback(uint256 _amount, bytes memory _data) public {
        require(_amount > 0, "Amount must be greater than zero");
        require(
            token.transferWithCallback(address(this), _amount, _data),
            "Transfer failed"
        ); // 从用户账户转移token到TokenBank合约
        deposits[msg.sender] += _amount; // 更新存款记录
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyToken {
    mapping(address => uint256) private _balances;
    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(uint256 initSupply) {
        _balances[msg.sender] = initSupply;
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(_balances[msg.sender] >= value, "Insufficient balance");
        _balances[msg.sender] -= value;
        _balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
}
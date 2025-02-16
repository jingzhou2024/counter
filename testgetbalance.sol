// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract B {
    address public addr;
    constructor (address _addr) payable  {
        addr = _addr;
    }
    receive() external payable { }
    function getcontractBalance() public view returns (uint){
        return address(this).balance;
    }
    function getaddrBalance() public view returns (uint) {
        return addr.balance;
    }
}
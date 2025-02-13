// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AddressDataType {
    // wallet
    address public wallet = 0xdeaADF91881EC521385c45959556C026F4804884;

    constructor() {}

    function checkBalance() public view returns (uint256) {
        //
        return wallet.balance;
    }

    function sendEth(uint256 amount) public payable {
        //确保不为0
        // require(amount > 0, "Amount uint");
        // 向 wallet 发送指定的以太币数量
        // require(
        //     address(this).balance >= amount,
        //     "Insufficient contract balance"
        // );
        payable(wallet).transfer(amount);
    }

    receive() external payable {} 
}

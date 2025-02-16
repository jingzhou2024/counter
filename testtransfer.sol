// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DTransfer {
    address public addr;
    address public sender;
    bool public flag = false;
    constructor () {
    }
    function zhuanzhang() public payable {
        // address payable newAddr = payable(addr);
        // newAddr.transfer(msg.value);
        // payable(addr).transfer(5 ether);
        (flag, ) = payable(addr).call{value: 1 ether}(new bytes(0));
        sender = msg.sender;
    }

    function setAddr(address _addr) public  {
        addr = _addr;
    }

    // receive() external payable { }


}

contract B {
    address public sender;
    receive() external payable {
        sender = msg.sender;
     }
}
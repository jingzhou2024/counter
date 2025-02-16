// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/*
补充完整 Caller 合约的 callGetData 方法，
使用 staticcall 调用 Callee 合约中 getData 函数，并返回值。
当调用失败时，抛出“staticcall function failed”异常。
*/

contract Callee {
    uint256 value;

    function getValue() public view returns (uint256) {
        return value;
    }

    function setValue(uint256 value_) public payable {
        require(msg.value > 0);
        value = value_;
    }
}

contract Caller {
    function callSetValue(address callee, uint256 value) public payable returns (bool) { // 添加 payable 修饰符
        // call setValue()
        bytes memory data = abi.encodeWithSignature("setValue(uint256)", value);
        (bool success, ) = callee.call{value: 1 ether}(data);
        require(success, "call function failed");
        return success;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/*
在 Solidity 中，正确的数据存储位置不仅关系到合约的执行效率，
还直接影响交易成本（gas）。storage、memory和calldata是用以指定数据存储位置的关键词，
它们分别用于持久存储、临时存储和外部函数调用参数。

任务描述:
以下是部分完成的智能合约，其中包括一个用于存储整数的数组以及三个函数。这些函数分别用于：

添加一系列新元素到数组中
返回从指定索引开始的数字序列
修改数组中的所有元素，增加特定值
在合约代码中的三个空白处（____）填入正确的关键词（calldata、memory或storage），
以确保合约可以正常编译并通过测试。
*/
contract DataLocation {
    uint[] private numbers;

    // 添加一系列新元素到数组中
    function addNumbers(uint[] memory _numbers) public {
        for (uint i = 0; i < _numbers.length; i++) {
            numbers.push(_numbers[i]);
        }
    }

    // 返回从指定索引开始的数字序列
    function getNumbers(
        uint start,
        uint count
    ) public view returns (uint[] memory result) {
        result = new uint[](count);
        for (uint i = 0; i < count; i++) {
            result[i] = numbers[start + i];
        }
    }

    // 修改数组中的所有元素，增加特定值
    function increaseNumbers(uint value) public {
        uint[] storage storedNumbers = numbers;
        for (uint i = 0; i < storedNumbers.length; i++) {
            storedNumbers[i] += value;
        }
    }
}

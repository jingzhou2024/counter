pragma solidity ^0.8.0;

contract IntegerDataType {
    uint public a = 10;
    uint public b = 1;
    int public c = -1;
    
    function arithmetic() public view returns (uint add,uint sub,uint mul,uint div) {
        add = a + b;
        sub = a - b;
        mul = a * b;
        div = a / b;
    }
}
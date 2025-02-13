pragma solidity ^0.8.0;

contract BooleanDataType {
    // isActive
    bool public isActive = true;
    function switchStatus() public {
        // 
        isActive = !isActive;
    }

}
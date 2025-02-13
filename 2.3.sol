pragma solidity ^0.8.12;

contract StringDataType {
    // s1
    string public s1 = "hello";
    // s2
    string public s2 = "world";

    function combine() public view returns (string memory s3) {
        //
        s3 = string(abi.encodePacked(s1, s2));

    }

}
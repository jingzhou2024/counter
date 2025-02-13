// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    address payable public admin;
    mapping(address => uint256) public balances;
    RankingStruct[3] public topUsers;
    struct RankingStruct {
        address addr;
        uint256 balance;
    }

    constructor(address payable _admin) payable {
        admin = _admin;
        topUsers[0] = RankingStruct(address(0), 0);
        topUsers[1] = RankingStruct(address(0), 0);
        topUsers[2] = RankingStruct(address(0), 0);
    }

    receive() external payable {
        balances[msg.sender] = balances[msg.sender] + msg.value;
        bool flag = false;
        for (uint256 i = 0; i < 3; i++) {
            if (msg.sender == topUsers[i].addr) {
                flag = true;
                topUsers[i].balance = balances[msg.sender];
                break;
            }
        }
        if (!flag) {
            if (balances[msg.sender] > topUsers[0].balance) {
                topUsers[0].addr = msg.sender;
                topUsers[0].balance = balances[msg.sender];
            } else if (balances[msg.sender] > topUsers[1].balance) {
                topUsers[1].addr = msg.sender;
                topUsers[1].balance = balances[msg.sender];
            } else if (balances[msg.sender] > topUsers[2].balance) {
                topUsers[2].addr = msg.sender;
                topUsers[2].balance = balances[msg.sender];
            }
            bubbleSort();
        }
    }

    function withdraw() public returns (uint256) {
        require(msg.sender == admin, "admin wrong");
        payable(admin).transfer(address(this).balance);
        return address(this).balance;
    }

    function compare(uint256 a, uint256 b) internal pure returns (bool) {
        return a > b;
    }

    function rightBigger(
        RankingStruct memory left,
        RankingStruct memory right,
        function(uint256, uint256) internal pure returns (bool) func
    ) internal pure returns (RankingStruct memory, RankingStruct memory) {
        if (func(left.balance, right.balance)) {
            return (right, left);
        }
        return (left, right);
    }

    function bubbleSort() internal {
        uint256 num = topUsers.length;
        for (uint256 i = 0; i < num - 1; i++) {
            for (uint256 j = 0; j < num - 1 - i; j++) {
                (
                    RankingStruct memory left,
                    RankingStruct memory right
                ) = rightBigger(topUsers[j], topUsers[j + 1], compare);
                topUsers[j] = left;
                topUsers[j + 1] = right;
            }
        }
    }

    function getRankings() public view returns (RankingStruct[3] memory) {
        return topUsers;
    }

    function checkUserInTopUsers(address user)
        public
        view
        returns (
            bool found,
            uint256 balance,
            uint256 position
        )
    {
        for (uint256 i = 0; i < 3; i++) {
            if (user == topUsers[i].addr) {
                return (true, topUsers[i].balance, i);
            }
        }
        return (false, 0, 0);
    }
}

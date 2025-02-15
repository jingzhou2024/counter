// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBank {
    function withdraw() external returns (uint256);
}

contract Bank is IBank {
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
    modifier onlyAdmin() {
        require(msg.sender == admin, "must admin");
        _;
    }
    
    function deposit(address sender, uint value) public virtual {
        balances[sender] = balances[sender] + value;
        bool flag = false;
        for (uint256 i = 0; i < 3; i++) {
            if (sender == topUsers[i].addr) {
                flag = true;
                topUsers[i].balance = balances[sender];
                break;
            }
        } 
        if (!flag) {
            if (balances[sender] > topUsers[0].balance) {
                topUsers[0].addr = sender;
                topUsers[0].balance = balances[sender];
            } else if (balances[sender] > topUsers[1].balance) {
                topUsers[1].addr = sender;
                topUsers[1].balance = balances[sender];
            } else if (balances[sender] > topUsers[2].balance) {
                topUsers[2].addr = sender;
                topUsers[2].balance = balances[sender];
            }
            bubbleSort();
        }
    }

    receive() external virtual payable { 
        deposit(msg.sender, msg.value);
    }


    function withdraw() external override returns (uint256)  {
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

/*
在 该挑战 的 Bank 合约基础之上，编写 IBank 接口及BigBank 合约，
使其满足 Bank 实现 IBank， BigBank 继承自 Bank ， 同时 BigBank 有附加要求：

要求存款金额 >0.001 ether（用modifier权限控制）
BigBank 合约支持转移管理员
编写一个 Admin 合约， Admin 合约有自己的 Owner ，
同时有一个取款函数 adminWithdraw(IBank bank), 
adminWithdraw 中会调用 IBank 接口的 withdraw 方法从而把 bank 合约内的资金转移到 Admin 合约地址。

BigBank 和 Admin 合约 部署后，把 BigBank 的管理员转移给 Admin 合约地址，模拟几个用户的存款，然后

Admin 合约的Owner地址调用 adminWithdraw(IBank bank) 把 BigBank 的资金转移到 Admin 地址。
*/

contract BigBank is Bank {
    uint constant DEPOSIT_LIMIT = 10 ** 15;
    constructor () Bank(payable(address(msg.sender))) payable  {

    }
    modifier oneFinney(uint value) {
        require(value > 1 * DEPOSIT_LIMIT, "must more than 1 Finney");
        _;
    }

    function changeAdmin(address payable _admin) public onlyAdmin {
        admin = _admin;
    }

    function deposit(address sender, uint value) public oneFinney(value) override {
        super.deposit(sender, value);
    }

    receive() external override payable { 
        deposit(msg.sender, msg.value);
    }

}

contract Admin {
    address public _owner;
    constructor () {
        _owner = msg.sender;
    }

    modifier Owner() {
        require(_owner == msg.sender, "must be owner");
        _;
    }

    function adminWithdraw(IBank bank) public Owner{
        
        // address(bank).call(abi.encodeWithSignature("withdraw()"));
        IBank(bank).withdraw();
    }
    receive() external payable { }
}
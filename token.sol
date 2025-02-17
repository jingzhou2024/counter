// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
设置 Token 名称（name）："BaseERC20"
设置 Token 符号（symbol）："BERC20"
设置 Token 小数位decimals：18
设置 Token 总量（totalSupply）:100,000,000
允许任何人查看任何地址的 Token 余额（balanceOf）
允许 Token 的所有者将他们的 Token 发送给任何人（transfer）；转帐超出余额时抛出异常(require),并显示错误消息 “ERC20: transfer amount exceeds balance”。
允许 Token 的所有者批准某个地址消费他们的一部分Token（approve）
允许任何人查看一个地址可以从其它账户中转账的代币数量（allowance）
允许被授权的地址消费他们被授权的 Token 数量（transferFrom）；
转帐超出余额时抛出异常(require)，异常信息：“ERC20: transfer amount exceeds balance”
转帐超出授权数量时抛出异常(require)，异常消息：“ERC20: transfer amount exceeds allowance”。
注意：
在编写合约时，需要遵循 ERC20 标准，此外也需要考虑到安全性，确保转账和授权功能在任何时候都能正常运行无误。
代码模板中已包含基础框架，只需要在标记为“Write your code here”的地方编写你的代码。不要去修改已有内容！
*/
// 定义接收合约需要实现的接口
interface IERC20Receiver {
    function tokensReceived(
        address _from,
        uint256 _value,
        bytes memory _data
    ) external;
}

contract BaseERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 public totalSupply;

    mapping(address => uint256) balances;

    mapping(address => mapping(address => uint256)) allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor() {
        // write your code here
        // set name,symbol,decimals,totalSupply
        name = "BaseERC20";
        symbol = "BERC20";
        decimals = 18;
        totalSupply = 100000000 * 10**18;
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        // write your code here
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        // write your code here
        require(
            balances[msg.sender] >= _value,
            "ERC20: transfer amount exceeds balance"
        );
        require(msg.sender != _to, "DONT TRANSFER YOUSELF");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        // write your code here
        require(
            allowances[_from][msg.sender] >= _value,
            "ERC20: transfer amount exceeds allowance"
        );
        require(
            balances[_from] >= _value,
            "ERC20: transfer amount exceeds balance"
        );
        if (msg.sender != _to) {
            allowances[_from][msg.sender] -= _value;
            balances[_from] -= _value;
            balances[_to] += _value;
            emit Transfer(_from, _to, _value);
        }
        success = true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        // write your code here
        // require(_value <= totalSupply, "DONOT MORE THAN TOTALSUPPLY");
        require(msg.sender != _spender, "DONT APPROVE YOUSELF");
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256)
    {
        require(_owner != _spender, "DONOT LOOK AT YOUSELF");
        return allowances[_owner][_spender];
    }

    function transferWithCallback(
        address _to,
        uint256 _value,
        bytes memory _data
    ) public returns (bool success) {
        require(
            balances[msg.sender] >= _value,
            "ERC20: transfer amount exceeds balance"
        );
        require(msg.sender != _to, "DONT TRANSFER YOUSELF");

        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        // 检查接收地址是否为合约地址
        if (isContract(_to)) {
            IERC20Receiver(_to).tokensReceived(msg.sender, _value, _data);
        }

        return true;
    }

    // 辅助函数：检查地址是否为合约地址
    function isContract(address addr) internal view returns (bool) {
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(addr)
        }
        return codeSize > 0;
    }
}

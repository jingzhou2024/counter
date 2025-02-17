// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
扩展 ERC20 合约 ，添加一个有hook 功能的转账函数，
如函数名为：transferWithCallback ，
在转账时，如果目标地址是合约地址的话，调用目标地址的 tokensReceived() 方法。

继承 TokenBank 编写 TokenBankV2，支持存入扩展的 ERC20 Token，
用户可以直接调用 transferWithCallback 将 扩展的 ERC20 Token 存入到 TokenBankV2 中。
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


contract TokenBank {
    mapping(address => uint256) public deposits; // 记录每个地址的存款数量
    BaseERC20 public token; // Token合约实例

    constructor(address _tokenAddress) {
        token = BaseERC20(_tokenAddress); // 初始化token合约实例
    }

    function deposit(uint256 _amount) public {
        require(_amount > 0, "Amount must be greater than zero");
        require(
            token.transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        ); // 从用户账户转移token到TokenBank合约
        deposits[msg.sender] += _amount; // 更新存款记录
    }

    function withdraw(uint256 _amount) public {
        require(_amount > 0, "Amount must be greater than zero");
        require(deposits[msg.sender] >= _amount, "Insufficient balance"); // 检查余额是否足够
        require(token.transfer(msg.sender, _amount), "Transfer failed"); // 从TokenBank合约转移token到用户账户
        deposits[msg.sender] -= _amount; // 更新存款记录
    }

    // 添加一个查询余额的函数，方便用户查看在Bank的token数量
    function balanceOf(address _user) public view returns (uint256) {
        return deposits[_user];
    }
}

contract TokenBankVTwo is TokenBank {
    constructor(address _tokenAddress) TokenBank(_tokenAddress) {}
}

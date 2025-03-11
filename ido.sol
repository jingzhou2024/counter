// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 如何定义预售的开始和结束时间？
// 如何计算代币的购买价格？
// 如何存储和跟踪用户的购买记录？
// 如何在预售成功或失败时更新合约状态？
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract MyTokenWithPermit is ERC20Permit {
    // 代币基本信息
    uint256 constant TOTAL_SUPPLY = 1000000 * 10**18; // 总供应量：100万代币

    // 构造函数
    constructor()
        ERC20("MyToken", "MTK") // 代币名称和符号
        ERC20Permit("MyToken") // Permit 的名称，通常与代币名称相同
    {
        _mint(msg.sender, TOTAL_SUPPLY); // 在部署时铸造所有代币给部署者
    }

    // 可以添加其他自定义功能
    // 示例：销毁函数
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    // 示例：获取 decimals（可选，因为默认是 18）
    function decimals() public pure override returns (uint8) {
        return 18;
    }
}

contract LInIDO {
    MyTokenWithPermit public token; // 代币合约地址
    address payable public presale_addr; // 合约所有者
    uint256 start = 1628590437; //预售开始时间
    uint256 end = 1628766137 + 100 * 24 * 60 * 60; //预售结束时间
    uint256 immutable TOKENS_PER_ETH = 10000;
    // 价格
    uint256 presale_price = 1e14 wei;
    // 总个数
    uint256 presale_uantity = 1e6 * 1e18;
    //总个数
    uint256 presale_sec_uantity = 2 * 1e6 * 1e18;
    //单地址最高
    uint256 immutable single_addr_max_buy_in = 1000 * 1e14 wei;
    // 单笔最低
    uint256 immutable single_buy_in_min_price = 100 * 1e14 wei;

    // 存储用户购买记录
    mapping(address => uint256) public buy_in;
    // 预售状态
    enum PresaleState {
        Active,
        Success,
        Failed
    }
    // 是否已结束并确定状态
    bool public finalized = false;

    constructor(address _token) payable {
        presale_addr = payable(msg.sender); // 显式转换
        token = MyTokenWithPermit(_token); // 初始化代币合约实例
    }

    //预售阶段，允许用户在合约处于活动状态时向合约发送ETH以购买代币。
    function presale() public payable onlyActive {
        require(
            msg.value > single_buy_in_min_price,
            unicode"single buy in min price 0.01 ETH"
        );
        require(
            buy_in[msg.sender] + msg.value <= single_addr_max_buy_in,
            unicode"single address buy in max 0.1 ETH"
        );
        // 预售价格
        buy_in[msg.sender] = msg.value;
    }

    // 在预售结束后声明他们购买的代币。只有在预售成功完成后，用户才能声明他们的代币。就是取钱
    function claim(
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public onlySuccess {
        require(block.timestamp > end, "Presale not ended");
        require(buy_in[msg.sender] > 0, "No tokens to claim");

        uint256 tokenAmount = (buy_in[msg.sender] * TOKENS_PER_ETH) / 1 ether;
        require(tokenAmount <= value, "Invalid token amount");

        token.permit(presale_addr, address(this), value, deadline, v, r, s);
        buy_in[msg.sender] = 0;
        token.transferFrom(presale_addr, msg.sender, tokenAmount);
    }

    // 合约所有者在预售成功完成后提取合约中的ETH
    function withdraw() public onlySuccess {
        require(block.timestamp > end, unicode"not claim");
        require(msg.sender == presale_addr, "Only owner can withdraw"); // 确保只有合约所有者可以提款
        uint256 balance = address(this).balance; // 获取合约的 ETH 余额
        require(balance > 0, "No ETH to withdraw"); // 确保合约中有 ETH 可以提款
        (bool success, ) = presale_addr.call{value: balance}(""); // 将 ETH 转移到 presale_addr
        require(success, "Withdrawal failed"); // 确保转账成功
    }

    // 估算用户发送一定数量的ETH可以购买多少代币
    function estAmount(uint256 eths) public pure returns (uint256) {
        return eths * TOKENS_PER_ETH; // 计算代币数量
    }

    // 在预售失败时向用户退还他们发送的ETH。
    function Refund() public onlyFailed {
        require(block.timestamp > end, unicode"not claim");
        require(buy_in[msg.sender] > 0, unicode"not money");
        uint256 balance = address(this).balance; // 获取合约的 ETH 余额
        if (balance > 0) {
            // 如果合约中有 ETH，则退款
            payable(msg.sender).transfer(buy_in[msg.sender]);
        }
    }

    // 检查是否达到了预定的筹款目标
    modifier onlySuccess() {
        require(block.timestamp >= end, "Presale not ended");

        require(
            finalized && address(this).balance >= presale_uantity,
            "Not successful"
        );

        _;
    }
    // 只有在预售失败后，用户才能调用函数. 检查是否未达到预定的筹款目标
    modifier onlyFailed() {
        require(block.timestamp >= end, "Presale not ended");

        require(
            finalized && address(this).balance < presale_uantity,
            "Not successful"
        );

        _;
    }
    // 检查合约是否处于活动状态。检查是否在预售时间范围内
    modifier onlyActive() {
        require(
            block.timestamp >= start && block.timestamp <= end,
            unicode"presale is not active"
        );
        _;
    }
}

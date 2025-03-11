// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 如何定义预售的开始和结束时间？
// 如何计算代币的购买价格？
// 如何存储和跟踪用户的购买记录？
// 如何在预售成功或失败时更新合约状态？


// 设计思路：
// Launchpad（如一些通用平台）通常有一个预售池，时间结束后自动根据筹集金额分配代币。

// 没有手动 finalize，但会记录最终余额，状态由时间和目标决定。

// 用户参与后，合约自动判断成功或失败。



// 特点
// 自动化锁定：totalRaisedAtEnd 在第一次调用结束函数时自动记录，避免手动更新。

// Launchpad 相似性：类似一些平台在预售池结束后自动分配，状态基于时间和锁定金额。

// 简单性：没有显式状态枚举，逻辑清晰。




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
contract LInIDO_LaunchpadStyle {
    MyTokenWithPermit public token;
    address payable public presale_addr;
    uint256 public start = 1628590437;
    uint256 public end = 1628766137 + 100 * 24 * 60 * 60;
    uint256 immutable TOKENS_PER_ETH = 10000;
    uint256 public presale_price = 1e14 wei;
    uint256 public presale_quantity = 1e6 * 1e18;
    uint256 immutable single_addr_max_buy_in = 1000 * 1e14 wei;
    uint256 immutable single_buy_in_min_price = 100 * 1e14 wei;
    uint256 public totalRaisedAtEnd; // 结束时锁定总金额

    mapping(address => uint256) public buy_in;

    constructor(address _token) payable {
        presale_addr = payable(msg.sender);
        token = MyTokenWithPermit(_token);
    }

    function presale() public payable {
        require(block.timestamp >= start && block.timestamp <= end, "Presale not active");
        require(msg.value >= single_buy_in_min_price, "Min buy-in 0.01 ETH");
        require(buy_in[msg.sender] + msg.value <= single_addr_max_buy_in, "Max buy-in 0.1 ETH");
        buy_in[msg.sender] += msg.value;
    }

    // 自动锁定结束时的余额
    function _lockTotalRaised() private {
        if (block.timestamp > end && totalRaisedAtEnd == 0) {
            totalRaisedAtEnd = address(this).balance;
        }
    }

    function claim(uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        _lockTotalRaised();
        require(block.timestamp > end, "Presale not ended");
        require(buy_in[msg.sender] > 0, "No tokens to claim");
        require(totalRaisedAtEnd >= presale_quantity / TOKENS_PER_ETH, "Presale failed");

        uint256 tokenAmount = (buy_in[msg.sender] * TOKENS_PER_ETH) / 1 ether;
        require(tokenAmount <= value, "Invalid token amount");

        token.permit(presale_addr, address(this), value, deadline, v, r, s);
        buy_in[msg.sender] = 0;
        token.transferFrom(presale_addr, msg.sender, tokenAmount);
    }

    function refund() public {
        _lockTotalRaised();
        require(block.timestamp > end, "Presale not ended");
        require(buy_in[msg.sender] > 0, "No ETH to refund");
        require(totalRaisedAtEnd < presale_quantity / TOKENS_PER_ETH, "Presale succeeded");

        uint256 amount = buy_in[msg.sender];
        buy_in[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function withdraw() public {
        _lockTotalRaised();
        require(block.timestamp > end, "Presale not ended");
        require(msg.sender == presale_addr, "Only owner");
        require(totalRaisedAtEnd >= presale_quantity / TOKENS_PER_ETH, "Presale failed");
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");
        (bool success, ) = presale_addr.call{value: balance}("");
        require(success, "Withdrawal failed");
    }

    function estAmount(uint256 eths) public pure returns (uint256) {
        return (eths * TOKENS_PER_ETH) / 1 ether;
    }
}
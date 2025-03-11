// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 如何定义预售的开始和结束时间？
// 如何计算代币的购买价格？
// 如何存储和跟踪用户的购买记录？
// 如何在预售成功或失败时更新合约状态？


// 设计思路：


// Polkastarter 通常有固定的预售时间和目标，结束后自动分配代币或退款。

// 状态由时间驱动，但会记录参与者的贡献，结束后根据比例分配。

// 这里我们假设一个硬顶（hard cap），并根据实际筹集金额按比例分配代币。

//特点

// 硬顶与比例分配：模仿 Polkastarter 的硬顶机制，超募时按比例分配代币。

// 软顶退款：设置一个软顶（这里假设为硬顶的一半），未达到时退款。

// 自动化：无需手动更新，状态由时间和 totalRaised 驱动。



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
contract LInIDO_PolkastarterStyle {
    MyTokenWithPermit public token;
    address payable public presale_addr;
    uint256 public start = 1628590437;
    uint256 public end = 1628766137 + 100 * 24 * 60 * 60;
    uint256 immutable TOKENS_PER_ETH = 10000;
    uint256 public presale_price = 1e14 wei;
    uint256 public presale_quantity = 1e6 * 1e18; // 硬顶代币数量
    uint256 immutable single_addr_max_buy_in = 1000 * 1e14 wei;
    uint256 immutable single_buy_in_min_price = 100 * 1e14 wei;
    uint256 public totalRaised; // 总计筹集的 ETH

    mapping(address => uint256) public buy_in;

    constructor(address _token) payable {
        presale_addr = payable(msg.sender);
        token = MyTokenWithPermit(_token);
    }

    function presale() public payable {
        require(block.timestamp >= start && block.timestamp <= end, "Presale not active");
        require(msg.value >= single_buy_in_min_price, "Min buy-in 0.01 ETH");
        require(buy_in[msg.sender] + msg.value <= single_addr_max_buy_in, "Max buy-in 0.1 ETH");
        require(totalRaised + msg.value <= presale_quantity / TOKENS_PER_ETH, "Hard cap reached");
        buy_in[msg.sender] += msg.value;
        totalRaised += msg.value;
    }

    // 按比例领取代币（超募时调整）
    function claim(uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        require(block.timestamp > end, "Presale not ended");
        require(buy_in[msg.sender] > 0, "No tokens to claim");

        uint256 tokenAmount;
        if (totalRaised > presale_quantity / TOKENS_PER_ETH) {
            // 超募，按比例分配
            tokenAmount = (buy_in[msg.sender] * presale_quantity) / totalRaised;
        } else {
            tokenAmount = (buy_in[msg.sender] * TOKENS_PER_ETH) / 1 ether;
        }
        require(tokenAmount <= value, "Invalid token amount");

        token.permit(presale_addr, address(this), value, deadline, v, r, s);
        buy_in[msg.sender] = 0;
        token.transferFrom(presale_addr, msg.sender, tokenAmount);
    }

    // 退款（未达到最小目标时）
    function refund() public {
        require(block.timestamp > end, "Presale not ended");
        require(buy_in[msg.sender] > 0, "No ETH to refund");
        require(totalRaised < presale_quantity / TOKENS_PER_ETH / 2, "Presale reached soft cap"); // 假设软顶为硬顶一半

        uint256 amount = buy_in[msg.sender];
        buy_in[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function withdraw() public {
        require(block.timestamp > end, "Presale not ended");
        require(msg.sender == presale_addr, "Only owner");
        require(totalRaised >= presale_quantity / TOKENS_PER_ETH / 2, "Below soft cap");
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");
        (bool success, ) = presale_addr.call{value: balance}("");
        require(success, "Withdrawal failed");
    }

    function estAmount(uint256 eths) public pure returns (uint256) {
        return (eths * TOKENS_PER_ETH) / 1 ether;
    }
}
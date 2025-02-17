pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function transferWithCallback(address recipient, uint256 amount) public returns (bool) {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");

        _transfer(msg.sender, recipient, amount);

        // 如果接收者是合约地址，则调用 tokensReceived 方法
        if (isContract(recipient)) {
            IERC20Receiver(recipient).tokensReceived(msg.sender, amount);
        }

        return true;
    }

    // 检查地址是否是合约地址
    function isContract(address addr) internal view returns (bool) {
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(addr)
        }
        return codeSize > 0;
    }
}

// 接收代币的合约需要实现此接口
interface IERC20Receiver {
    function tokensReceived(address from, uint256 amount) external;
}
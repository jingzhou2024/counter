// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingPool is ReentrancyGuard, Ownable {
    IERC20 public immutable RNT;    // 质押代币
    IERC20 public immutable esRNT;  // 奖励代币
    
    uint256 constant SECONDS_PER_DAY = 86400;
    uint256 constant LOCK_PERIOD = 30 days;
    uint256 constant REWARD_RATE = 1e18; // 每天每RNT奖励1 esRNT (假设18位小数)

    struct StakeInfo {
        uint256 amount;         // 质押数量
        uint256 lastUpdateTime; // 上次更新时间
        uint256 pendingRewards; // 未领取的奖励
    }

    struct VestingInfo {
        uint256 amount;         // 锁仓数量
        uint256 startTime;      // 开始时间
    }

    mapping(address => StakeInfo) public stakes;
    mapping(address => VestingInfo[]) public vestings;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardsClaimed(address indexed user, uint256 amount);
    event Vested(address indexed user, uint256 amount);
    event Redeemed(address indexed user, uint256 unlocked, uint256 burned);

    constructor(address _rnt, address _esrnt, address initialOwner) 
        Ownable(initialOwner) // 添加Ownable构造函数参数
    {
        RNT = IERC20(_rnt);
        esRNT = IERC20(_esrnt);
    }

    // 更新奖励
    function updateRewards(address user) internal {
        StakeInfo storage userStake = stakes[user]; // 使用不同的变量名
        if (userStake.amount > 0) {
            uint256 timeElapsed = block.timestamp - userStake.lastUpdateTime;
            uint256 newRewards = (userStake.amount * timeElapsed * REWARD_RATE) / SECONDS_PER_DAY / 1e18;
            userStake.pendingRewards += newRewards;
        }
        userStake.lastUpdateTime = block.timestamp;
    }

    // 质押
    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        
        updateRewards(msg.sender);
        
        StakeInfo storage userStake = stakes[msg.sender]; // 使用不同的变量名
        userStake.amount += amount;
        require(RNT.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        
        emit Staked(msg.sender, amount);
    }

    // 解押
    function unstake(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        StakeInfo storage userStake = stakes[msg.sender]; // 使用不同的变量名
        require(userStake.amount >= amount, "Insufficient staked amount");

        updateRewards(msg.sender);
        
        userStake.amount -= amount;
        require(RNT.transfer(msg.sender, amount), "Transfer failed");
        
        emit Unstaked(msg.sender, amount);
    }

    // 领取奖励
    function claimRewards() external nonReentrant {
        updateRewards(msg.sender);
        
        StakeInfo storage userStake = stakes[msg.sender];
        uint256 rewards = userStake.pendingRewards;
        require(rewards > 0, "No rewards to claim");
        
        userStake.pendingRewards = 0;
        require(esRNT.transfer(msg.sender, rewards), "Transfer failed");
        
        vestings[msg.sender].push(VestingInfo({
            amount: rewards,
            startTime: block.timestamp
        }));
        
        emit RewardsClaimed(msg.sender, rewards);
        emit Vested(msg.sender, rewards);
    }

    // 获取可赎回的RNT数量
    function getRedeemableAmount(address user) public view returns (uint256 unlocked, uint256 total) {
        VestingInfo[] storage userVestings = vestings[user];
        uint256 currentTime = block.timestamp;
        
        for (uint256 i = 0; i < userVestings.length; i++) {
            if (userVestings[i].amount > 0) {
                total += userVestings[i].amount;
                uint256 timeElapsed = currentTime - userVestings[i].startTime;
                
                if (timeElapsed >= LOCK_PERIOD) {
                    unlocked += userVestings[i].amount;
                } else {
                    uint256 unlockedPart = (userVestings[i].amount * timeElapsed) / LOCK_PERIOD;
                    unlocked += unlockedPart;
                }
            }
        }
    }

    // 赎回esRNT
    function redeem(uint256 amount) external nonReentrant {
        (uint256 unlocked, uint256 total) = getRedeemableAmount(msg.sender);
        require(total >= amount, "Insufficient vested amount");
        
        uint256 burnAmount = 0;
        uint256 redeemAmount = 0;
        
        if (amount <= unlocked) {
            redeemAmount = amount;
        } else {
            redeemAmount = unlocked;
            burnAmount = amount - unlocked;
        }

        // 更新vesting记录
        VestingInfo[] storage userVestings = vestings[msg.sender];
        uint256 remaining = amount;
        
        for (uint256 i = 0; i < userVestings.length && remaining > 0; i++) {
            if (userVestings[i].amount > 0) {
                if (userVestings[i].amount <= remaining) {
                    remaining -= userVestings[i].amount;
                    userVestings[i].amount = 0;
                } else {
                    userVestings[i].amount -= remaining;
                    remaining = 0;
                }
            }
        }

        // 转移代币
        require(esRNT.transferFrom(msg.sender, address(this), amount), "esRNT transfer failed");
        if (redeemAmount > 0) {
            require(RNT.transfer(msg.sender, redeemAmount), "RNT transfer failed");
        }
        
        emit Redeemed(msg.sender, redeemAmount, burnAmount);
    }

    // 查看质押信息
    function getStakeInfo(address user) external view returns (uint256 amount, uint256 rewards) {
        StakeInfo memory userStake = stakes[user]; // 使用不同的变量名
        uint256 pending = userStake.pendingRewards;
        if (userStake.amount > 0) {
            uint256 timeElapsed = block.timestamp - userStake.lastUpdateTime;
            pending += (userStake.amount * timeElapsed * REWARD_RATE) / SECONDS_PER_DAY / 1e18;
        }
        return (userStake.amount, pending);
    }
}
// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.19;

// interfaces of ERC20 token 
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns(bool);
    function transferFrom(address from, address to, uint256 amount) external returns(bool);
    function balanceOf(address account) external view returns(uint256);
}

contract StakingPool {

    IERC20 public stakingToken;     // the token users will stake

    address public admin;           // admin address (owner of hte contract)

    uint256 public rewardRatePerSecond;   // how much reward is given per second 

    // Info about each user who staked
    struct StakeInfo{ 
        uint256 amount;            // how many tokens user has staked 
        uint256 rewardDebt;        // rewards earned but not claimed yet 
        uint256 lastUpdated;       // last time user's rewards were updated 
    }

    // mapping of user address => their stake info 
    mapping (address => StakeInfo) public stakes;

    // reentrancy lock 
    mapping(address => bool) private _locked;

    // total tokens staked by all users 
    uint256 public totalStaked;

    // total reward tokens available to distributed 
    uint256 public rewardPool;

    // Events to helps track contract activity 
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount, uint256 reward);
    event RewardClaimed(address indexed user, uint256 reward);
    event PoolFunded(uint256 amount);

    // Reentrancy guard 
    modifier noReentrant() {
        require(!_locked[msg.sender], "Reentrancy not allowed");
        _locked[msg.sender] = true;
        _;
        _locked[msg.sender] = false;
    }

    // restrict function to only admin 
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin is allowed");
        _;
    }

    // set staking token and reward rate in consturctor 
    constructor(address _token, uint256 _rewardRatePerSecond) {
        stakingToken = IERC20(_token);
        rewardRatePerSecond = _rewardRatePerSecond;        
        admin = msg.sender;
    }

    // stake token into the contract
    function stake(uint256 _amount) external noReentrant {
        require(_amount > 0, "Amount must be > 0");

        _updateReward(msg.sender);   // first, update any rewards already earned 

        // transfer tokens from user to contract 
        bool success = stakingToken.transferFrom(msg.sender, address(this), _amount);
        require(success, "token transfer failed");

        // add tokens to user's stake 
        stakes[msg.sender].amount += _amount;
        stakes[msg.sender].lastUpdated = block.timestamp;
        totalStaked += _amount;

        emit Staked(msg.sender, _amount);
    }

    // Unstake your tokens 
    function unstake() external noReentrant {
        StakeInfo storage user = stakes[msg.sender];
        require(user.amount > 0, "Nothing to unstake");

        _updateReward(msg.sender);   // update any reward earned before unstaking 

        uint256 amountToUnstake = user.amount;
        uint256 reward = user.rewardDebt;

        // reset user's stake 
        user.amount = 0;
        user.rewardDebt = 0;
        user.lastUpdated = block.timestamp;
        totalStaked -= amountToUnstake;

        // return staked tokens to user 
        require(stakingToken.transfer(msg.sender, amountToUnstake), "Unstake Failed");

        // pay the rewards if pool has enough tokens 
        if (reward > 0 && rewardPool >= reward) {
            rewardPool -= reward;
            stakingToken.transfer(msg.sender, reward);
            emit RewardClaimed(msg.sender, reward);
        }

        emit Unstaked(msg.sender, amountToUnstake, reward);
    }

    // Claimed only the reward (without unstaking)
    function claimReward() external noReentrant {
        _updateReward(msg.sender);

        uint256 reward  = stakes[msg.sender].rewardDebt;
        require(reward > 0, "No reward to claim");
        require(rewardPool >= reward, "Not enough reward pool");

        stakes[msg.sender].rewardDebt = 0;
        rewardPool -= reward;
        stakingToken.transfer(msg.sender, reward);

        emit RewardClaimed(msg.sender, reward);
    }

    // admin can add tokens to the reward pool 
    function fundRewardPool(uint256 _amount) external onlyAdmin {
        require(_amount > 0, "Invalid amount");
        bool success = stakingToken.transferFrom(msg.sender, address(this), _amount);
        require (success, "funding fails");
        rewardPool += _amount;

        emit PoolFunded(_amount);
    }

    // internal function to calculate and update rewards 
    function _updateReward(address _user) internal {
        StakeInfo storage user = stakes[_user];

        // if the user has staked tokens, calculate reward
        if (user.amount > 0) {
            uint256 duration = block.timestamp - user.lastUpdated;

            // Reward = time x rate x staked amount (scaled to avoid overflow)
            uint256 reward = (duration * rewardRatePerSecond * user.amount) / 1e18;

            user.rewardDebt += reward;
        }

        // Update the last updated time 
        user.lastUpdated = block.timestamp;
    }

    // just check jow much pending reward 
    function pendingReward(address _user) external view returns (uint256) {
        StakeInfo memory user = stakes[_user];

        if (user.amount == 0 ) return user.rewardDebt;

        uint256 duration = block.timestamp - user.lastUpdated;
        uint256 reward = duration * rewardRatePerSecond * user.amount / 1e18;
        return user.rewardDebt + reward;
    }

    function getContractInfo() external view returns (
        uint256 _totalStaked,
        uint256 _rewardPool,
        uint256 _rewardRatePerSecond
    ) {
        return (totalStaked, rewardPool, rewardRatePerSecond);
    }
}

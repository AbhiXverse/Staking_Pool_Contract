// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/PoolToken.sol";
import "../src/StakingPool.sol";

contract StakingPoolTest is Test {
    PoolToken public token;
    StakingPool public stakingPool;
    
    address public admin;
    address public user1;
    address public user2;
    
    uint256 public constant INITIAL_SUPPLY = 1000 * 10**18;
    uint256 public constant REWARD_RATE_PER_SECOND = 1 * 10**15; // 0.001 tokens per second
    uint256 public constant STAKE_AMOUNT = 100 * 10**18;
    
    function setUp() public {
        admin = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
        // Deploy PoolToken
        token = new PoolToken();
        
        // Deploy StakingPool
        stakingPool = new StakingPool(address(token), REWARD_RATE_PER_SECOND);
        
        // Transfer tokens to users for testing
        token.transfer(user1, 200 * 10**18);
        token.transfer(user2, 200 * 10**18);
        
        // Fund the reward pool
        token.approve(address(stakingPool), 500 * 10**18);
        stakingPool.fundRewardPool(500 * 10**18);
    }
    
    function testInitialState() public {
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(stakingPool.admin(), admin);
        assertEq(stakingPool.rewardRatePerSecond(), REWARD_RATE_PER_SECOND);
        assertEq(stakingPool.totalStaked(), 0);
        assertEq(stakingPool.rewardPool(), 500 * 10**18);
    }
    
    function testStaking() public {
        vm.startPrank(user1);
        
        // Approve staking pool to spend tokens
        token.approve(address(stakingPool), STAKE_AMOUNT);
        
        // Stake tokens
        stakingPool.stake(STAKE_AMOUNT);
        
        // Check staking was successful
        (uint256 stakedAmount, uint256 rewardDebt, uint256 lastUpdated) = stakingPool.stakes(user1);
        assertEq(stakedAmount, STAKE_AMOUNT);
        assertEq(rewardDebt, 0);
        assertEq(lastUpdated, block.timestamp);
        assertEq(stakingPool.totalStaked(), STAKE_AMOUNT);
        
        vm.stopPrank();
    }
    
    function testRewardAccumulation() public {
        vm.startPrank(user1);
        
        // Approve and stake
        token.approve(address(stakingPool), STAKE_AMOUNT);
        stakingPool.stake(STAKE_AMOUNT);
        
        // Fast forward time by 1000 seconds
        vm.warp(block.timestamp + 1000);
        
        // Check pending rewards
        uint256 pending = stakingPool.pendingReward(user1);
        uint256 expectedReward = (1000 * REWARD_RATE_PER_SECOND * STAKE_AMOUNT) / 1e18;
        
        assertEq(pending, expectedReward);
        
        vm.stopPrank();
    }
    
    function testClaimReward() public {
        vm.startPrank(user1);
        
        // Stake tokens
        token.approve(address(stakingPool), STAKE_AMOUNT);
        stakingPool.stake(STAKE_AMOUNT);
        
        // Fast forward time
        vm.warp(block.timestamp + 1000);
        
        uint256 balanceBefore = token.balanceOf(user1);
        uint256 pendingBefore = stakingPool.pendingReward(user1);
        
        // Claim rewards
        stakingPool.claimReward();
        
        uint256 balanceAfter = token.balanceOf(user1);
        
        assertEq(balanceAfter - balanceBefore, pendingBefore);
        assertEq(stakingPool.pendingReward(user1), 0);
        
        vm.stopPrank();
    }
    
    function testUnstaking() public {
        vm.startPrank(user1);
        
        // Stake tokens
        token.approve(address(stakingPool), STAKE_AMOUNT);
        stakingPool.stake(STAKE_AMOUNT);
        
        // Fast forward time
        vm.warp(block.timestamp + 1000);
        
        uint256 balanceBefore = token.balanceOf(user1);
        uint256 pendingReward = stakingPool.pendingReward(user1);
        
        // Unstake
        stakingPool.unstake();
        
        uint256 balanceAfter = token.balanceOf(user1);
        
        // Should get back staked amount + rewards
        assertEq(balanceAfter - balanceBefore, STAKE_AMOUNT + pendingReward);
        assertEq(stakingPool.totalStaked(), 0);
        
        // Check stake info is reset
        (uint256 stakedAmount, uint256 rewardDebt,) = stakingPool.stakes(user1);
        assertEq(stakedAmount, 0);
        assertEq(rewardDebt, 0);
        
        vm.stopPrank();
    }
    
    function testMultipleUsers() public {
        // User1 stakes
        vm.startPrank(user1);
        token.approve(address(stakingPool), STAKE_AMOUNT);
        stakingPool.stake(STAKE_AMOUNT);
        vm.stopPrank();
        
        // Fast forward 500 seconds
        vm.warp(block.timestamp + 500);
        
        // User2 stakes
        vm.startPrank(user2);
        token.approve(address(stakingPool), STAKE_AMOUNT);
        stakingPool.stake(STAKE_AMOUNT);
        vm.stopPrank();
        
        // Fast forward another 500 seconds
        vm.warp(block.timestamp + 500);
        
        uint256 user1Pending = stakingPool.pendingReward(user1);
        uint256 user2Pending = stakingPool.pendingReward(user2);
        
        // User1 should have more rewards (staked for 1000 seconds total)
        // User2 should have less rewards (staked for 500 seconds only)
        assertGt(user1Pending, user2Pending);
        assertEq(stakingPool.totalStaked(), STAKE_AMOUNT * 2);
    }
    
    function testRevertWhenStakeZeroAmount() public {
        vm.startPrank(user1);
        token.approve(address(stakingPool), STAKE_AMOUNT);
        
        vm.expectRevert("Amount must be > 0");
        stakingPool.stake(0);
        
        vm.stopPrank();
    }
    
    function testRevertWhenUnstakeWithoutStaking() public {
        vm.startPrank(user1);
        
        vm.expectRevert("Nothing to unstake");
        stakingPool.unstake();
        
        vm.stopPrank();
    }
    
    function testRevertWhenClaimRewardWithoutStaking() public {
        vm.startPrank(user1);
        
        vm.expectRevert("No reward to claim");
        stakingPool.claimReward();
        
        vm.stopPrank();
    }
    
    function testOnlyAdminCanFundPool() public {
        vm.startPrank(user1);
        token.approve(address(stakingPool), 100 * 10**18);
        
        // This should fail because user1 is not admin
        vm.expectRevert("Only admin is allowed");
        stakingPool.fundRewardPool(100 * 10**18);
        
        vm.stopPrank();
    }
    
    function testGetContractInfo() public {
        // Stake some tokens first
        vm.startPrank(user1);
        token.approve(address(stakingPool), STAKE_AMOUNT);
        stakingPool.stake(STAKE_AMOUNT);
        vm.stopPrank();
        
        (uint256 totalStaked, uint256 rewardPool, uint256 rewardRate) = stakingPool.getContractInfo();
        
        assertEq(totalStaked, STAKE_AMOUNT);
        assertEq(rewardPool, 500 * 10**18);
        assertEq(rewardRate, REWARD_RATE_PER_SECOND);
    }
    
    function testPoolTokenMinting() public {
        uint256 mintAmount = 100 * 10**18;
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 balanceBefore = token.balanceOf(user1);
        
        // Only owner can mint
        token.mint(user1, mintAmount);
        
        assertEq(token.totalSupply(), totalSupplyBefore + mintAmount);
        assertEq(token.balanceOf(user1), balanceBefore + mintAmount);
    }
    
    function testRevertWhenNonOwnerMinting() public {
        vm.startPrank(user1);
        
        vm.expectRevert("only owner can mint");
        token.mint(user1, 100 * 10**18);
        
        vm.stopPrank();
    }
    
    function testTokenTransfer() public {
        uint256 transferAmount = 50 * 10**18;
        uint256 user1BalanceBefore = token.balanceOf(user1);
        uint256 user2BalanceBefore = token.balanceOf(user2);
        
        vm.startPrank(user1);
        token.transfer(user2, transferAmount);
        vm.stopPrank();
        
        assertEq(token.balanceOf(user1), user1BalanceBefore - transferAmount);
        assertEq(token.balanceOf(user2), user2BalanceBefore + transferAmount);
    }
    
    function testTokenApproveAndTransferFrom() public {
        uint256 transferAmount = 50 * 10**18;
        
        vm.startPrank(user1);
        token.approve(user2, transferAmount);
        vm.stopPrank();
        
        assertEq(token.allowance(user1, user2), transferAmount);
        
        uint256 user1BalanceBefore = token.balanceOf(user1);
        uint256 adminBalanceBefore = token.balanceOf(admin);
        
        vm.startPrank(user2);
        token.transferFrom(user1, admin, transferAmount);
        vm.stopPrank();
        
        assertEq(token.balanceOf(user1), user1BalanceBefore - transferAmount);
        assertEq(token.balanceOf(admin), adminBalanceBefore + transferAmount);
        assertEq(token.allowance(user1, user2), 0);
    }
    
    function testStakingPoolFunding() public {
        uint256 fundAmount = 100 * 10**18;
        uint256 poolBefore = stakingPool.rewardPool();
        
        token.approve(address(stakingPool), fundAmount);
        stakingPool.fundRewardPool(fundAmount);
        
        assertEq(stakingPool.rewardPool(), poolBefore + fundAmount);
    }
    
    function testRewardCalculationOverTime() public {
        vm.startPrank(user1);
        token.approve(address(stakingPool), STAKE_AMOUNT);
        stakingPool.stake(STAKE_AMOUNT);
        vm.stopPrank();
        
        uint256 startTime = block.timestamp;
        
        // Check rewards at different absolute time points
        uint256[] memory timePoints = new uint256[](4);
        timePoints[0] = startTime + 100;
        timePoints[1] = startTime + 500;
        timePoints[2] = startTime + 1000;
        timePoints[3] = startTime + 2000;
        
        for (uint i = 0; i < timePoints.length; i++) {
            vm.warp(timePoints[i]);
            uint256 pending = stakingPool.pendingReward(user1);
            uint256 timeElapsed = timePoints[i] - startTime;
            uint256 expected = (timeElapsed * REWARD_RATE_PER_SECOND * STAKE_AMOUNT) / 1e18;
            assertEq(pending, expected);
        }
    }
}

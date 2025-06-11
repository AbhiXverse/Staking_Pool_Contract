# Staking Pool Smart Contract

A decentralized staking pool smart contract built with Solidity that allows users to stake tokens, earn rewards over time, and manage their staking positions efficiently.

## 🚀 Features

- **Token Staking**: Users can stake their tokens to earn rewards
- **Reward Distribution**: Automatic reward calculation based on staking duration and amount
- **Pool Token System**: Mint pool-specific tokens for staking participants
- **Admin Controls**: Administrative functions for pool management and funding
- **Secure Operations**: Built-in security measures and access controls
- **Time-based Rewards**: Rewards accumulate over time based on staking duration

## 📋 Contract Overview

The staking pool consists of two main contracts:

### StakingPool Contract
- Main contract handling staking logic
- Manages user stakes and reward calculations
- Controls fund distribution and pool operations
- Implements admin-only functions for pool management

### PoolToken Contract
- ERC20-compatible token for the staking pool
- Minted to users who participate in staking
- Used for reward distribution and governance

## 🛠 Technology Stack

- **Solidity**: Smart contract development
- **Foundry**: Development framework and testing
- **OpenZeppelin**: Security and standard implementations
- **Forge**: Testing and deployment tools

## 📁 Project Structure

```
staking-pool/
├── src/
│   ├── StakingPool.sol      # Main staking contract
│   └── PoolToken.sol        # Pool token contract
├── test/
│   └── StakingPoolTest.sol  # Comprehensive test suite
├── script/
│   └── Deploy.s.sol         # Deployment scripts
├── foundry.toml             # Foundry configuration
└── README.md               # This documentation
```

## 🔧 Installation & Setup

### Prerequisites
- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Git
- Node.js (optional, for additional tooling)

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/staking-pool.git
   cd staking-pool
   ```

2. **Install dependencies**
   ```bash
   forge install
   ```

3. **Build the contracts**
   ```bash
   forge build
   ```

4. **Run tests**
   ```bash
   forge test -vv
   ```

## 🧪 Testing

The project includes a comprehensive test suite covering all major functionalities:

### Test Coverage

| Test Case | Description | Status |
|-----------|-------------|---------|
| `testInitialState()` | Verifies contract initialization | ✅ PASS |
| `testStaking()` | Tests basic staking functionality | ✅ PASS |
| `testUnstaking()` | Tests unstaking mechanism | ✅ PASS |
| `testClaimReward()` | Tests reward claiming | ✅ PASS |
| `testRewardAccumulation()` | Verifies reward calculation | ✅ PASS |
| `testRewardCalculationOverTime()` | Tests time-based rewards | ✅ PASS |
| `testMultipleUsers()` | Tests multi-user scenarios | ✅ PASS |
| `testStakingPoolFunding()` | Tests pool funding mechanism | ✅ PASS |
| `testPoolTokenMinting()` | Tests token minting | ✅ PASS |
| `testOnlyAdminCanFundPool()` | Tests admin-only functions | ✅ PASS |
| `testGetContractInfo()` | Tests contract information retrieval | ✅ PASS |
| `testTokenTransfer()` | Tests token transfer functionality | ✅ PASS |
| `testTokenApproveAndTransferFrom()` | Tests token approval mechanism | ✅ PASS |

### Error Handling Tests

| Test Case | Description | Status |
|-----------|-------------|---------|
| `testRevertWhenStakeZeroAmount()` | Prevents zero-amount staking | ✅ PASS |
| `testRevertWhenUnstakeWithoutStaking()` | Prevents unstaking without stake | ✅ PASS |
| `testRevertWhenClaimRewardWithoutStaking()` | Prevents reward claims without stake | ✅ PASS |
| `testRevertWhenNonOwnerMinting()` | Prevents unauthorized minting | ✅ PASS |

### Running Tests

```bash
# Run all tests with verbose output
forge test -vv

# Run specific test
forge test --match-test testStaking -vv

# Run tests with gas reporting
forge test --gas-report

# Run tests with coverage
forge coverage
```

### Latest Test Results
```
Ran 17 tests for test/StakingPoolTest.sol:StakingPoolTest
✅ All tests passed (17/17)
⏱ Total execution time: 794.12ms
📊 Gas usage optimized across all functions
```

## 📖 Usage Guide

### For Users

1. **Staking Tokens**
   ```solidity
   // Approve tokens first
   stakingToken.approve(stakingPoolAddress, amount);
   
   // Stake tokens
   stakingPool.stake(amount);
   ```

2. **Claiming Rewards**
   ```solidity
   // Check available rewards
   uint256 rewards = stakingPool.getReward(userAddress);
   
   // Claim rewards
   stakingPool.claimReward();
   ```

3. **Unstaking**
   ```solidity
   // Unstake tokens
   stakingPool.unstake(amount);
   ```

### For Administrators

1. **Fund the Pool**
   ```solidity
   // Fund pool with reward tokens
   stakingPool.fundPool(rewardAmount);
   ```

2. **Mint Pool Tokens**
   ```solidity
   // Mint tokens to users
   poolToken.mint(userAddress, amount);
   ```

## 🔒 Security Features

- **Access Control**: Admin-only functions protected
- **Input Validation**: All inputs validated for security
- **Reentrancy Protection**: Protected against reentrancy attacks
- **Safe Math**: Uses OpenZeppelin's safe math operations
- **Zero Amount Checks**: Prevents zero-value operations

## 📊 Contract Functions

### StakingPool Main Functions

| Function | Access | Description |
|----------|--------|-------------|
| `stake(uint256 amount)` | Public | Stake tokens to earn rewards |
| `unstake(uint256 amount)` | Public | Withdraw staked tokens |
| `claimReward()` | Public | Claim accumulated rewards |
| `getReward(address user)` | View | Get pending rewards for user |
| `fundPool(uint256 amount)` | Admin | Add funds to reward pool |

### PoolToken Functions

| Function | Access | Description |
|----------|--------|-------------|
| `mint(address to, uint256 amount)` | Owner | Mint new tokens |
| `transfer(address to, uint256 amount)` | Public | Transfer tokens |
| `approve(address spender, uint256 amount)` | Public | Approve token spending |

## 🚀 Deployment

### Local Deployment

1. **Start local blockchain**
   ```bash
   anvil
   ```

2. **Deploy contracts**
   ```bash
   forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --private-key YOUR_PRIVATE_KEY --broadcast
   ```

### Testnet Deployment

```bash
# Deploy to Sepolia testnet
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify

# Deploy to other testnets
forge script script/Deploy.s.sol --rpc-url $GOERLI_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```

## 🎯 Future Enhancements

- [ ] **Governance Token Integration**: Add governance features
- [ ] **Multiple Reward Tokens**: Support for multiple reward token types
- [ ] **Staking Tiers**: Implement different staking tiers with varying rewards
- [ ] **Lock-up Periods**: Add time-locked staking options
- [ ] **Emergency Withdraw**: Implement emergency withdrawal mechanisms
- [ ] **Rewards Multiplier**: Dynamic reward multipliers based on staking duration
- [ ] **Frontend Interface**: Web3 frontend for easy interaction

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/YOUR_USERNAME/staking-pool/issues) page
2. Create a new issue with detailed description
3. Join our community discussions

## 📞 Contact

- **Developer**: Abhishek
- **GitHub**: [@YOUR_USERNAME](https://github.com/YOUR_USERNAME)
- **Project Link**: [https://github.com/YOUR_USERNAME/staking-pool](https://github.com/YOUR_USERNAME/staking-pool)

---

## 🏆 Test Results Summary

```
Ran 17 tests for test/StakingPoolTest.sol:StakingPoolTest
[PASS] testClaimReward() (gas: 174896)
[PASS] testGetContractInfo() (gas: 123200)
[PASS] testInitialState() (gas: 32797)
[PASS] testMultipleUsers() (gas: 219312)
[PASS] testOnlyAdminCanFundPool() (gas: 45208)
[PASS] testPoolTokenMinting() (gas: 33016)
[PASS] testRevertWhenClaimRewardWithoutStaking() (gas: 60847)
[PASS] testRevertWhenNonOwnerMinting() (gas: 14953)
[PASS] testRevertWhenStakeZeroAmount() (gas: 65518)
[PASS] testRevertWhenUnstakeWithoutStaking() (gas: 36492)
[PASS] testRewardAccumulation() (gas: 124532)
[PASS] testRewardCalculationOverTime() (gas: 139221)
[PASS] testStaking() (gas: 123538)
[PASS] testStakingPoolFunding() (gas: 50577)
[PASS] testTokenApproveAndTransferFrom() (gas: 53943)
[PASS] testTokenTransfer() (gas: 35946)
[PASS] testUnstaking() (gas: 186928)

Suite result: ✅ ok. 17 passed; 0 failed; 0 skipped
Total time: 36.72ms (28.08ms CPU time)
```

**Made with ❤️ by Abhishek**


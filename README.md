# EigenLayer Restaking Contract

## Overview
This project implements a smart contract system for restaking Rocket Pool's rETH (Rocket Pool ETH) through EigenLayer, a protocol that enables restaking of staked ETH to secure additional protocols. The system allows users to deposit rETH, delegate it to operators, and manage withdrawals and rewards.

## Key Components

### 1. EigenLayerRestake Contract
The main contract that handles all restaking operations. It interacts with several EigenLayer components:

- **StrategyManager**: Manages staking strategies and share tracking
- **DelegationManager**: Handles operator delegation
- **RewardsCoordinator**: Manages reward distribution and claims

### 2. Core Functions

#### Deposit
```solidity
function deposit(uint256 rethAmount) external returns (uint256 shares)
```
- Transfers rETH from user to contract
- Approves StrategyManager to spend rETH
- Deposits rETH into EigenLayer strategy
- Returns shares received from deposit

#### Delegate
```solidity
function delegate(address operator) external auth
```
- Allows contract owner to delegate staked rETH to an operator
- Operator can perform actions on behalf of the staker
- Requires owner authorization

#### Undelegate
```solidity
function undelegate() external auth returns (bytes32[] memory withdrawalRoot)
```
- Removes delegation from current operator
- Automatically queues a withdrawal
- Returns withdrawal root for tracking

#### Withdraw
```solidity
function withdraw(address operator, uint256 shares, uint32 startBlockNum) external auth
```
- Withdraws staked rETH from operator after undelegation
- Requires waiting for withdrawal delay period
- Completes queued withdrawal process

#### Claim Rewards
```solidity
function claimRewards(IRewardsCoordinator.RewardsMerkleClaim memory claim) external
```
- Claims rewards for staked rETH
- Uses merkle proofs to verify reward claims
- Transfers claimed rewards to contract

### 3. Testing Framework

The project includes comprehensive tests in `test/EigenLayer.t.sol` that verify:

- Deposit functionality
- Delegation process
- Undelegation and withdrawal
- Reward claiming
- Authorization checks

### 4. Helper Contracts

#### RewardsHelper
A utility contract that assists with:
- Parsing reward claim data from JSON
- Setting up test environment for rewards
- Managing merkle proofs and claims

## Constants and Interfaces

The project uses several predefined constants and interfaces:

- **Token Addresses**: WETH, DAI, USDC, rETH
- **Protocol Addresses**: Rocket Pool, Chainlink, Balancer, Aura, Aave, Uniswap
- **EigenLayer Addresses**: Strategy Manager, Delegation Manager, Rewards Coordinator

## Security Features

1. **Authorization Checks**: All critical functions are protected with `auth` modifier
2. **Withdrawal Delays**: Implements protocol and strategy-specific withdrawal delays
3. **Merkle Proof Verification**: Secure reward claiming through merkle proofs

## Usage Flow

1. **Initial Setup**
   - Deploy EigenLayerRestake contract
   - Set up operator delegation

2. **Staking Process**
   - User deposits rETH
   - Contract delegates to operator
   - Operator manages staked assets

3. **Reward Management**
   - Rewards accumulate over time
   - Users can claim rewards using merkle proofs
   - Rewards are distributed to contract

4. **Withdrawal Process**
   - User undelegates from operator
   - Waits for withdrawal delay
   - Completes withdrawal to receive rETH

## Testing

The project uses Foundry for testing:
```bash
forge test --fork-url $FORK_URL --match-path test/EigenLayer.t.sol -vvv
```

Tests cover:
- Basic functionality
- Edge cases
- Authorization checks
- Reward claiming
- Withdrawal scenarios

## Dependencies

- Foundry for development and testing
- EigenLayer protocol contracts
- Rocket Pool rETH token
- Various DeFi protocol interfaces

## Security Considerations

1. Always verify operator addresses before delegation
2. Monitor withdrawal delays and timing
3. Ensure proper reward claim verification
4. Maintain secure key management for contract ownership

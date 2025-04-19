### 1. Core Functions

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

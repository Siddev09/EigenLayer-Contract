// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "../interface/IERC20.sol";
import {IStrategyManager} from "../interface/IStrategyManager.sol";
import {IStrategy} from "../interface/IStrategy.sol";
import {IDelegationManager} from "../interface/IDelegationManager.sol";
import {IRewardsCoordinator} from "../interface/IRewardsCoordinator.sol";
import {RETH, EIGEN_LAYER_STRATEGY_MANAGER, EIGEN_LAYER_STRATEGY_RETH, EIGEN_LAYER_DELEGATION_MANAGER, EIGEN_LAYER_REWARDS_COORDINATOR, EIGEN_LAYER_OPERATOR} from "./Constants.sol";
import {max} from "./Utils.sol";


contract EigenLayerRestake {
    IERC20 constant reth = IERC20(RETH);
    IStrategyManager constant strategyManager =
        IStrategyManager(EIGEN_LAYER_STRATEGY_MANAGER);
    IStrategy constant strategy = IStrategy(EIGEN_LAYER_STRATEGY_RETH);
    IDelegationManager constant delegationManager =
        IDelegationManager(EIGEN_LAYER_DELEGATION_MANAGER);
    IRewardsCoordinator constant rewardsCoordinator =
        IRewardsCoordinator(EIGEN_LAYER_REWARDS_COORDINATOR);

    address public owner;

    modifier auth() {
        require(msg.sender == owner, "not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }


    function deposit(uint256 rethAmount) external returns (uint256 shares) {
        reth.transferFrom(msg.sender, address(this), rethAmount);
        reth.approve(address(strategyManager), rethAmount);
        shares = strategyManager.depositIntoStrategy({
            strategy: address(strategy),
            token: RETH,
            amount: rethAmount
        });
    }


    function delegate(address operator) external auth {
        delegationManager.delegateTo({
            operator: operator,
            approverSignatureAndExpiry: IDelegationManager.SignatureWithExpiry({
                signature: "",
                expiry: 0
            }),
            approverSalt: bytes32(uint256(0))
        });
    }


    function undelegate()
        external
        auth
        returns (bytes32[] memory withdrawalRoot)
    {
        // Undelegating from an operator automatically queues a withdrawal
        withdrawalRoot = delegationManager.undelegate(address(this));
    }


    function withdraw(
        address operator,
        uint256 shares,
        uint32 startBlockNum
    ) external auth {
        address[] memory strategies = new address[](1);
        strategies[0] = address(strategy);

        uint256[] memory _shares = new uint256[](1);
        _shares[0] = shares;

        IDelegationManager.Withdrawal memory withdrawal = IDelegationManager
            .Withdrawal({
                staker: address(this),
                delegatedTo: operator,
                withdrawer: address(this),
                nonce: 0,
                startBlock: startBlockNum,
                strategies: strategies,
                shares: _shares
            });

        address[] memory tokens = new address[](1);
        tokens[0] = RETH;

        delegationManager.completeQueuedWithdrawal({
            withdrawal: withdrawal,
            tokens: tokens,
            middlewareTimesIndex: 0,
            receiveAsTokens: true
        });
    }

  
    function claimRewards(
        IRewardsCoordinator.RewardsMerkleClaim memory claim
    ) external {
        rewardsCoordinator.processClaim(claim, address(this));
    }

    /// @notice Get the number of shares held in the strategy for the current staker
    /// @return The number of shares held in the EigenLayer strategy
    function getShares() external view returns (uint256) {
        return
            strategyManager.stakerStrategyShares(
                address(this),
                address(strategy)
            );
    }


    function getWithdrawalDelay() external view returns (uint256) {
        uint256 protocolDelay = delegationManager.minWithdrawalDelayBlocks();

        address[] memory strategies = new address[](1);
        strategies[0] = address(strategy);
        uint256 strategyDelay = delegationManager.getWithdrawalDelay(
            strategies
        );

        return max(protocolDelay, strategyDelay);
    }

    function transfer(address token, address dst) external auth {
        IERC20(token).transfer(dst, IERC20(token).balanceOf(address(this)));
    }
}

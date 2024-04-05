// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

/*
* @title SABRE DAO ENGINE
* @author Ola Hamid

*/

import {SabreDAO} from "../src/SabreDAO.sol";

contract SabreDAOStaking {
    /////////////////
    //STATE VARIBLE///
    /////////////////
    SabreDAO public sabreDAO;
    uint256 public s_totalStakingSupply;
    uint256 public s_totalStakeableSupply;
    uint256 public s_rewardPerTokenStored;

    uint256 public reward_Rate = 100;
    uint256 public s_lastUpdate;

    //mappings
    mapping(address user => uint256 amount) public sm_balance;

    mapping(address user => uint256 amount) public s_UserRewardPerTokenPaid;

    mapping(address user => uint256 amount) public sm_reward;
    ////////////
    //error///
    /////////

    error e_NeedMoreZero();
    error e_StakingError();
    error e_unStakingError();
    error e_rewardClaimError();
    ///////////
    //modifier//
    ///////////

    modifier moreThanZero(uint256 amount) {
        if (amount <= 0) {
            revert e_NeedMoreZero();
        }
        _;
    }

    //update reward
    modifier updateReward(address account) {
        s_rewardPerTokenStored = rewardPerToken();
        s_lastUpdate = block.timestamp;
        sm_reward[msg.sender] = _earned(account);
        s_UserRewardPerTokenPaid[account] = s_rewardPerTokenStored;
        _;
    }

    ////////////
    //function//
    ////////////
    //f-stake
    function _stake(uint256 amountToStake) external virtual updateReward(msg.sender) moreThanZero(amountToStake) {
        sm_balance[msg.sender] += amountToStake;
        s_totalStakeableSupply += amountToStake;
        bool sucess = sabreDAO.transferFrom((msg.sender), address(this), amountToStake);
        if (!sucess) {
            revert e_StakingError();
        }
    }
    //f-earned

    function _earned(address account) public view returns (uint256) {
        uint256 currentBalance = sm_balance[account];
        uint256 amountPaid = s_UserRewardPerTokenPaid[account];
        uint256 currentRewardPerToken = rewardPerToken();
        uint256 pastRewards = sm_reward[account];
        uint256 earn = ((currentBalance * (currentRewardPerToken - amountPaid))) * 1 * 18 + pastRewards;
        return earn;
    }

    //f-unstake
    function _unStake(uint256 amountToUnstake) public virtual updateReward(msg.sender) {
        sm_balance[msg.sender] -= amountToUnstake;
        s_totalStakeableSupply -= amountToUnstake;
        bool sucess = sabreDAO.transfer(msg.sender, amountToUnstake);
        if (!sucess) {
            revert e_unStakingError();
        }
    }

    //f claimReward
    function _claimReward() public virtual updateReward(msg.sender) {
        uint256 Reward = sm_reward[msg.sender];
        bool success = sabreDAO.transfer(msg.sender, Reward);
        if (!success) {
            revert e_rewardClaimError();
        }
    }

    function _claimAndUnstake(uint256 amountToUnstake) public {
        _claimReward();
        _unStake(amountToUnstake);
    }

    //rewardPerToken
    function rewardPerToken() public view returns (uint256) {
        if (s_totalStakingSupply == 0) {
            return s_rewardPerTokenStored;
        } else {
            return (
                s_rewardPerTokenStored
                    + (((block.timestamp /*+*/ - s_lastUpdate) / (reward_Rate / 1 * 18))) / s_totalStakingSupply
            );
        }
    }

    function _getStake(address staker) external view returns (uint256) {
        return sm_balance[staker];
    }
}

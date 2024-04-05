// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0

// version
// imports
// interfaces, libraries, contracts
// errors
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
* @Aboout this is a sabreDAOToken contract to an ERC20 dao token, it is used to mint and burn funds, also transfer from other based projects to generate income, and main focus is to allow usser stay early and secure to all investment. 
 * This is an ERC20coin with the properties:
 * - ERC20 token minted  
 * - SabreDAO
 * - Algorithmically mint in funds.
 *
 * 
 *
 * @notice
*/
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Votes.sol";

// import {sabreDAOEngine} from "../src/SabreDAOEngine.sol";

contract SabreDAO is ERC20, Ownable, ERC20Permit, ERC20Votes {
    error e_burnError();
    error SBR_MustBeMoreThanZero();

    error SBR_NotZeroAddress();

    event TokenMinted(address indexed to, uint256 amount);
    event TokenBurned(address indexed from, uint256 amount);
    ///////////////////////////////////////////////////
    //////////////////////state variable///////////////
    ///////////////////////////////////////////////////

    /**
     * @audit-qa The name s_TotalSupply is a little confusing as there is not the token total supply:
     *               After constructor:
     *               sabreDAO.totalSupply()   = 60000000000000000000 (s_TotalSupply + keepTeamAmount)
     *               sabreDAO.s_TotalSupply() = 50000000000000000000
     */
    uint256 public s_TotalSupply = 50000000000000000000 wei; // 50 ether => 50 * 1e18
    uint256 public keepPeercentage = 20;

    address[] public a_TokenMinter;

    ///////////////////////////////////////////////////
    //////////////////////CONSTRUCTOR///////////////////
    ///////////////////////////////////////////////////
    constructor(address initialOwner) ERC20("SabreDAO", "SBR") Ownable(initialOwner) ERC20Permit("SabreDAO") {
        /**
         * @audit-qa it is not neccesary to add the "amount" variable, you can use  "s_TotalSupply"
         *           for _mint as is already inizialized.
         */
        uint256 amount = s_TotalSupply;
        /**
         * @audit-qa If keepPeercentage and s_TotalSupply known values, it is not neccesary this operation.
         *           uint256 KeepTeamAmount = 10 * 1e18;      => save gas
         */
        uint256 keepTeamAmount = (keepPeercentage * s_TotalSupply) / 100;
        _mint(msg.sender, amount);
        _mint(address(this), keepTeamAmount);
        /**
         * @audit-qa I can´t see a porpuse to add the owner to an array. He is the only minter.
         *           This is the only call to a_TokenMinter so it will be an array with 1 field.
         *           Maybe you call it in other contract?
         */
        a_TokenMinter.push(msg.sender);
    }

    function _burn(address to, uint256 amount) internal virtual override(ERC20) onlyOwner {
        /**
         * @audit-qa I had to set _mint and _burn functions as virtual in the Open Zeppelin ERC20 contract
         *           It is not usual, but maybe it is just because of contracts version
         *           If your contract compile correctly, it is ok
         * @audit-qa Remember: sabreDAO.totalSupply() != sabreDAO.s_TotalSupply()
         * @audit-qa amount < s_TotalSupply = error? => if amount > total Supply = error
         * @audit-qa As _burn is internal is not possible to burn any token.
         */
        if (amount < s_TotalSupply) {
            revert e_burnError();
        }
        super._burn(to, amount);
        emit TokenBurned(to, amount);
    }

    function _mint(address to, uint256 amount) internal virtual override(ERC20) onlyOwner {
        if (to == address(0)) {
            revert SBR_NotZeroAddress();
        }
        if (amount <= 0) {
            revert SBR_MustBeMoreThanZero();
        }
        super._mint(to, amount);
        emit TokenMinted(to, amount);
    }

    function _update(address from, address to, uint256 value) internal override(ERC20, ERC20Votes) onlyOwner {
        super._update(from, to, value);
    }

    function nonces(address owner) public view override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {Test, console} from "./../lib/forge-std/src/Test.sol";

import {SabreDAO} from "./../src/SabreDAO.sol";
import {SabreDAOStaking} from "./../src/SabreDAOStaking.sol";
import {SabreDAOEngine} from "./../src/SabreDAOEngine.sol";

contract SabreDAOTest is Test {
    ////////////////////
    //    USERS    /////
    ////////////////////

    address deployer = makeAddr("deployer");
    address user = makeAddr("user");

    ////////////////////////
    //    DATA/CONS    /////
    ////////////////////////

    ////////////////////
    // CONTRACTS   /////
    ////////////////////
    SabreDAO sabreDAO;
    SabreDAOStaking staking;
    SabreDAOEngine engine;

    ////////////////////
    // DEPLOY       /////
    ////////////////////

    function setUp() external {
        vm.startPrank(deployer);
        sabreDAO = new SabreDAO(deployer);
        staking = new SabreDAOStaking();
        engine = new SabreDAOEngine(1 ether, 1 ether, block.timestamp, 0, address(sabreDAO));

        // Transfer Ownership to engine:
        sabreDAO.transferOwnership(address(engine));
        assertEq(address(engine), sabreDAO.owner());
        vm.stopPrank();
    }

    function test_checkAddresses() external view {
        console.log("sabreDao: ", address(sabreDAO));
        console.log("real Total supply:      ", sabreDAO.totalSupply());
        assertEq(address(engine), sabreDAO.owner());
        console.log("Staking contract: ", address(staking));
        console.log("engine contract: ", address(engine));
    }

    //////////////////////////////
    // TESTS  FUNCIONALES     ///
    /////////////////////////////

    /*1. SABREDAO */

    function test_checkSimpleMint() external {
        vm.startPrank(address(engine));
        sabreDAO.mint(deployer, 50 * 1e18);
        assertEq(110 * 1e18, sabreDAO.totalSupply());
        assertEq(100 * 1e18, sabreDAO.balanceOf(deployer));
    }

    function test_checkSimpleBurn() external {
        vm.startPrank(deployer);
        sabreDAO.burn(10 * 1e18);
        assertEq(40 * 1e18, sabreDAO.balanceOf(deployer));
    }

    function test_burnMoreThanBalance() external {
        vm.startPrank(deployer);
        vm.expectRevert();
        sabreDAO.burn(1000 * 1e18);
    }

    function test_mintToAddressZero() external {
        vm.startPrank(address(engine));
        vm.expectRevert();
        sabreDAO.mint(address(0), 50 * 1e18);
    }

    /*1. SABREDAO */

    function test_stakeBasic() external {
        // 1. Mint tokens to user:
        vm.prank(address(engine));
        sabreDAO.mint(user, 1000 * 1e18);
        assertEq(1000 * 1e18, sabreDAO.balanceOf(user));
        assertEq(1060 * 1e18, sabreDAO.totalSupply());

        // 2. Aprove staking contract to spend the tokens:
        vm.startPrank(user);
        sabreDAO.approve(address(staking), 500 * 1e18);
        staking.stake(address(user), 500 * 1e18);
        vm.stopPrank();
        // vm.prank(address(staking));
        // sabreDAO.transferFrom(address(user), address(sabreDAO), 500 * 1e18);
    }
}

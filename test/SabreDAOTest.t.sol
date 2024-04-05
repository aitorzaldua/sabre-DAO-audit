// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {Test, console} from "./../lib/forge-std/src/Test.sol";

import {SabreDAO} from "./../src/SabreDAO.sol";

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

    ////////////////////
    // DEPLOY       /////
    ////////////////////

    function setUp() external {
        vm.prank(deployer);
        sabreDAO = new SabreDAO(deployer);
    }

    function test_checkAddresses() external view {
        console.log("sabreDao: ", address(sabreDAO));
        console.log("real Total supply:      ", sabreDAO.totalSupply());
        console.log("variable s_TotalSupply: ", sabreDAO.s_TotalSupply());
        assertEq(deployer, sabreDAO.owner());
    }

    //////////////////////////////
    // TESTS  FUNCIONALES     ///
    /////////////////////////////
    function test_checkMint() external {
        vm.startPrank(deployer);
        sabreDAO.mint(deployer, 50 ether);
        console.log("real Total supply:      ", sabreDAO.totalSupply());
        console.log("variable s_TotalSupply: ", sabreDAO.s_TotalSupply());
    }

    /* function test_checkBurn() external {
        vm.startPrank(deployer);
        sabreDAO.mint(deployer, 50 ether);

        sabreDAO.burn(deployer, 20 ether); */
}

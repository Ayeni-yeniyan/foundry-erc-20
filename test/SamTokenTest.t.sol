// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {SamToken} from "src/SamToken.sol";
import {DeployToken} from "script/DeployToken.s.sol";

contract SamTokenTest is Test {
    SamToken public samToken;
    DeployToken public deployToken;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployToken = new DeployToken();
        samToken = deployToken.run();

        vm.startBroadcast(msg.sender);
        samToken.transfer(bob, STARTING_BALANCE);
        vm.stopBroadcast();
    }

    function testBobBalance() public view {
        assertEq(STARTING_BALANCE, samToken.balanceOf(bob));
    }

    function testAllowanceWork() public {
        uint256 initialAllowance = 1000;

        // Bob approves alice to spend his money. Very risky behaviour
        vm.prank(bob);
        samToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;
        samToken.transferFrom(bob, alice, transferAmount);

        assertEq(samToken.balanceOf(alice), transferAmount);
        assertEq(samToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }
}

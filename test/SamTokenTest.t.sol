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
    address charlie = makeAddr("charlie");

    uint256 public constant STARTING_BALANCE = 100 ether;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function setUp() public {
        deployToken = new DeployToken();
        samToken = deployToken.run();

        vm.startPrank(msg.sender);
        samToken.transfer(bob, STARTING_BALANCE);
        // samToken.transfer(alice, STARTING_BALANCE);
        vm.stopPrank();
    }

    // Basic Balance Tests
    function testInitialBalances() public view {
        assertEq(
            samToken.balanceOf(bob),
            STARTING_BALANCE,
            "Bob's initial balance incorrect"
        );
    }

    // Transfer Tests
    function testTransfer() public {
        uint256 transferAmount = 50 ether;

        vm.prank(bob);
        bool success = samToken.transfer(charlie, transferAmount);

        assertTrue(success, "Transfer should succeed");
        assertEq(
            samToken.balanceOf(bob),
            STARTING_BALANCE - transferAmount,
            "Sender balance incorrect after transfer"
        );
        assertEq(
            samToken.balanceOf(charlie),
            transferAmount,
            "Recipient balance incorrect after transfer"
        );
    }

    function testTransferEmitsEvent() public {
        uint256 transferAmount = 50 ether;

        vm.prank(bob);
        vm.expectEmit(true, true, true, true);
        emit Transfer(bob, charlie, transferAmount);
        samToken.transfer(charlie, transferAmount);
    }

    function testCannotTransferMoreThanBalance() public {
        uint256 excessiveAmount = STARTING_BALANCE + 1;

        vm.prank(bob);
        vm.expectRevert(); // This will catch any revert, including custom errors
        samToken.transfer(charlie, excessiveAmount);
    }

    // Allowance and TransferFrom Tests
    function testApprove() public {
        uint256 allowanceAmount = 50 ether;

        vm.prank(bob);
        bool approved = samToken.approve(alice, allowanceAmount);

        assertTrue(approved, "Approval should succeed");
        assertEq(
            samToken.allowance(bob, alice),
            allowanceAmount,
            "Allowance not set correctly"
        );
    }

    function testApproveEmitsEvent() public {
        uint256 allowanceAmount = 50 ether;

        vm.prank(bob);
        vm.expectEmit(true, true, true, true);
        emit Approval(bob, alice, allowanceAmount);
        samToken.approve(alice, allowanceAmount);
    }

    function testTransferFrom() public {
        uint256 allowanceAmount = 50 ether;

        // Bob approves Alice to spend
        vm.prank(bob);
        samToken.approve(alice, allowanceAmount);

        // Alice transfers on Bob's behalf
        vm.prank(alice);
        bool success = samToken.transferFrom(bob, charlie, allowanceAmount);

        assertTrue(success, "TransferFrom should succeed");
        assertEq(
            samToken.balanceOf(bob),
            STARTING_BALANCE - allowanceAmount,
            "Bob's balance incorrect"
        );
        assertEq(
            samToken.balanceOf(charlie),
            allowanceAmount,
            "Charlie's balance incorrect"
        );
        assertEq(samToken.allowance(bob, alice), 0, "Allowance not reduced");
    }

    function testCannotTransferFromWithoutAllowance() public {
        uint256 transferAmount = 50 ether;

        vm.prank(alice);
        vm.expectRevert(); // This will catch ERC20InsufficientAllowance
        samToken.transferFrom(bob, charlie, transferAmount);
    }

    function testInfiniteAllowance() public {
        // Set infinite allowance
        vm.prank(bob);
        samToken.approve(alice, type(uint256).max);

        // Multiple transfers should work
        uint256 firstTransfer = 50 ether;
        uint256 secondTransfer = 25 ether;

        vm.prank(alice);
        samToken.transferFrom(bob, charlie, firstTransfer);

        vm.prank(alice);
        samToken.transferFrom(bob, charlie, secondTransfer);

        assertEq(
            samToken.balanceOf(charlie),
            firstTransfer + secondTransfer,
            "Total transfer amount incorrect"
        );
        // Allowance should remain max for infinite approval
        assertEq(
            samToken.allowance(bob, alice),
            type(uint256).max,
            "Infinite allowance modified"
        );
    }

    // Metadata Tests
    function testTokenMetadata() public view {
        assertEq(samToken.name(), "Samtoken", "Token name incorrect");
        assertEq(samToken.symbol(), "STK", "Token symbol incorrect");
        assertEq(samToken.decimals(), 18, "Token decimals incorrect");
    }
}

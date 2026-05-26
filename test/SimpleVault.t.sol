// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test} from "forge-std/Test.sol";
import {SimpleVault} from "../src/SimpleVault.sol";

contract SimpleVaultTest is Test {
    event SimpleVaultInitialized(uint256 minDepositAmount, address owner);
    event MinDepositAmountUpdated(uint256 newMinDepositAmount);
    event Deposit(address indexed user, uint256 amount);

    SimpleVault public simpleVault;

    uint256 public constant MIN_DEPOSIT_AMOUNT = 0.1 ether;
    uint256 public constant INITIAL_BALANCE = 1 ether;

    // Actors
    address public owner = vm.addr(1);
    address public alice = makeAddr("Alice");
    address public bob = makeAddr("Bob");

    function setUp() public {
        vm.prank(owner);
        simpleVault = new SimpleVault(MIN_DEPOSIT_AMOUNT);

        // Fund Alice and Bob with some Ether
        vm.deal(alice, INITIAL_BALANCE);
        vm.deal(bob, INITIAL_BALANCE);

        assertEq(alice.balance, INITIAL_BALANCE);
        assertEq(bob.balance, INITIAL_BALANCE);
    }

    /*//////////////////////////////////////////////////////////////
                               INIT TESTS
    //////////////////////////////////////////////////////////////*/

    function testInitialStateIsAsExpected() public {
        assertEq(simpleVault.owner(), owner);
        assertEq(simpleVault.minDepositAmount(), MIN_DEPOSIT_AMOUNT);

        assertEq(simpleVault.balances(alice), 0);
        assertEq(simpleVault.balances(bob), 0);
    }

    function testConstructorEmitsEvent() public {
        vm.expectEmit(false, false, false, true);
        emit SimpleVaultInitialized(MIN_DEPOSIT_AMOUNT, owner);
        vm.prank(owner);
        new SimpleVault(MIN_DEPOSIT_AMOUNT);
    }

    /*//////////////////////////////////////////////////////////////
                              ADMIN TESTS
    //////////////////////////////////////////////////////////////*/

    function testOwnerCanUpdateMinDepositAmount() public {
        uint256 newMinDepositAmount = 0.2 ether;

        assertEq(simpleVault.minDepositAmount(), MIN_DEPOSIT_AMOUNT);

        vm.prank(owner);
        simpleVault.setMinDepositAmount(newMinDepositAmount);

        assertEq(simpleVault.minDepositAmount(), newMinDepositAmount);
    }

    function testNonOwnerCannotSetMinDepositAmount() public {
        uint256 newDepositAmount = 0.2 ether;

        vm.prank(alice);
        vm.expectRevert("Only owner can call this function");
        simpleVault.setMinDepositAmount(newDepositAmount);
    }

    function testSetMinDepositAmountEmitsEvent() public {
        uint256 newMinDepositAmount = 0.2 ether;

        vm.expectEmit(false, false, false, true);
        emit MinDepositAmountUpdated(newMinDepositAmount);
        vm.prank(owner);
        simpleVault.setMinDepositAmount(newMinDepositAmount);
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function testDepositUpdatesBalance() public {
        assertEq(simpleVault.balances(alice), 0);

        vm.prank(alice);
        simpleVault.deposit{value: 0.5 ether}();

        assertEq(simpleVault.balances(alice), 0.5 ether);
    }
    function testCannotDepositLessThanMinDepositAmount() public {
        vm.prank(alice);
        vm.expectRevert("Deposit amount too low");
        simpleVault.deposit{value: MIN_DEPOSIT_AMOUNT - 0.01 ether}();
    }

    function testDepositEmitsEvent() public {
        uint256 depositAmount = 0.5 ether;

        vm.expectEmit(false, false, false, true);
        emit Deposit(alice, depositAmount);
        vm.prank(alice);
        simpleVault.deposit{value: depositAmount}();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { UserOperation } from "aa/interfaces/UserOperation.sol";

import { Vm } from "forge-std/Vm.sol";

import { ITokenPaymasterEvent, TokenPaymaster } from "contracts/TokenPaymaster.sol";
import { VoidAccount } from "contracts/VoidAccount.sol";
import { ERC20Mintable } from "contracts/token/ERC20Mintable.sol";

import { AATest } from "./utils/AATest.sol";

contract TokenPaymasterTest is AATest, ITokenPaymasterEvent {
    // Suppose token has 1:1 exchnage ratio to ETH
    ERC20Mintable token = new ERC20Mintable("ETH", "ETH");

    address account = address(new VoidAccount());
    address paymaster = address(new TokenPaymaster());

    function setUp() public {
        entryPoint.depositTo{ value: 1 ether }(paymaster);
    }

    function testCheckBalance() public {
        UserOperation memory userOp = createUserOp();
        userOp.sender = account;
        userOp.paymasterAndData = abi.encodePacked(paymaster, abi.encode(address(token)));

        expectRevertFailedOp("AA33 reverted: Sender has insufficient token balance");
        handleUserOp(userOp);
    }

    function testCollectToken() public {
        UserOperation memory userOp = createUserOp();

        uint256 maxCost = (userOp.callGasLimit + userOp.verificationGasLimit * 3 + userOp.preVerificationGas) *
            userOp.maxFeePerGas;

        // Mint token to account to pay for gas fee
        token.mint(account, maxCost);
        uint256 accountBalanceBefore = maxCost;

        // Approve paymaster to collect token from account
        vm.prank(account);
        token.approve(paymaster, maxCost);

        userOp.sender = account;
        userOp.paymasterAndData = abi.encodePacked(paymaster, abi.encode(address(token)));

        vm.recordLogs();
        handleUserOp(userOp);

        Vm.Log[] memory logs = vm.getRecordedLogs();
        Vm.Log memory postOp;
        for (uint8 i = 0; i < logs.length; i++) {
            if (logs[i].topics[0] == PostOp.selector) {
                postOp = logs[i];
                break;
            }
        }
        (, uint256 userOpGasCost) = abi.decode(postOp.data, (address, uint256));

        // Paymaster should collect back his prefund gas cost from account in token
        uint256 accountBalance = token.balanceOf(account);
        assertEq(accountBalance, accountBalanceBefore - userOpGasCost);

        uint256 paymasterBalance = token.balanceOf(paymaster);
        assertEq(paymasterBalance, userOpGasCost);
    }
}

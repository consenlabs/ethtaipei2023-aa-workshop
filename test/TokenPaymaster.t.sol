// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { UserOperation } from "aa/interfaces/UserOperation.sol";

import { Vm } from "forge-std/Vm.sol";

import { ITokenPaymasterEvent, TokenPaymaster } from "contracts/TokenPaymaster.sol";
import { VoidAccount } from "contracts/VoidAccount.sol";
import { ERC20Mintable } from "contracts/token/ERC20Mintable.sol";

import { AATest } from "./utils/AATest.sol";
import { Wallet, WalletLib } from "./utils/Wallet.sol";

contract TokenPaymasterTest is AATest, ITokenPaymasterEvent {
    using WalletLib for Wallet;

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

        token.mint(account, maxCost);
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
        (, uint256 cost) = abi.decode(postOp.data, (address, uint256));
        uint256 balance = token.balanceOf(paymaster);

        assertEq(balance, cost);
    }
}

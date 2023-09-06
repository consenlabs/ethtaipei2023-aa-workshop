// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IEntryPoint } from "aa/interfaces/IEntryPoint.sol";
import { UserOperation } from "aa/interfaces/UserOperation.sol";

import { SignatureAccount } from "contracts/SignatureAccount.sol";

import { AATest } from "./utils/AATest.sol";
import { Wallet, WalletLib } from "./utils/Wallet.sol";

contract SignatureAccountTest is AATest {
    using WalletLib for Wallet;

    Wallet owner = WalletLib.createRandomWallet(vm);
    address account = address(new SignatureAccount(entryPoint, owner.addr()));

    function setUp() public {
        entryPoint.depositTo{ value: 1 ether }(account);
        deal(account, 1 ether);
    }

    function testCannotExecuteUserOpSignedByOther() public {
        Wallet memory other = WalletLib.createRandomWallet(vm);

        // Transfer 1 ether from account signed by other
        UserOperation memory userOp = createUserOp();
        userOp.sender = account;
        userOp.callData = abi.encodeCall(SignatureAccount.execute, (other.addr(), 1 ether, bytes("")));
        signUserOp(other, userOp);

        UserOperation[] memory userOps = new UserOperation[](1);
        userOps[0] = userOp;

        vm.expectRevert(abi.encodeWithSelector(IEntryPoint.FailedOp.selector, 0, "AA24 signature error"));
        entryPoint.handleOps(userOps, payable(msg.sender));
    }

    function testExecuteUserOp() public {
        Wallet memory recipient = WalletLib.createRandomWallet(vm);

        // Transfer 1 ether from account signed by owner
        UserOperation memory userOp = createUserOp();
        userOp.sender = account;
        userOp.callData = abi.encodeCall(SignatureAccount.execute, (recipient.addr(), 1 ether, bytes("")));
        signUserOp(owner, userOp);

        UserOperation[] memory userOps = new UserOperation[](1);
        userOps[0] = userOp;

        entryPoint.handleOps(userOps, payable(msg.sender));

        assertEq(recipient.balance(), 1 ether);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { UserOperation } from "aa/interfaces/UserOperation.sol";

import { VoidAccount } from "contracts/VoidAccount.sol";

import { AATest } from "./utils/AATest.sol";
import { Wallet, WalletLib } from "./utils/Wallet.sol";

contract VoidAccountTest is AATest {
    Wallet owner = WalletLib.createRandomWallet(vm);
    address account = address(new VoidAccount());

    function testExecuteUserOp() public {
        address recipient = makeAddr("recipient");

        entryPoint.depositTo{ value: 1 ether }(account);
        deal(account, 1 ether);

        // Transfer 1 ether from account to recipient
        UserOperation memory userOp = createUserOp();
        userOp.sender = account;
        userOp.callData = abi.encodeWithSelector(VoidAccount.execute.selector, recipient, 1 ether, bytes(""));
        signUserOp(owner, userOp);

        UserOperation[] memory userOps = new UserOperation[](1);
        userOps[0] = userOp;

        entryPoint.handleOps(userOps, payable(msg.sender));

        assertEq(recipient.balance, 1 ether);
    }
}

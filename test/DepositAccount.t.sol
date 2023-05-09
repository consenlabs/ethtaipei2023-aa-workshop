// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { UserOperation } from "aa/interfaces/UserOperation.sol";

import { DepositAccount } from "contracts/DepositAccount.sol";

import { AATest } from "./utils/AATest.sol";
import { Wallet, WalletLib } from "./utils/Wallet.sol";

contract DepositAccountTest is AATest {
    using WalletLib for Wallet;

    address account = address(new DepositAccount(address(entryPoint)));

    function testExecuteUserOp() public {
        Wallet memory recipient = WalletLib.createRandomWallet(vm);

        // Gas fee + transfer amount
        deal(account, 2 ether);

        // Transfer 1 ether from account to recipient
        UserOperation memory userOp = createUserOp();
        userOp.sender = account;
        userOp.callData = abi.encodeWithSelector(
            DepositAccount.execute.selector,
            recipient.addr(),
            1 ether,
            bytes("")
        );

        UserOperation[] memory userOps = new UserOperation[](1);
        userOps[0] = userOp;

        entryPoint.handleOps(userOps, payable(msg.sender));

        assertEq(recipient.balance(), 1 ether);
    }
}

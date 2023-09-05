// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { UserOperation } from "aa/interfaces/UserOperation.sol";

import { InitCodeLib, SignatureAccount, SignatureAccountFactory } from "contracts/InitCode.sol";

import { AATest } from "./utils/AATest.sol";
import { Wallet, WalletLib } from "./utils/Wallet.sol";

contract InitCodeTest is AATest {
    using WalletLib for Wallet;

    SignatureAccountFactory factory = new SignatureAccountFactory(entryPoint);
    Wallet owner = WalletLib.createRandomWallet(vm);

    function testInitCode() public {
        uint256 salt = uint256(keccak256(abi.encodePacked(owner.privateKey)));
        address account = factory.getAccountAddress(salt, owner.addr());

        // Account should not be deployed yet
        assertEq(account.code.length, 0);

        Wallet memory recipient = WalletLib.createRandomWallet(vm);
        entryPoint.depositTo{ value: 1 ether }(account);
        deal(account, 1 ether);

        // Transfer 1 ether from account to recipient
        UserOperation memory userOp = createUserOp();
        userOp.sender = account;
        userOp.callData = abi.encodeCall(SignatureAccount.execute, (recipient.addr(), 1 ether, bytes("")));

        // Setup init code to deploy account before transfer
        userOp.initCode = InitCodeLib.pack(address(factory), salt, owner.addr());

        signUserOp(owner, userOp);

        UserOperation[] memory userOps = new UserOperation[](1);
        userOps[0] = userOp;

        entryPoint.handleOps(userOps, payable(msg.sender));

        // Verify account is deployed properly
        assertGt(account.code.length, 0);
        assertEq(SignatureAccount(account).owner(), owner.addr());

        assertEq(recipient.balance(), 1 ether);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { EntryPoint } from "aa/core/EntryPoint.sol";
import { UserOperation, UserOperationLib } from "aa/interfaces/UserOperation.sol";

import { Test } from "forge-std/Test.sol";

import { Wallet, WalletLib } from "./Wallet.sol";

abstract contract AATest is Test {
    using UserOperationLib for UserOperation;
    using WalletLib for Wallet;

    EntryPoint entryPoint = new EntryPoint();

    function createUserOp() internal pure returns (UserOperation memory) {
        return
            UserOperation({
                sender: address(0),
                nonce: 0,
                initCode: bytes(""),
                callData: bytes(""),
                callGasLimit: 999999,
                verificationGasLimit: 999999,
                preVerificationGas: 99999,
                maxFeePerGas: 20 gwei,
                maxPriorityFeePerGas: 1 gwei,
                paymasterAndData: bytes(""),
                signature: bytes("")
            });
    }

    function signUserOp(Wallet memory signer, UserOperation memory userOp) internal view {
        bytes32 userOpHash = this.getUserOpHash(userOp);
        (uint8 v, bytes32 r, bytes32 s) = signer.sign(userOpHash);
        userOp.signature = abi.encodePacked(r, s, v);
    }

    function getUserOpHash(UserOperation calldata userOp) public view returns (bytes32) {
        return keccak256(abi.encode(userOp.hash(), address(entryPoint), block.chainid));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { EntryPoint } from "aa/core/EntryPoint.sol";
import { IEntryPoint } from "aa/interfaces/IEntryPoint.sol";
import { UserOperation, UserOperationLib } from "aa/interfaces/UserOperation.sol";

import { Test } from "forge-std/Test.sol";
import { console } from "forge-std/console.sol";

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

    function handleUserOp(UserOperation memory userOp) internal {
        UserOperation[] memory ops = new UserOperation[](1);
        ops[0] = userOp;

        entryPoint.handleOps(ops, payable(msg.sender));
    }

    function expectRevertFailedOp(string memory reason) internal {
        vm.expectRevert(abi.encodeWithSelector(IEntryPoint.FailedOp.selector, 0, reason));
    }

    function signUserOp(Wallet memory signer, UserOperation memory userOp) internal view {
        bytes32 userOpHash = getUserOpHash(userOp);
        (uint8 v, bytes32 r, bytes32 s) = signer.sign(userOpHash);
        userOp.signature = abi.encodePacked(r, s, v);
    }

    function getUserOpHash(UserOperation memory userOp, address entrypoint) internal view returns (bytes32) {
        return this._getUserOpHash(userOp, entrypoint);
    }

    function getUserOpHash(UserOperation memory userOp) internal view returns (bytes32) {
        return this._getUserOpHash(userOp, address(entryPoint));
    }

    function _getUserOpHash(UserOperation calldata userOp, address entrypoint) public view returns (bytes32) {
        return keccak256(abi.encode(userOp.hash(), entrypoint, block.chainid));
    }

    function logUserOp(UserOperation memory userOp) internal view {
        console.log(userOp.sender);
        console.log(userOp.nonce);
        console.logBytes(userOp.initCode);
        console.logBytes(userOp.callData);
        console.log(toHexString(userOp.callGasLimit));
        console.log(toHexString(userOp.verificationGasLimit));
        console.log(toHexString(userOp.preVerificationGas));
        console.log(toHexString(userOp.maxFeePerGas));
        console.log(toHexString(userOp.maxPriorityFeePerGas));
        console.logBytes(userOp.paymasterAndData);
        console.logBytes(userOp.signature);
    }

    function toHexDigit(uint8 d) internal pure returns (bytes1) {
        if (0 <= d && d <= 9) {
            return bytes1(uint8(bytes1("0")) + d);
        } else if (10 <= uint8(d) && uint8(d) <= 15) {
            return bytes1(uint8(bytes1("a")) + d - 10);
        }
        revert("Invalid hex digit");
    }

    function toHexString(uint256 a) internal pure returns (string memory) {
        uint count = 0;
        uint b = a;
        while (b != 0) {
            count++;
            b /= 16;
        }
        bytes memory res = new bytes(count);
        for (uint i = 0; i < count; ++i) {
            b = a % 16;
            res[count - i - 1] = toHexDigit(uint8(b));
            a /= 16;
        }
        return string.concat("0x", string(res));
    }
}

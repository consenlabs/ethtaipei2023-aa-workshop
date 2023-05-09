// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";

import "oz/utils/cryptography/ECDSA.sol";

import "aa/interfaces/UserOperation.sol";
import { IEntryPoint } from "aa/interfaces/IEntryPoint.sol";

import { NonStandardAccount } from "../../contracts/bundler/NonStandardAccount.sol";

import { AATest } from "../utils/AATest.sol";

contract BuildUserOp is AATest {
    address immutable entryPointAddr =
        0x0576a174D229E3cFA37253523E645A78A0C91B57;
    address account = vm.envAddress("ACCOUNT_ADDR");

    // Signature does not matter here since we will truncate it when signing
    UserOperation userOpTemplate =
        UserOperation({
            sender: address(0),
            nonce: 0,
            initCode: bytes(""),
            callData: bytes(""),
            callGasLimit: 43000,
            verificationGasLimit: 210000,
            preVerificationGas: 52000,
            maxFeePerGas: 15 gwei,
            maxPriorityFeePerGas: 1 gwei,
            paymasterAndData: bytes(""),
            signature: bytes("")
        });

    function testBundlerDemo() public {
        // This userOp calldata sends 1 wei of ether to burning address
        address transferTo = 0x000000000000000000000000000000000000dEaD;
        uint256 transferAmount = 1 wei;
        bytes memory userOpCalldata = abi.encodeWithSignature(
            "execute(address,uint256,bytes)",
            transferTo,
            transferAmount,
            bytes("")
        );
        userOpTemplate.sender = account;
        userOpTemplate.callData = userOpCalldata;

        // Sign the userOp data
        bytes32 userOpHash = getUserOpHash(userOpTemplate, entryPointAddr);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            vm.envUint("PRIVATE_KEY"),
            ECDSA.toEthSignedMessageHash(userOpHash)
        );
        userOpTemplate.signature = abi.encodePacked(r, s, v);

        // Call userOp from entryPoint contract
        UserOperation[] memory ops = new UserOperation[](1);
        ops[0] = userOpTemplate;
        IEntryPoint(entryPointAddr).handleOps(ops, payable(msg.sender));

        logUserOp(userOpTemplate);
    }
}

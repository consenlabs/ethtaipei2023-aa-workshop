// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "oz/utils/cryptography/ECDSA.sol";

import "aa/interfaces/UserOperation.sol";
import { IEntryPoint } from "aa/interfaces/IEntryPoint.sol";

import { NonStandardAccount } from "../../contracts/session-4-bundler-demo/NonStandardAccount.sol";

import { Helpers, HelperIAccount } from "./Helpers.sol";

contract BuildUserOp is Test {
    // StackUp v0.6.0 bundler entryPoint
    // address immutable entryPointAddr = 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789;

    address immutable entryPointAddr = 0x0576a174D229E3cFA37253523E645A78A0C91B57;
    address walletOwner = vm.rememberKey(vm.envUint("PRIVATE_KEY"));
    address walletAccount = 0xeA719F4872F731AFD69B4fC1649349941230e6a7;

    Helpers helpers = new Helpers();

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
            maxFeePerGas: 5 gwei,
            maxPriorityFeePerGas: 1 gwei,
            paymasterAndData: bytes(""),
            signature: bytes("")
        });

    function testBundlerDemo() public {
        // This userOp calldata sends 1 gwei of Matic to Mumbai's burning address
        address transferTo = 0x000000000000000000000000000000000000dEaD;
        uint256 transferAmount = 1 gwei;
        bytes memory userOpCalldata = abi.encodeWithSignature(
            "execute(address,uint256,bytes)",
            transferTo,
            transferAmount,
            bytes("")
        );
        userOpTemplate.sender = walletAccount;
        userOpTemplate.callData = userOpCalldata;
        userOpTemplate.nonce = HelperIAccount(walletAccount).nonce();

        // Sign the userOp data
        bytes32 userOpHash = helpers.getUserOpHashFromMemory(
            abi.encode(0, userOpTemplate),
            entryPointAddr,
            block.chainid
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(vm.envUint("PRIVATE_KEY"), ECDSA.toEthSignedMessageHash(userOpHash));
        userOpTemplate.signature = abi.encodePacked(r, s, v);

        // Call userOp from entryPoint contract
        UserOperation[] memory ops = new UserOperation[](1);
        ops[0] = userOpTemplate;
        IEntryPoint(entryPointAddr).handleOps(ops, payable(walletOwner));

        helpers.logUserOp(userOpTemplate);
    }
}

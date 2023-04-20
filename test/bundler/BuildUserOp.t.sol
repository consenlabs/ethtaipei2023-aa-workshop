// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "oz/utils/cryptography/ECDSA.sol";

import "aa/interfaces/UserOperation.sol";
import { IEntryPoint } from "aa/interfaces/IEntryPoint.sol";

import { NonStandardAccount } from "../../contracts/bundler/NonStandardAccount.sol";

contract BuildUserOp is Test {
    address immutable entryPointAddr = 0x0576a174D229E3cFA37253523E645A78A0C91B57;
    address account = vm.envAddress("ACCOUNT_ADDR");

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
            maxFeePerGas: 10 gwei,
            maxPriorityFeePerGas: 1 gwei,
            paymasterAndData: bytes(""),
            signature: bytes("")
        });

    function testBundlerDemo() public {
        // This userOp calldata sends 0.01 gwei of ether to burning address
        address transferTo = 0x000000000000000000000000000000000000dEaD;
        uint256 transferAmount = 0.01 gwei;
        bytes memory userOpCalldata = abi.encodeWithSignature(
            "execute(address,uint256,bytes)",
            transferTo,
            transferAmount,
            bytes("")
        );
        userOpTemplate.sender = account;
        userOpTemplate.callData = userOpCalldata;
        userOpTemplate.nonce = HelperIAccount(account).nonce();

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
        IEntryPoint(entryPointAddr).handleOps(ops, payable(msg.sender));

        helpers.logUserOp(userOpTemplate);
    }
}

interface HelperIAccount {
    function nonce() external returns (uint256);
}

contract Helpers {
    function logUserOp(UserOperation memory userOp) public view {
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

    function getUserOpHashFromMemory(
        bytes memory data,
        address entryPoint,
        uint256 chainId
    ) public view returns (bytes32) {
        bytes32 hashedOp = _decodeThenPackOp(data);
        return keccak256(abi.encode(hashedOp, entryPoint, chainId));
    }

    function _decodeThenPackOp(bytes memory data) internal view returns (bytes32) {
        (, UserOperation memory userOp) = abi.decode(data, (uint256, UserOperation));
        return this.hash(userOp);
    }

    function hash(UserOperation calldata userOp) public pure returns (bytes32) {
        return keccak256(pack(userOp));
    }

    function pack(UserOperation calldata userOp) internal pure returns (bytes memory ret) {
        //lighter signature scheme. must match UserOp.ts#packUserOp
        bytes calldata sig = userOp.signature;
        // copy directly the userOp from calldata up to (but not including) the signature.
        // this encoding depends on the ABI encoding of calldata, but is much lighter to copy
        // than referencing each field separately.
        assembly {
            let ofs := userOp
            let len := sub(sub(sig.offset, ofs), 32)
            ret := mload(0x40)
            mstore(0x40, add(ret, add(len, 32)))
            mstore(ret, len)
            calldatacopy(add(ret, 32), ofs, len)
        }
    }

    function toHexDigit(uint8 d) internal pure returns (bytes1) {
        if (0 <= d && d <= 9) {
            return bytes1(uint8(bytes1("0")) + d);
        } else if (10 <= uint8(d) && uint8(d) <= 15) {
            return bytes1(uint8(bytes1("a")) + d - 10);
        }
        // revert("Invalid hex digit");
        revert();
    }

    function toHexString(uint256 a) public pure returns (string memory) {
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

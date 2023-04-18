// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "aa/interfaces/UserOperation.sol";
import "forge-std/console.sol";

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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IAccount } from "aa/interfaces/IAccount.sol";
import { UserOperation } from "aa/interfaces/UserOperation.sol";

import { Create2 } from "oz/utils/Create2.sol";

import { SignatureAccount } from "./SignatureAccount.sol";

library InitCodeLib {
    function pack(address factory, uint256 salt, address owner) internal pure returns (bytes memory initCode) {
        // TODO: Implement this method to pass the tests in test/InitCode.t.sol
        //
        // With account factory, we can deploy account along with the first user operation.
        // Please try to pack proper `initCode` bytes to deploy `SignatureAccount` through `SignatureAccountFactory`.
        //
        // HINT:
        // (1) First 20 bytes of the init code should be the address of account factory.
        // (2) Right after the first 20 bytes, it should concat with function selector and arguments of the `createAccount` function on `SignatureAccountFactory`.
        // (3) There are two useful abi utils: `abi.encodePacked` and `abi.encodeWithSelector`.
        initCode = bytes("");
    }
}

contract SignatureAccountFactory {
    address public entryPoint;

    constructor(address _entryPoint) {
        entryPoint = _entryPoint;
    }

    function createAccount(uint256 salt, address owner) public returns (SignatureAccount) {
        address account = getAccountAddress(salt, owner);
        if (account.code.length > 0) {
            return SignatureAccount(account);
        }
        return new SignatureAccount{ salt: bytes32(salt) }(entryPoint, owner);
    }

    function getAccountAddress(uint256 salt, address owner) public view returns (address) {
        return
            Create2.computeAddress(
                bytes32(salt),
                keccak256(abi.encodePacked(type(SignatureAccount).creationCode, abi.encode(entryPoint, owner)))
            );
    }
}

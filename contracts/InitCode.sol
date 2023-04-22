// SPDX-License-Identifier: MIT
/* solhint-disable no-inline-assembly no-unused-vars */
pragma solidity 0.8.17;

import { IAccount } from "aa/interfaces/IAccount.sol";
import { UserOperation } from "aa/interfaces/UserOperation.sol";

import { Create2 } from "oz/utils/Create2.sol";

library InitCodeLib {
    function pack(address factory, uint256 salt, address owner) internal pure returns (bytes memory initCode) {
        // TODO: Implement this method to pass the tests in test/InitCode.t.sol
        //
        // With account factory, we can deploy account along with the first user operation.
        // Please try to pack proper `initCode` bytes to deploy `SampleAccount` through `SampleAccountFactory`.
        //
        // HINT:
        // (1) First 20 bytes of the init code should be the address of account factory.
        // (2) Right after the first 20 bytes, it should concat with function selector and arguments of the `createAccount` function on `SampleAccountFactory`.
        // (3) There are two useful abi utils: `abi.encodePacked` and `abi.encodeWithSelector`.
        initCode = abi.encodePacked(
            factory,
            abi.encodeWithSelector(SampleAccountFactory.createAccount.selector, salt, owner)
        );
    }
}

contract SampleAccountFactory {
    function createAccount(uint256 salt, address owner) public returns (SampleAccount) {
        address account = getAccountAddress(salt, owner);
        if (account.code.length > 0) {
            return SampleAccount(account);
        }
        return new SampleAccount{ salt: bytes32(salt) }(owner);
    }

    function getAccountAddress(uint256 salt, address owner) public view returns (address) {
        return
            Create2.computeAddress(
                bytes32(salt),
                keccak256(abi.encodePacked(type(SampleAccount).creationCode, abi.encode(owner)))
            );
    }
}

contract SampleAccount is IAccount {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function validateUserOp(
        UserOperation calldata /* userOp */,
        bytes32 /* userOpHash */,
        uint256 /* missingAccountFunds */
    ) external pure returns (uint256) {}

    function execute(address target, uint256 value, bytes calldata data) external {
        (bool success, bytes memory result) = target.call{ value: value }(data);
        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }
}

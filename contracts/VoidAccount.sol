// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IAccount } from "aa/interfaces/IAccount.sol";
import { UserOperation, UserOperationLib } from "aa/interfaces/UserOperation.sol";

import { console } from "forge-std/console.sol";

contract VoidAccount is IAccount {
    function validateUserOp(
        UserOperation calldata /* userOp */,
        bytes32 /* userOpHash */,
        uint256 /* missingAccountFunds */
    ) external pure returns (uint256 validationData) {
        return 0;
    }

    function execute(address target, uint256 value, bytes calldata data) external {
        (bool success, bytes memory result) = target.call{ value: value }(data);
        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }
}

// SPDX-License-Identifier: MIT
/* solhint-disable no-inline-assembly no-unused-vars */
pragma solidity 0.8.17;

import { IAccount } from "aa/interfaces/IAccount.sol";
import { UserOperation } from "aa/interfaces/UserOperation.sol";

contract DepositAccount is IAccount {
    address public entryPoint;

    constructor(address _entryPoint) {
        entryPoint = _entryPoint;
    }

    function validateUserOp(
        UserOperation calldata /* userOp */,
        bytes32 /* userOpHash */,
        uint256 missingAccountFunds
    ) external returns (uint256) {
        // TODO: Implement this method to pass the tests in test/DepositAccount.t.sol
        //
        // Account should deposit missing funds to EntryPoint to pay gas for the user operation.
        //
        // HINT: There are two possible ways to achieve this goal:
        // (1) Send ETH directly to EntryPoint
        // (2) Call `depositTo` on EntryPoint
        // Check out the EntryPoint contract: https://github.com/eth-infinitism/account-abstraction/blob/develop/contracts/core/EntryPoint.sol
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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/* solhint-disable no-inline-assembly no-unused-vars */

import { IAccount } from "aa/interfaces/IAccount.sol";
import { IEntryPoint } from "aa/interfaces/IEntryPoint.sol";
import { UserOperation } from "aa/interfaces/UserOperation.sol";

contract DepositAccount is IAccount {
    IEntryPoint public entryPoint;

    constructor(IEntryPoint _entryPoint) {
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
        //
        // (1) Send ETH directly to EntryPoint
        // * Sending ETH in Solidity: https://solidity-by-example.org/sending-ether/
        // * Convert interface to address payable, for example, `payable(address(entryPoint))`
        //
        // (2) Call `depositTo` on EntryPoint
        // * Check out the EntryPoint interface: https://github.com/eth-infinitism/account-abstraction/blob/dae9733bf78bcb7576f572d67497c2d241ae4da1/contracts/interfaces/IStakeManager.sol#L76-L80
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

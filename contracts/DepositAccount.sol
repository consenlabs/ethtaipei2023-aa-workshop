// SPDX-License-Identifier: MIT
/* solhint-disable no-inline-assembly no-unused-vars */
pragma solidity 0.8.17;

import { IAccount } from "aa/interfaces/IAccount.sol";
import { IEntryPoint } from "aa/interfaces/IEntryPoint.sol";
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

        // Only EntryPoint can trigger this function to send missing funds
        require(msg.sender == entryPoint, "DepositAccount: Not from EntryPoint");

        // (1) Send ETH directly to EntryPoint
        //
        // Note that it cannot use `send` or `transfer` to deposit missing funds,
        // because these two calls limit gas to only 2,300.
        // 
        // Although 2,300 gas is enough for plain transfer, EntryPoint needs extra operations 
        // to update its deposit balance storage upon receiving the fund.
        // (https://github.com/eth-infinitism/account-abstraction/blob/9b5f2e4bb30a81aa30761749d9e2e43fee64c768/contracts/core/StakeManager.sol#L35-L37)
        (bool success, ) = payable(entryPoint).call{value : missingAccountFunds }("");
        // Ignore failure because its EntryPoint's job to verify.
        (success); 

        // (2) Call `depositTo` on EntryPoint
        // IEntryPoint(entryPoint).depositTo{ value: missingAccountFunds }(address(this));

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

// SPDX-License-Identifier: MIT
/* solhint-disable no-inline-assembly no-unused-vars */
pragma solidity 0.8.17;

import { IAccount } from "aa/interfaces/IAccount.sol";
import { UserOperation } from "aa/interfaces/UserOperation.sol";

import { ECDSA } from "oz/utils/cryptography/ECDSA.sol";

contract SignatureAccount is IAccount {
    uint256 internal constant SIG_VALIDATION_SUCCEEDED = 0;
    uint256 internal constant SIG_VALIDATION_FAILED = 1;

    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function validateUserOp(
        UserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 /* missingAccountFunds */
    ) external view returns (uint256 validationData) {
        // TODO: Implement this method to pass the tests in test/SignatureAccount.t.sol
        //
        // Account should verify `userOp.signature` against `userOpHash` to authorize executing the user operation.
        //
        // It should return `SIG_VALIDATION_FAILED` when signature is invalid,
        // and return `SIG_VALIDATION_SUCCEEDED` when signature is valid.
        //
        // HINT: OpenZeppelin `ECDSA` library has a `tryRecover(hash, signature)` function to recover the signature signer.

        return SIG_VALIDATION_SUCCEEDED;
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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IAccount } from "aa/interfaces/IAccount.sol";
import { UserOperation } from "aa/interfaces/UserOperation.sol";

import { ECDSA } from "oz/utils/cryptography/ECDSA.sol";

contract SignatureAccount is IAccount {
    uint256 internal constant SIG_VALIDATION_SUCCEEDED = 0;
    uint256 internal constant SIG_VALIDATION_FAILED = 1;

    address public entryPoint;
    address public owner;

    constructor(address _entryPoint, address _owner) {
        entryPoint = _entryPoint;
        owner = _owner;
    }

    function validateUserOp(
        UserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external returns (uint256 validationData) {
        require(msg.sender == entryPoint, "SignatureAccount: Not from EntryPoint");
        (bool success, ) = payable(entryPoint).call{ value: missingAccountFunds }("");
        (success);

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
        require(msg.sender == entryPoint, "SignatureAccount: Unauthorized caller");
        (bool success, bytes memory result) = target.call{ value: value }(data);
        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }
}

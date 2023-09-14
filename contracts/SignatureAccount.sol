// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/* solhint-disable no-inline-assembly no-unused-vars */

import { IAccount } from "aa/interfaces/IAccount.sol";
import { IEntryPoint } from "aa/interfaces/IEntryPoint.sol";
import { UserOperation } from "aa/interfaces/UserOperation.sol";

import { ECDSA } from "oz/utils/cryptography/ECDSA.sol";

contract SignatureAccount is IAccount {
    uint256 internal constant SIG_VALIDATION_SUCCEEDED = 0;
    uint256 internal constant SIG_VALIDATION_FAILED = 1;

    IEntryPoint public entryPoint;
    address public owner;

    constructor(IEntryPoint _entryPoint, address _owner) {
        entryPoint = _entryPoint;
        owner = _owner;
    }

    function validateUserOp(
        UserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external returns (uint256 validationData) {
        require(msg.sender == address(entryPoint), "SignatureAccount: Not from EntryPoint");
        (bool success, ) = payable(address(entryPoint)).call{ value: missingAccountFunds }("");
        (success);

        // TODO: Implement this method to pass the tests in test/SignatureAccount.t.sol
        //
        // Account should verify `userOp.signature` against `userOpHash` to authorize executing the user operation.
        //
        // Please:
        // (1) Return `SIG_VALIDATION_FAILED` when signature is invalid,
        // (2) Return `SIG_VALIDATION_SUCCEEDED` when signature is valid.
        //
        // HINT:
        // (1) OpenZeppelin `ECDSA` library, already import for you at top, has a `recover(hash, signature)` function to get the signer of signature.
        // * For example: `address signer = ECDSA.recover(hash, signature)`
        // * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/0a25c1940ca220686588c4af3ec526f725fe2582/contracts/utils/cryptography/ECDSA.sol#L74-L92
        // (2) Check if signer is the account owner
        address signer = ECDSA.recover(userOpHash, userOp.signature);
        if (signer != owner) {
            return SIG_VALIDATION_FAILED;
        }
        return SIG_VALIDATION_SUCCEEDED;
    }

    function execute(address target, uint256 value, bytes calldata data) external {
        require(msg.sender == address(entryPoint), "SignatureAccount: Unauthorized caller");
        (bool success, bytes memory result) = target.call{ value: value }(data);
        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }
}

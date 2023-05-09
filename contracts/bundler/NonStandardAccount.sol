// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { UserOperation } from "aa/interfaces/UserOperation.sol";
import { IAccount } from "aa/interfaces/IAccount.sol";

import { IERC20 } from "oz/token/ERC20/IERC20.sol";

contract NonStandardAccount is IAccount {
    uint256 internal constant SIG_VALIDATION_SUCCEEDED = 0;
    uint256 internal constant SIG_VALIDATION_FAILED = 1;
    address internal constant WETH = 0xf531B8F309Be94191af87605CfBf600D71C2cFe0;

    address public entryPoint;
    address public owner;
    uint96 private counter;

    constructor(address _entryPoint, address _owner) {
        entryPoint = _entryPoint;
        owner = _owner;
    }

    event BundlerTestCall(address associatedAddress, uint256 placeholder);

    function callAndIncrementCounter() internal returns (uint96) {
        counter++;
        return counter;
    }

    function validateUserOp(
        UserOperation calldata /*userOp*/,
        bytes32 /* userOpHash */,
        uint256 /* missingAccountFunds */
    ) external override returns (uint256 validationData) {
        // Should fail
        uint256 lastBalance = address(this).balance;
        emit BundlerTestCall(address(this), lastBalance);

        // Should fail
        uint256 nonSelfStorageERC20Call = IERC20(WETH).balanceOf(entryPoint);
        emit BundlerTestCall(entryPoint, nonSelfStorageERC20Call);

        // Should pass
        uint256 selfStorageERC20Call = IERC20(WETH).balanceOf(address(this));
        emit BundlerTestCall(address(this), selfStorageERC20Call);

        // Should pass
        uint256 selfStorageCall = callAndIncrementCounter();
        emit BundlerTestCall(address(this), selfStorageCall);

        // Omit signature validation and paying EntryPoint

        return SIG_VALIDATION_SUCCEEDED;
    }

    function execute(address target, uint256 value, bytes calldata data) external {
        require(msg.sender == entryPoint, "Unauthorized caller");
        (bool success, bytes memory result) = target.call{ value: value }(data);
        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }
}

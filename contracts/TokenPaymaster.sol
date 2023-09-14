// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IPaymaster } from "aa/interfaces/IPaymaster.sol";
import { UserOperation } from "aa/interfaces/UserOperation.sol";

import { IERC20 } from "oz/token/ERC20/IERC20.sol";

interface ITokenPaymasterEvent {
    event PostOp(address token, uint256 actualGasCost);
}

contract TokenPaymaster is IPaymaster, ITokenPaymasterEvent {
    function validatePaymasterUserOp(
        UserOperation calldata userOp,
        bytes32 /* userOpHash */,
        uint256 maxCost
    ) external returns (bytes memory context, uint256 validationData) {
        bytes memory data = userOp.paymasterAndData[20:];
        address token = abi.decode(data, (address));

        // TODO: Implement this method to pass the tests in test/TokenPaymaster.t.sol
        //
        // Paymaster should check sender's token balance to ensure he has enough
        // fund to pay back paymaster in the `postOp` step.
        //
        // Please revert with message "Sender has insufficient token balance"
        // when sender doesn't have enough token balance to pay the cost.
        // (Suppose token has 1:1 exchange ratio to ETH)
        //
        // HINT:
        // (1) Query balance of `userOp.sender` on token by `IERC20(token).balanceOf(userOp.sender)`.
        // * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/0a25c1940ca220686588c4af3ec526f725fe2582/contracts/token/ERC20/IERC20.sol#L29-L32
        // (2) Check balance is enough to cover `maxCost`.
        // (3) Revert when balance is not enough: `revert("Sender has insufficient token balance")`.

        return (abi.encode(userOp.sender, token), 0);
    }

    function postOp(PostOpMode /* mode */, bytes calldata context, uint256 actualGasCost) external {
        (address sender, address token) = abi.decode(context, (address, address));

        // TODO: Implement this method to pass the tests in test/TokenPaymaster.t.sol
        //
        // Paymaster should collect token from sender to cover his prefund gas fee.
        // (Suppose token has 1:1 exchange ratio to ETH)
        //
        // HINT:
        // (1) Use `IERC20(token).transferFrom(sender, address(this), amount)` to transfer `actualGasCost` token amount from sender to this paymaster.
        // * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/0a25c1940ca220686588c4af3ec526f725fe2582/contracts/token/ERC20/IERC20.sol#L68-L82

        emit PostOp(token, actualGasCost);
    }
}

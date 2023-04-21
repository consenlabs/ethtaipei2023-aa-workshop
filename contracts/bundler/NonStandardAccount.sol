// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "oz/utils/cryptography/ECDSA.sol";
import "oz/token/ERC20/IERC20.sol";
import { BaseAccount } from "aa/core/BaseAccount.sol";
import { UserOperation } from "aa/interfaces/UserOperation.sol";
import { IEntryPoint } from "aa/interfaces/IEntryPoint.sol";

interface INonStandardAccount {
    function nonce() external returns (uint256);
}

contract NonStandardAccount is BaseAccount {
    event bundlerTestCall(address associatedAddress, uint256 placeholder);

    using ECDSA for bytes32;

    address public immutable owner;
    IEntryPoint private immutable _entryPoint;

    uint96 private _nonce;

    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}

    constructor(IEntryPoint anEntryPoint, address _owner) {
        _entryPoint = anEntryPoint;
        owner = _owner;
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() internal view {
        //directly from EOA owner
        require(msg.sender == owner, "only owner");
    }

    // Require the function call went through EntryPoint or owner
    function _requireFromEntryPointOrOwner() internal view {
        require(msg.sender == address(entryPoint()) || msg.sender == owner, "account: not Owner or EntryPoint");
    }

    /// @inheritdoc BaseAccount
    function nonce() public view virtual override returns (uint256) {
        return _nonce;
    }

    /// @inheritdoc BaseAccount
    function entryPoint() public view virtual override returns (IEntryPoint) {
        return _entryPoint;
    }

    /// implement template method of BaseAccount
    function _validateAndUpdateNonce(UserOperation calldata userOp) internal override {
        require(_nonce++ == userOp.nonce, "account: invalid nonce");
    }

    /// implement template method of BaseAccount
    function _validateSignature(
        UserOperation calldata userOp,
        bytes32 /*userOpHash*/
    ) internal virtual override returns (uint256 validationData) {
        // Should fail
        uint256 lastBalance = address(this).balance;
        emit bundlerTestCall(address(this), lastBalance);

        // Should fail
        uint256 shoudlNotPassCall = IERC20(0xf531B8F309Be94191af87605CfBf600D71C2cFe0).balanceOf(address(entryPoint()));
        emit bundlerTestCall(address(entryPoint()), shoudlNotPassCall);

        // Should pass
        uint256 selfStorageERC20Call = IERC20(0xf531B8F309Be94191af87605CfBf600D71C2cFe0).balanceOf(address(this));
        emit bundlerTestCall(address(this), selfStorageERC20Call);

        // Should pass
        uint256 selfStorageNonceCall = this.nonce();
        emit bundlerTestCall(address(this), selfStorageNonceCall);

        // To prevent bad actors transferring all the balance
        (, uint256 value, ) = abi.decode(userOp.callData[4:], (address, uint256, bytes));
        if (value > 2 wei) {
            revert("This account is for demo purpose, please don't transfer large funds out from this account...");
        }

        // Returns 0 anyway so everyone can pass signature validation
        // (Optional) TODO: Add some verification logic here so only wallet owner can use this account
        return 0;
    }

    /**
     * execute a transaction
     */
    function execute(address dest, uint256 value, bytes calldata func) external {
        _requireFromEntryPointOrOwner();
        _call(dest, value, func);
    }

    function _call(address target, uint256 value, bytes memory data) internal {
        (bool success, bytes memory result) = target.call{ value: value }(data);
        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }

    /**
     * check current account deposit in the entryPoint
     */
    function getDeposit() public view returns (uint256) {
        return entryPoint().balanceOf(address(this));
    }

    /**
     * deposit more funds for this account in the entryPoint
     */
    function addDeposit() public payable {
        entryPoint().depositTo{ value: msg.value }(address(this));
    }

    /**
     * withdraw value from the account's deposit
     * @param withdrawAddress target to send to
     * @param amount to withdraw
     */
    function withdrawDepositTo(address payable withdrawAddress, uint256 amount) public onlyOwner {
        entryPoint().withdrawTo(withdrawAddress, amount);
    }
}

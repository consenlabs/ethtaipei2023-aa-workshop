// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Script.sol";

import "aa/interfaces/IEntryPoint.sol";
import { NonStandardAccount } from "../../contracts/bundler/NonStandardAccount.sol";

contract Deploy is Script {
    // Account that sends deployment tx, needs to have funds for paying contract creation
    address deployer = vm.rememberKey(vm.envUint("PRIVATE_KEY"));
    // The owner account (an EOA account) of the deployed 4337 account
    // Use an account that is under your control, we will need this account's private key to sign userOperation.
    address ownerAccount = vm.envAddress("ACCOUNT_OWNER_ADDR");

    address immutable entryPoint = 0x0576a174D229E3cFA37253523E645A78A0C91B57;

    // Deploys contract NonStandardAccount at contracts/bundler/NonStandardAccount.sol
    // then deposits 0.01 ether for the account from deployer
    function run() public {
        vm.startBroadcast(deployer);

        NonStandardAccount account = new NonStandardAccount(ownerAccount);
        console.log("Deployed account address:", address(account));

        (bool success, ) = entryPoint.call{ value: 0.01 ether }(
            abi.encodeWithSignature("depositTo(address)", address(account))
        );
        require(success);
    }
}

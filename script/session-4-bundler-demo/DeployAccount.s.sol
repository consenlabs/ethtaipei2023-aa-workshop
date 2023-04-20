// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Script.sol";

import "aa/interfaces/IEntryPoint.sol";
import { NonStandardAccount } from "../../contracts/session-4-bundler-demo/NonStandardAccount.sol";

contract DeployAccount is Script {
    // Account that sends deployment tx, needs to have funds for paying contract creation
    address deployer = vm.rememberKey(vm.envUint("PRIVATE_KEY"));
    // The owner account (an EOA account) of the deployed 4337 account
    // Use an account that is under your control, we will need this account's private key to sign userOperation.
    address ownerAccount = vm.envAddress("ACCOUNT_OWNER_ADDR");

    function run() public {
        vm.startBroadcast(deployer);

        NonStandardAccount account = new NonStandardAccount(
            IEntryPoint(0x0576a174D229E3cFA37253523E645A78A0C91B57),
            ownerAccount
        );
        console.log("Deployed account address:", address(account));
    }
}

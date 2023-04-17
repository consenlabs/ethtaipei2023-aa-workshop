// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Script.sol";

import "aa/interfaces/IEntryPoint.sol";
import { NonStandardAccount } from "../../contracts/session-4-bundler-demo/NonStandardAccount.sol";

contract DeployAccount is Script {
    address deployer = vm.rememberKey(vm.envUint("PRIVATE_KEY"));

    function run() public {
        vm.startBroadcast(deployer);

        NonStandardAccount account = new NonStandardAccount(
            IEntryPoint(0x0576a174D229E3cFA37253523E645A78A0C91B57),
            0xE82493656F31dAC3c839fa93449Ee4F21Fdd05b7
        );

        console.log("Deployed account address:", address(account));
    }
}

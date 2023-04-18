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
            // StackUp bundler entryPoint
            // IEntryPoint(0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789),
            IEntryPoint(0x0576a174D229E3cFA37253523E645A78A0C91B57),
            // This adddress is the owner of wallet account,
            // replace an EOA account that is under your control (e.g. you have its private key)
            0xE82493656F31dAC3c839fa93449Ee4F21Fdd05b7
        );

        console.log("Deployed account address:", address(account));
    }
}

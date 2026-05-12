// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Demo} from "../src/Demo.sol";

contract DeployDemoScript is Script {
    Demo public demo;

    function run() public {
        vm.startBroadcast();

        demo = new Demo();

        vm.stopBroadcast();
    }
}

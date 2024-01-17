// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {SphinxConfig} from './SphinxConfig.sol';
import {QuestContractConstants as C} from "../contracts/libraries/QuestContractConstants.sol";

contract ProxyAdminDeploy is Script, SphinxConfig {
    function run() external sphinx {
        bytes memory data = vm.parseJsonBytes(vm.readFile("script/deployDataBytes.json"), "$.proxyAdminImpl");

        // Deploy ProxyAdmin
        (bool success,) = C.DETERMINISTIC_DEPLOY_PROXY.call(data);
        require(success, "failed to deploy ProxyAdmin");
    }
}

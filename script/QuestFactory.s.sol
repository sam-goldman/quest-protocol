// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {SphinxConfig} from "./SphinxConfig.sol";
import {Quest} from "../contracts/Quest.sol";
import {Quest1155} from "../contracts/Quest1155.sol";
import {QuestFactory} from "../contracts/QuestFactory.sol";
import {QuestContractConstants as C} from "../contracts/libraries/QuestContractConstants.sol";
import {ProxyAdmin, ITransparentUpgradeableProxy} from "openzeppelin-contracts/proxy/transparent/ProxyAdmin.sol";

// # To Upgrade QuestFactory.sol run this command below
// ! important: make sure storage layouts are compatible first:
// bun clean && forge clean && forge build && npx @openzeppelin/upgrades-core validate --contract QuestFactory
// bun sphinx propose script/QuestFactory.s.sol --target-contract QuestFactoryUpgrade --networks testnets
contract QuestFactoryUpgrade is Script, SphinxConfig {
    function run() external sphinx {
        ITransparentUpgradeableProxy questfactoryProxy = ITransparentUpgradeableProxy(C.QUEST_FACTORY_ADDRESS);

        questfactoryProxy.upgradeTo(address(new QuestFactory{ salt: bytes32(0) }()));
    }
}

contract QuestFactoryDeploy is Script, SphinxConfig {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("MAINNET_PRIVATE_KEY");
        address owner = vm.addr(deployerPrivateKey);
        address claimSigner = vm.addr(vm.envUint("MAINNET_CLAIM_SIGNER_PRIVATE_KEY"));
        ITransparentUpgradeableProxy questfactoryProxy = ITransparentUpgradeableProxy(C.QUEST_FACTORY_ADDRESS);
        string memory json = vm.readFile("script/deployDataBytes.json");
        bytes memory ogData = vm.parseJsonBytes(json, "$.questFactoryOgImpl");
        bytes memory data = vm.parseJsonBytes(json, "$.questFactoryData");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy OgImpl
        (bool success,) = C.DETERMINISTIC_DEPLOY_PROXY.call(ogData);
        require(success, "failed to deploy OgImpl");

        // Deploy QuestFactory
        (bool success2,) = C.DETERMINISTIC_DEPLOY_PROXY.call(data);
        require(success2, "failed to deploy QuestFactory");

        // Upgrade
        ProxyAdmin(C.PROXY_ADMIN_ADDRESS).upgrade(questfactoryProxy, address(new QuestFactory()));

        // Initialize
        QuestFactory(C.QUEST_FACTORY_ADDRESS).initialize(
            claimSigner,                        // claimSignerAddress_
            owner,                              // protocolFeeRecipient_
            address(new Quest()),               // erc20QuestAddress_
            payable(address(new Quest1155())),  // erc1155QuestAddress_
            owner,                              // ownerAddress_
            500000000000000,                    // nftQuestFee_,
            5000,                               // referralFee_,
            75000000000000                      // mintFee_
        );

        // Transfer ownership of the proxy from the ProxyAdmin to the Gnosis Safe
        ProxyAdmin(C.PROXY_ADMIN_ADDRESS).changeProxyAdmin(questfactoryProxy, safeAddress());

        vm.stopBroadcast();
    }
}
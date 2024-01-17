// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {Sphinx, Network} from '@sphinx-labs/plugins/SphinxPlugin.sol';

// Sphinx config options. Inherit from this contract in any script that you want to propose with
// Sphinx.
contract SphinxConfig is Sphinx {
    address internal owner = address(0); // Add owner address

    constructor() {
        sphinxConfig.owners = [owner];
        sphinxConfig.orgId = ""; // Add org ID
        sphinxConfig.mainnets = [
            Network.ethereum,
            Network.polygon,
            Network.arbitrum,
            Network.optimism,
            Network.base
        ];
        sphinxConfig.testnets = [
            Network.arbitrum_sepolia
        ];
        sphinxConfig.projectName = "Quest_Protocol";
        sphinxConfig.threshold = 1;
    }
}
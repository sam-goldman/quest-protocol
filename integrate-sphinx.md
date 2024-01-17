# Sphinx Integration Guide

Follow this guide to deploy with Sphinx on Arbitrum Sepolia. It should take you 5 minutes to finish.

## Notes

I noticed that the addresses of your `QuestFactory`, `ProtocolRewards`, and `RabbitHoleTickets` contracts are determined by the address of the deployer. It's not currently possible to deploy these contracts with Sphinx while also keeping their same addresses. This limitation is due to the fact that deployments with Sphinx are executed by a Gnosis Safe that you own instead of a deployer private key.

If you're fine with new addresses for these three contracts, you can use Sphinx to deploy them, which means you wouldn't need native gas tokens on any new chain that you want to support. However, in this integration, I assumed that you'd prefer to keep the same addresses for these contracts.

This guide will show you how to deploy the `QuestFactory` at the same address then import it into Sphinx. After it's imported, you'll be able to upgrade and manage the `QuestFactory` gaslessly. If you want to use Sphinx on all networks, you'll be able to upgrade and manage your contracts on all chains simultaneously without needing to fund the transactions.

There are two main components in this guide:
1. Deploy the `ProxyAdmin`. In this guide, we deploy it with Sphinx to demonstrate how Sphinx works. This contract will have the same address as usual because it's deployed via `CREATE2`.
2. Deploy and initialize the `QuestFactory` using your existing script. You must execute this script from your local machine in order to get a consistent address for the `QuestFactory`. I've made one change to the script: after the `QuestFactory` is initialized, the script imports it into Sphinx by transferring ownership of it to your Gnosis Safe.

A few other notes:
* We don't currently support Scroll, Mantle, or Zora, but we'd be happy to support them if you want. Generally, you can just ask us if you need us to support any EVM-compatible network.
* The diff of this integration is [here](https://github.com/sam-goldman/quest-protocol/pull/1).

If you have any questions, check out our [GitHub page](https://github.com/sphinx-labs/sphinx) or send us a message.

## Deployment Instructions

1. Clone this fork of your repo:
```
git clone git@github.com:sam-goldman/quest-protocol.git
```

2. 
```
cd quest-protocol
```

3. Update Foundry, then install packages:
```
foundryup && bun install
```

4. Sign up for Sphinx using this [invite link](https://www.sphinx.dev/signup?code=7df7c3d8-8e66-41a0-b6bc-04cf2021cb35).

5. In Sphinx's website, go to "Options" -> "API Credentials". You'll need these credentials in the next couple of steps.

6. Open `script/SphinxConfig.sol`. The `setUp` function contains your config options. Update the following fields:\
    a. In `sphinxConfig.orgId`, add the Organization ID from Sphinx's website. This is a public field, so you don't need to keep it secret.\
    b. In `sphinxConfig.owners`, add the addresses of the account that will own your project. (Specifically, it'll own the Gnosis Safe that executes your deployment).

7. Create a `.env` file. Then, copy and paste the variables from `.env.example` to `.env` and fill them in. The `SPHINX_API_KEY` is in the Sphinx UI (under "Options" -> "API Credentials").

8. You're done with the configuration steps! Run `forge build` to make sure your contracts can compile.

9. Next, propose `ProxyAdmin.s.sol` on the networks in `sphinxConfig.testnets` (which is currently just Arbitrum Sepolia):
```
bun sphinx propose script/ProxyAdmin.s.sol --networks testnets
```

10. When the proposal is finished, go to the [Sphinx UI](https://sphinx.dev) to approve the deployment. After you approve it, you can monitor the deployment's status in the UI while it's executed.

### Setup the `QuestFactory` with Sphinx (Optional)

In this section, you'll run the `QuestFactoryDeploy` script from your local machine so that the `QuestFactory` has the same address as your previous deployments. I've made one modification to this script: at the end, it transfers ownership of the `QuestFactory` from the `ProxyAdmin` to your Gnosis Safe, which was deployed earlier in this guide.

Run the `QuestFactoryDeploy` script:
```
forge script script/QuestFactory.s.sol:QuestFactoryDeploy --rpc-url arbitrum_sepolia --broadcast --verify -vvvv
```

After this script executes, you can upgrade and manage the `QuestFactory` with Sphinx. For example, to run the `QuestFactoryUpgrade` script, run the command:
```
bun sphinx propose script/QuestFactory.s.sol --target-contract QuestFactoryUpgrade --networks testnets
```

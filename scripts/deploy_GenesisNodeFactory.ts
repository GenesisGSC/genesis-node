import { ethers } from "hardhat";

async function main() {
    const genesisNodeFactory = await ethers.deployContract("GenesisNodeFactory");

    await genesisNodeFactory.waitForDeployment();

    const GenesisNodeFactory = genesisNodeFactory.deploymentTransaction();
    // @ts-ignore
    console.log(`GenesisNodeFactory Address：${genesisNodeFactory.target} hash: ${GenesisNodeFactory.hash}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

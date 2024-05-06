import { loadFixture, time } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { ethers } from "hardhat";
import { expect } from "chai";

describe("GenesisNodeFactory", function () {
    async function deployContracts() {
        const [owner, otherAccount] = await ethers.getSigners();

        const GenesisNodeFactory = await ethers.getContractFactory("GenesisNodeFactory");
        const genesisNodeFactory = await GenesisNodeFactory.deploy();
        return { genesisNodeFactory, owner, otherAccount };
    }

    describe("Deployment", function () {
        it("Deployment GenesisNodeFactory", async function () {
            const { genesisNodeFactory, owner } = await loadFixture(deployContracts);
            console.log("owner", owner.address);
            console.log("GenesisNodeFactory Address：", genesisNodeFactory.target);
        });
    });
});
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require("dotenv").config();

const config: HardhatUserConfig = {
    solidity: {
        version: "0.8.6",
        settings: {
            optimizer: {
                enabled: true,
                runs: 200
            }
        }
    },
    networks: {
        gsctestnet: {
            url: "https://testnet.genesischain.io/",
            accounts: [
                `${process.env.PRIVATE_KEY}`
            ],
            chainId: 44
        },
    }
};

export default config;

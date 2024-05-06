
# hardhat
## Install
```bash
npm install --save-dev @nomicfoundation/hardhat-toolbox@^4.0.0

npm install dotenv
```

## env
 `.env` file
```shell
PRIVATE_KEY=xxxxx
```

## Quick start
```bash
npx hardhat compile

npx hardhat test  

npx hardhat node 

npx hardhat run scripts/deploy_GenesisNodeFactory.ts

npx hardhat run scripts/deploy_GenesisNodeFactory.ts --network gsctestnet
```
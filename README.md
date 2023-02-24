# Thales Hardhat Contract Development Environment

This is a Hardhat development environment for the Thales project. It contains the following:

- _contracts_ folder - contains the contracts to be deployed
- _scripts_ folder - contains the scripts to deploy the contracts
- _test_ folder - contains the tests for the contracts
- _hardhat.config.js_ - contains the configuration for the Hardhat environment

### _Commands:_

- _npx hardhat test_ - runs the tests in the test folder sequentially.
- _npx hardhat node_ - starts a local network on localhost:8545
- _npx hardhat compile_ - compiles the contracts in the contracts folder
- _npx hardhat help_ - lists all the available commands

### _Contract Deployment:_

- _npx hardhat run scripts/deploy.js_ - deploys the contract to the local network. Add --network goerli to deploy to Goerli testnet.

### _Contract Interactions:_

- _npx hardhat console --network goerli_ - starts a console to interact with the deployed contract on Goerli testnet.
- _npx hardhat console --network localhost_ - starts a console to interact with the deployed contract on localhost.

### _Contract Addresses:_ - [Contract Listing for each network](https://contracts.thalesmarket.io/)

### _Contract Github:_ - [Thales Contract Repository](https://github.com/thales-markets/contracts)

### _HardHat Documentation:_ - [HardHat Documentation](https://hardhat.org/getting-started/)

### _Thales Documentation:_ - [Thales Documentation](https://docs.thalesmarket.io/)

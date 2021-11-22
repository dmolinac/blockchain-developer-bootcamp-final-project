# Blockchain Developer Bootcamp Final Project

# Fully on-chain dynamic NTFs for Spanish horseracing in Ethereum

## About
The purpose of this project is to develop a platform to manage on-chain data for Spanish horse racing so these data can be used by external applications (games, dApps, etc.)

One of this applications, included in the project, is a fully on-chain thoroughbred NFTs representing real race horses that anyone can acquire. The NFTs look like a game card with SVG and horse data. The NFTs are upgradeable with the current number of victories of the horse represented.

In order to fetch horses' data, I have installed a local Chainlink node with a specific jobId that requests the data to [Metaturf Spanish horse racing platform](https://www.metaturf.com). I am partner at this company.

## Frontend access
https://dmolinac.github.io/blockchain-developer-bootcamp-final-project/

## Screencast
https://youtu.be/FrQsV3mwQEs

## Example workflows
1. The contract owner checks the last races' IDs and requests the information of a horse asking for the winner of a race. The information retrieved is stored on-chain.
2. Any address can mint a horse from the list of on-chain horses stored. Every horse can be minted once.
3. The contract owner can periodically update the number of races winned by a horse. Token owners cannot do this.
4. The number of victories is shown in the NFT (tokenURI).


In order to cover costs, the platform will apply fees when horses are sold, traits are updated and horses are used by external dApps.
### Next steps
I tried to keep the idea as simple as possible, so at this stage the contracts and dApp are in an early stage. Next steps are manyfold:

- Retrieve more information from horses (age, sex, etc.).
- Implement proxy contract.
- Set `MetaturfHorseRacingData` address as an argument in `MetaturfNFT` constructor.
- Fetch information about races. At this stage I have only developed the queries to fetch race information the oracle contract.
- Check other ways to ask the Oracle about how to retrieve horse information, rather than asking for the winner of a race.
- Users may have to pay a fee to mint horses to cover costs.
- NFTs should be better designed with more information, different colors, shapes, etc. and SVG may be pre-codified in base64.
- Anyone could use the information stored in the `MetaturfHorseRacingData` contract to build other dApps.


## Contracts

The dApp is backed by 3 smart contracts:
### Horse Racing Data

`MetaturfHorseRacingData` contract stores Spanish horse racing data retrieved from a Chainlink oracle. It declares a library with structs to store Horse and Race data.

### Horses' NFTs

`MetaturfNFT` contract mints NFTs 100% on-chain. Inspired in generative NFTs and [Loot project](https://www.lootproject.com)

### Oracle Contract
`Oracle` Chainlink base contract for Oracles. Deployed with [Remix](https://remix.ethereum.org)

## Tech Stack
- Blockchain: Ethereum Kovan testnet
- Solidity Development: [Truffle v5.4.18](https://www.trufflesuite.com/truffle) `npm i -g truffle`
- Node v12.18.4 
- Web3.js v1.5.3
- Wallet Support: [MetaMask](https://metamask.io/)
- Web Client: [React](https://reactjs.org/)

## Dependencies
- HDWallet provider ^1.0.6: `npm i @truffle/hdwallet-provider`
- NFT Contract Library ^4.3.2: [Open Zeppelin](https://openzeppelin.com/) `npm i @openzeppelin/contracts`
- Oracle Contract Library ^0.2.2: [Chainlink](https://github.com/smartcontractkit) `npm i @chainlink/contracts`
- React: `npm i -g react`
- Axios ^0.24.0: required to fetch off-chain data from Metaturf REST API `npm i axios`
- Dotenv ^10.0.0: `npm i dotenv` 

## Directory structure
`client`: Project's React frontend.

`contracts`: Smart contracts that are deployed in the Kovan testnet.

`migrations`: Migration files for deploying contracts in contracts directory.

`test`: Tests for smart contracts.

## Instructions

The development, test and deploy of the contracts and the React dApps have been performed in Kovan testnet, mainly to be able to integrate with the Chainlink oracle.

### Deployment of contracts

1. Clone the repository

`git clone https://github.com/dmolinac/blockchain-developer-bootcamp-final-project`

2. Populate the .env locally
   
I have included a file .env.template with the two environment variables to customise: 

`MNEMONIC="YOUR_MNEMONIC_PHRASE_HERE"`

`INFURA_API_URL="YOUR_INFURA_API_KEY_HERE"`

3. Install dependencies
   
`cd blockchain-developer-bootcamp-final-project`

`npm install`

4. Compile contracts
   
`truffle compile`

5. Test contracts

`truffle test --network kovan`

6. Deploy contracts
   
`truffle deploy --network kovan --reset`

7. Oracle contract

The oracle contract is inherited from Chainlink and it is fixed as it needs to call the local Chainlink node. It was deployed using Remix. The address is set in `MetaturfHorseRacingData` contract. 


### Configuration of MetaturfNFT contract

In order for the dApp to work, we need to set the address of `MetaturfHorseRacingData` contract in `MetaturfNFT` contract:

First, we get the address of `MetaturfHorseRacingData` address:

`npx truffle console --network kovan`

`truffle(kovan)> let mtdata = await MetaturfHorseRacingData.deployed()`

`truffle(kovan)> let mtaddress = mtdata.address`

Then, we register the address in `MetaturfNFT` contract:

`truffle(kovan)> let nft = await MetaturfNFT.deployed()`

`truffle(kovan)> nft.registerMetaturfHorseRacingDataAddress(mtdata.address)`

Finally, we need to send LINK tokens (1 LINK per request) to the `MetaturfHorseRacingContract` (i.e. using Metamask):

[LINK faucet](https://faucets.chain.link/kovan)

We can check the contract address by typing `mtdata.address` in Truffle console.


### Calling the contracts from Truffle console

Some examples:

- Calling the oracle to retrieve the winner of a race and checking the result. For this call to work, the local node must be active. In case it is not up, please write me to dmolinac@gmail.com.
  
`let result = await mtdata.requestOracleRaceWinner(456)`

`result.logs[0]`

- Setting a horse without calling the oracle (only for contract owner). This operation is only for testing purposes, in mainnet this function should be removed)

`mtdata.setHorseFromCSV("793,VEGIA,3")`

- Get information from a horse stored: `mtdata.getHorse(793)`

- List horses: `mtdata.listHorses()`

- Mint a horse: `nft.mint(12,"Horse_name")`

- Get NFT Info: `nft.getHorseNFTInfo(0);`

- Get number of tokens: `nft.getNumberOfTokens()`

### Deployment of dApp

The Web Client for the dApp has been developed with React.

#### Installation:

`cd client`

`npm install`

#### Deployment to Github pages:

`npm install gh-pages --save-dev`

`npm run predeploy`

`npm run deploy`


### Accessing or—if your project needs a server (not required)—running your project

The project interacts with a Chalinlink node installed locally. We have developed the project so it can be operated without this requirement by calling `setHorseFromCSV` from `MetaturfHorseRacingData`contract (see example above). In case the server is not running, please write to dmolinac@gmail.com.

## Public Ethereum acccount for the certification NFT
`0xBbc9368898422Cc9FfaBEf8ea66210D3D011512F`

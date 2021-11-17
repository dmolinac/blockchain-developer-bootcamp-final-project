# Blockchain Developer Bootcamp Final Project

# Upgradeable NTFs for horse racing games in Ethereum

## About
The purpose of this project is to develop a platform that manages NFTs matching real race horses. These NFTs will be upgradeable with traits stored on-chain so an ecosystem of games, Dapps, etc. can be built around this.
The owner of the smart contract will mint horses that match real thoroughbreds. Users will be able to acquire these NFTs. Some traits of the NFTs will be updated in order to track number of victories, performances, value of the horse, etc.
The NFTs will look like a game card with a photograph of the horse, plus a set of fields including:
- Fixed traits: male/female, birthdate, etc.
- Dynamic traits: Number of races and victories, prizes won, performance, etc.
In order to cover costs, the platform will apply fees when horses are sold, traits are updated and horses are used by external Dapps.

### Example workflows
1. The owner mints NFTs matching real racing horses, with a cost of acquisition based on the quality of the horse.
2. Users will be able to buy these NFTs.
3. The contract will transfer ETH fees to the development team.
4. The contract will update periodically the dynamic traits of the horses. Owners  will not be able to update them.
5. Both the development team, the owners or anyone will be able to develop smart contracts or Dapps to play with the NFTs. When interacting with the smart contract, some fees may apply.

### Next steps
I tried to keep the idea as simple as possible. As the development advances, other aspects could be addressed: new use cases, use of oracles to fetch horses' data, speficic token to buy the horses and operate the smart contracts, etc. 

## Frontend access
https://dmolinac.github.io/blockchain-developer-bootcamp-final-project/

## Screencast
(TBC)

## Public Ethereum acccount for the certification NFT
`0xBbc9368898422Cc9FfaBEf8ea66210D3D011512F`

## Directory structure
`client`: Project's React frontend.
`contracts`: Smart contracts that are deployed in the Kovan testnet.
`migrations`: Migration files for deploying contracts in contracts directory.
`scripts`: Scripts to automate some operations.
`test`: Tests for smart contracts.

## Instructions

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

5. Deploy contracts
   
`truffle deploy --network kovan --reset`

### Configuration of MetaturfNFT contract

In order for the Dapp to work, we need to set the address of MetaturfHorseRacingData contract in MetaturfNFT:

First, we get the address of MetaturfHorseRacingData address:

`npx truffle console --network kovan`

`truffle(kovan)> let mtdata = await MetaturfHorseRacingData.deployed()`

`truffle(kovan)> let mtaddress = mtdata.address`

Then, we register the address in MetaturfNFT contract:

`truffle(kovan)> let nft = await MetaturfNFT.deployed()`

`truffle(kovan)> nft.registerMetaturfHorseRacingDataAddress(mtdata.address)`

Finally, we need to send LINK tokens (1 LINK for each request) to the MetaturfHorseRacingContract (i.e. using Metamask):

LINK faucet: https://faucets.chain.link/kovan

We can check the contract address by typing `mtdata.address` in Truffle console.

### Calling the contracts from Truffle console

Some examples:

- Calling the oracle to retrieve the winner of a race and checking the result:
  
For this call to work, the local node must be active. In case it is not up, please write me to dmolinac@gmail.com.
  
`let result = await mtdata.requestOracleRaceWinner(456)`
`result.logs[0]`

- Setting a horse without calling the oracle (only for contract owner):
  
This operation is only for testing purposes, in mainnet this function should be removed)

`mtdata.setHorseFromCSV("793,VEGIA,3")`

- Get information from a horse stored:

`mtdata.getHorse(793)`

- List horses:

`mtdata.listHorses()`

- Mint a horse:
  
`nft.mint(12,"Horse_name")`

- Get NFT Info:

`nft.getHorseNFTInfo(0);`

- Get number of tokens:

`nft.getNumberOfTokens()`

### Accessing or—if your project needs a server (not required)—running your project

The project interacts with a Chalinlink node installed locally. We have developed the project so it can be operated without this requirement by calling `setHorseFromCSV` from `MetaturfHorseRacingData`contract (see example above). In case the server is not running, please write to dmolinac@gmail.com.


### Running your smart contract unit tests
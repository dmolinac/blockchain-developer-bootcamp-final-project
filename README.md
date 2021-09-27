# Blockchain Developer Bootcamp Final Project

# Upgradeable NTFs for horse racing games in Ethereum

## About
The purpose of this project is to develop a platform that manages NFTs matching real race horses. These NFTs will be upgradeable with traits stored on-chain so an ecosystem of games, Dapps, etc. can be built around this.
The owner of the smart contract will mint horses that match real thoroughbreds. Users will be able to acquire these NFTs. Some traits of the NFTs will be updated in order to track number of victories, performances, value of the horse, etc.
The NFTs will look like a game card with a photograph of the horse, plus a set of fields including:
- Fixed traits: male/female, birthdate, etc.
- Dynamic traits: Number of races and victories, prizes won, performance, etc.
In order to cover costs, the platform will apply fees when horses are sold, traits are updated and horses are used by external Dapps.

## Example workflows
1. The owner mints NFTs matching real racing horses, with a cost of acquisition based on the quality of the horse.
2. Users will be able to buy these NFTs.
3. The contract will transfer ETH fees to the development team.
4. The contract will update periodically the dynamic traits of the horses. Owners  will not be able to update them.
5. Both the development team, the owners or anyone will be able to develop smart contracts or Dapps to play with the NFTs. When interacting with the smart contract, some fees may apply.

## Next steps
I tried to keep the idea as simple as possible. As the development advances, other aspects could be addressed: new use cases, use of oracles to fetch horses' data, speficic token to buy the horses and operate the smart contracts, etc. 

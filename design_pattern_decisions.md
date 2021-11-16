# Design patterns
## Inter-Contract Execution

`MetaturfNFT` contract calls `MetaturfHorseRacingData` contract to retrieve horses' data to draw tokens with on-chain data.

## Inheritance and Interfaces

- `MetaturfHorseRacingData` contract inherits from **ChainlinkClient** in order to perform requests to the Oracle.
- `MetaturfNFT` contract inherits from Open Zeppelins' **ERC721** contract in order to manage the NFTs.
## Oracles

`MetaturfHorseRacingData` contract makes requests to a **Chainlink test node**.
The oracle retrieves horse racing data from an off-chain database through a Chainlink JobID and API REST that I have developed.
## Access Control Design Patterns

`MetaturfHorseRacingData` contract:
- Modifier `onlyOwner`restricts access to any address different from the contract owner.
- Modifier `allowedAddress` restricts access to functions where only the contract owner or the oracle contract should access.
- Modifier `horseExists` restricts access to functions where the horse must exist.
- Modifier `raceExists`restricts access to funcions where the race must exist.
- Modifier `winsHaveChanged` restricts access to functions where the number of wins of a horse must have changed, in order to avoid useless calls to the Oracle.

`MetaturfNFT`contract:
- Modifier `onlyOwner` restricts access to any address different from the contract owner.
- Modifier `isTokenOwner`restricts access to functions where only the token owner can access (to be used).



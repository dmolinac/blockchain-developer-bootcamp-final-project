const MetaturfNFT = artifacts.require("./MetaturfNFT.sol");
const MetaturfHorseRacingData = artifacts.require("./MetaturfHorseRacingData.sol");

contract("MetaturfNFT", (/* accounts */) => {
  describe("Initial deployment", async () => {
    it("contract deployed", async function () {
      await MetaturfNFT.deployed();
      assert.isTrue(true);
    });

    it("MetaturfHorseRacingData address is not set", async () => {
      const instanceMetaturfNFT = await MetaturfNFT.deployed();
      var exists = await instanceMetaturfNFT.isSetMetaturfHorseRacingDataAddress();
      expect(exists).to.be.false;
      //return instanceMetaturfNFT.isSetMetaturfHorseRacingDataAddress().then(function(result) {
      //   assert.isFalse(result.receipt.status, 'it returns true');})
    });

    it("MetaturfHorseRacingData address is set", async () => {
      const instanceMetaturfHorseRacingData = await MetaturfHorseRacingData.deployed();
      const instanceMetaturfNFT = await MetaturfNFT.deployed();

      await instanceMetaturfNFT.registerMetaturfHorseRacingDataAddress(instanceMetaturfHorseRacingData.address);

      var exists = await instanceMetaturfNFT.isSetMetaturfHorseRacingDataAddress();
      expect(exists).to.be.true;

       //assert.equal(await instanceMetaturfNFT.isSetMetaturfHorseRacingDataAddress(), true);
     });

    // it("mint horse", async () => {
    //   const instanceMetaturfHorseRacingData = await MetaturfHorseRacingData.deployed();
    //   const instanceMetaturfNFT = await MetaturfNFT.deployed();

    //   await instanceMetaturfHorseRacingData.setHorse(1, "Mendavia", 3);

    //   const newHorseId = await instanceMetaturfNFT.mint(1,"test")
    //   assert.equal(newHorseId, 1);
    // });

  });
});

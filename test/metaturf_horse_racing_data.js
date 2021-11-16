// const MetaturfHorseRacingData = artifacts.require("./MetaturfHorseRacingData.sol");

// contract("MetaturfHorseRacingData", (/* accounts */) => {
//   describe("Initial deployment", async () => {
//     it("contract deployed", async function () {
//       await MetaturfHorseRacingData.deployed();
//       assert.isTrue(true);
//     });

//     it("set/get horse", async () => {
//       const instance = await MetaturfHorseRacingData.deployed();

//       await instance.setHorse(1, "Mendavia", 3);

//       const horse = await instance.getHorse(1);
//       assert.equal(horse[0], "Mendavia");
//       assert.equal(horse[1], 3);
//     });

//     it("update horse wins", async () => {
//       const instance = await MetaturfHorseRacingData.deployed();

//       await instance.updateHorseWins(1, 4);
      
//       const horse = await instance.getHorse(1);
//       assert.equal(horse[0], "Mendavia");
//       assert.equal(horse[1], 4);
//     });

//     it("set horse from CSV", async () => {
//       const instance = await MetaturfHorseRacingData.deployed();

//       await instance.setHorseFromCSV("13882,GALILODGE (FR),1");
      
//       const horse = await instance.getHorse(13882);
//       assert.equal(horse[0], "GALILODGE (FR)");
//       assert.equal(horse[1], 1);
//     });

//     it("horse exists", async () => {
//       const instance = await MetaturfHorseRacingData.deployed();
      
//       await instance.setHorseFromCSV("13,GALILODGE (FR),1");

//       const exists = await instance.theHorseExists(13);
//       assert.equal(exists, true);
//     });

//     it("horse does not exists", async () => {
//       const instance = await MetaturfHorseRacingData.deployed();
      
//       const exists = await instance.theHorseExists(2);
//       assert.equal(exists, false);
//     });
//   });
// });

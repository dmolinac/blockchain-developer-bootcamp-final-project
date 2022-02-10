// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "./strings.sol";

/// @title Library with structs to store Horse and Race data
/// @author Daniel Molina
/// @custom:experimental This is an experimental contract.
library MetaturfStructs {

    struct Horse {
        uint256 horseid;
        string name;
        uint256 wins;
    }
 
    struct Race {
        uint256 raceid;
        string racecourse;
        string date;
        string time;
        uint256 winnerhorseid;
    }    
}

/// @title Contract to store Spanish horse racing data from a Chainlink oracle
/// @author Daniel Molina
contract MetaturfHorseRacingData is ChainlinkClient {

    using Chainlink for Chainlink.Request;
    using strings for *;

    address private owner;

    using Chainlink for Chainlink.Request;
    
    string raceWinnerRequest;
    string horseDataRequest;

    /// @dev Address of the oracle contract.
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;
 
    mapping (uint => MetaturfStructs.Race) public races;
    mapping (uint => MetaturfStructs.Horse) public horses;
 
    /// @dev lists to be able to loop horses and races stored on-chain
    /// @dev following https://medium.com/@blockchain101/looping-in-solidity-32c621e05c22
    uint256[] private horseList;
    uint256[] private raceList;

    event LogFulfillRaceWinner(string winner);

    event LogFulfillHorseData(string horsedata);

    event LogSetHorse(uint256 horseid, string name, uint256 wins);

    event LogSetRace(uint256 raceid, string racecourse, string date, string time, uint256 winnerhorseid);
    
    /// @dev validates the contract owner
    modifier onlyOwner() {
      require (msg.sender == owner, "onlyOwner: caller is not the contract owner");
      _;
    }

    /// @dev validates the allowed addresses: contract owner and oracle contract
    modifier allowedAddress() {
      require ( (msg.sender == owner) || (msg.sender == oracle),
        "allowedAddress: caller is not allowed");
      _;
    }

    /// @dev validates that a horse exists or not, depending on the needs of the function
    /// @param _horseid ID of the horse
    /// @param _exist Boolean stating wether the horse ID should exist or not
    modifier horseExists(uint256 _horseid, bool _exist)   {
        if(!_exist) {
          require (horses[_horseid].horseid == 0, "horseExists: horse already exists");
        } else {
          require (horses[_horseid].horseid != 0, "horseExists: horse does not exis");  
        }
        _;
    }

    /// @dev validates that a race exists or not, depending on the needs of the function
    /// @param _raceid ID of the race
    /// @param _exist Boolean stating wether the race ID should exist or not
    modifier raceExists(uint _raceid, bool _exist)   {
        if(!_exist) {
          require (races[_raceid].raceid == 0, "raceExists: race already exists");
        } else {
          require (races[_raceid].raceid != 0, "raceExists: race does not exis");  
        }
        _;
    }

    /// @dev validates that the races winned by a horse have changed
    /// @param _horseid ID of the horse
    /// @param _wins number of wins to check   
    modifier winsHaveChanged(uint256 _horseid, uint256 _wins) {
        require (horses[_horseid].wins < _wins, "winsHaveChanged: wins do not match");
        _;
    }

    /// @notice Contract constructor
    /// @dev defaults the contract to the Chainlink parameters: oracle address, jobid and fee
    /// @dev initial owner is construct
    /// @dev sets the API requests for the orache (horse and race data)
    constructor() {
        owner = msg.sender;
        //setPublicChainlinkToken();
        oracle = 0x9dD3298DAd96648E7fdF5632b9813D22Bbb3eb61;
        jobId = "9daa7f5130ab4439a63dee42a15d119a"; //Correcto
        fee = 1 * 10 ** 18; // 1 LINK
        
        //lastRacesRequest = "https://ghdbadmin.metaturf.com/rest/rest_web3.php?resource=listraces&id=1&date=20210619&format=json";
        raceWinnerRequest = "https://ghdbadmin.metaturf.com/rest/rest_web3.php?resource=getwinner&id=";
        horseDataRequest = "https://ghdbadmin.metaturf.com/rest/rest_web3.php?resource=getHorseData&id=";
    }

    /// @notice Request the winner of a race to the oracle.
    /// @dev We own the oracle node in a test environment that needs to be active.
    /// @dev Example of response format:
    /// @dev {
    /// @dev   "code":1,
    /// @dev   "status":200,
    /// @dev   "data":{
    /// @dev     "winner":"13882,GALILODGE (FR),1"
    /// @dev   }
    /// @dev }
    /// @param _raceid ID of the race
    /// @return requestId ID provided by the oracle
    function requestOracleRaceWinner(uint _raceid) public onlyOwner returns (bytes32 requestId) {

        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfillRaceWinner.selector);
       
        string memory raceid = uintToString(_raceid);
        string memory format = "&format=json";
       
        // Set the URL to perform the GET request on
        string memory requestb = string(abi.encodePacked(raceWinnerRequest, raceid, format));
        request.add("get", requestb);
 
        request.add("path", "data.winner");
        
        // Sends the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }

    /// @notice Fulfillment function that receives the horse winner in the form of bytes32
    /// @dev this function is called by the oracle contract when data is available
    /// @param _requestId ID of the previous request sent
    /// @param _winner data retrieved from the oracle
    function fulfillRaceWinner(bytes32 _requestId, bytes32 _winner) public allowedAddress recordChainlinkFulfillment(_requestId) {

        string memory csvhorsedata = bytes32ToString(_winner);
        setHorseFromCSV(csvhorsedata);
        
        emit LogFulfillRaceWinner(csvhorsedata);

        return;
    }

    /// @notice Request the data of a horse to the oracle.
    /// @dev We own the oracle node in a test environment that needs to be active.
    /// @dev Example of response format:
    /// @dev {
    /// @dev   "code":1,"status":200,
    /// @dev   "data": {
    /// @dev     "name":"CASILDA (SPA)",
    /// @dev     "sex":"Y",
    /// @dev     "birthdate":"2019-01-01",
    /// @dev     "debutant":"false",
    /// @dev     "national":"true",
    /// @dev     "prizes":38400,
    /// @dev     "wins":2
    /// @dev   }
    /// @dev }
    /// @param _horseid ID of the horse
    /// @return requestId ID provided by the oracle
    function requestOracleHorseData(uint _horseid) public onlyOwner returns (bytes32 requestId) {

        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfillHorseData.selector);
       
        string memory horseid = uintToString(_horseid);
        string memory format = "&format=json";
       
        // Set the URL to perform the GET request on
        string memory requestb = string(abi.encodePacked(horseDataRequest, horseid, format));
        request.add("get", requestb);        

        request.add("path", "data");
        
        // Sends the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    
    /// @notice Fulfillment function that receives the horse data in the form of bytes32
    /// @dev this function is called by the oracle contract when data is available
    /// @param _requestId ID of the previous request sent
    /// @param _horsedata data retrieved from the oracle
    function fulfillHorseData(bytes32 _requestId, bytes32 _horsedata) public allowedAddress recordChainlinkFulfillment(_requestId) {

        string memory horsedata = bytes32ToString(_horsedata);

        setHorseFromCSV(horsedata);

        emit LogFulfillHorseData(horsedata);
    
        return;
    } 
    
    /// @notice Withdraw LINK from this contract
    function withdrawLink() external onlyOwner {
        LinkTokenInterface linkToken = LinkTokenInterface(chainlinkTokenAddress());
        require(linkToken.transfer(msg.sender, linkToken.balanceOf(address(this))), "Unable to transfer");
    }

    /// @notice Checks if a horse is already stored in the contract
    /// @param _horseid ID of the horse to check
    /// @return bool true if the horse exists
    function theHorseExists(uint256 _horseid) public view returns(bool) {
        if(horses[_horseid].horseid == 0) return false;
        return true;
    }

    /// @notice Inputs a new horse info in the contract.
    /// @dev only the contract owner can call this function
    /// @param _horseid horse ID
    /// @param _name horse name
    /// @param _wins number of wins
    function setHorse(uint _horseid, string memory _name, uint _wins) public onlyOwner horseExists(_horseid, false) {
 
        horseList.push(_horseid);

        horses[_horseid] = MetaturfStructs.Horse({
            horseid: _horseid,
            name: _name,
            wins: _wins
        });
        emit LogSetHorse(_horseid, _name, _wins);
    }

    /// @notice Inputs a new horse info in the contract from a CSV. 
    /// @dev only the contract owner and the oracle can call this function
    /// @dev example format: "13882,GALILODGE (FR),1";
    /// @param _csvhorsedata CSV data
    function setHorseFromCSV(string memory _csvhorsedata) public allowedAddress {

        strings.slice memory s = _csvhorsedata.toSlice();
        strings.slice memory delim = ",".toSlice();
        string[] memory parts = new string[](s.count(delim) + 1);
        for(uint i = 0; i < parts.length; i++) {
            parts[i] = s.split(delim).toString();
        }

        require(parts.length == 3, "setHorseFromCSV: lenth of the information retrieved not valid");

        uint256 horseid = stringToUint(parts[0]);

        //If the horse does not exist, we create it
        if (horses[horseid].horseid == 0) {

            horseList.push(horseid);

            horses[horseid] = MetaturfStructs.Horse({
                horseid: horseid,
                name: parts[1],
                wins: stringToUint(parts[2])
            });

        } else {

            if (horses[horseid].wins != stringToUint(parts[2])) {
                horses[horseid].wins = stringToUint(parts[2]);
            }
        }
        emit LogSetHorse(horseid, parts[1], stringToUint(parts[2]));
    }
    
    /// @notice Given a horse ID, get the name and number of wins. 
    /// @param _horseid CSV data
    /// @return memory horse name
    /// @return uint number of wins
    function getHorse(uint256 _horseid) public view horseExists(_horseid, true) returns (string memory, uint) {
        return (
            horses[_horseid].name,
            horses[_horseid].wins
        );
    }

    /// @notice Get the list of horses stored on-chain. 
    /// @return uint[] horse list
    function listHorses() public view returns(uint256[] memory) {
        return horseList;
    }

    /// @notice Update wins. 
    /// @dev the horse must exist and the number of wins need to be greater than stored
    /// @param _horseid CSV data
    /// @param _wins number of wins to store
    function updateHorseWins(uint256 _horseid, uint256 _wins) public onlyOwner horseExists(_horseid, true) winsHaveChanged(_horseid, _wins) {
        horses[_horseid].wins = _wins;
    }
    
    /// @notice Inputs a new race info in the contract. 
    /// @dev the race must not exist
    /// @dev the winner horse must exist
    /// @dev Currently it is not used;
    /// @param _raceid race ID
    /// @param _racecourse racecourse name
    /// @param _date race date
    /// @param _time time of the winner
    /// @param _winnerhorseid winner horse ID
    function setRace(
        uint256 _raceid,
        string memory _racecourse,
        string memory _date,
        string memory _time,
        uint256 _winnerhorseid
    ) 
        public onlyOwner horseExists(_winnerhorseid, true) raceExists(_raceid, false)
    {
        
        raceList.push(_raceid);

        races[_raceid] = MetaturfStructs.Race({
            raceid: _raceid,
            racecourse: _racecourse,
            date: _date,
            time: _time,
            winnerhorseid: _winnerhorseid
        });
        emit LogSetRace(_raceid, _racecourse, _date, _time, _winnerhorseid);
    }
    
    /// @notice Given a horse ID, get the name and number of wins. 
    /// @param _raceid CSV data
    /// @return memory racecourse name
    /// @return memory race date
    /// @return memory time of the winner
    /// @return uint256 winner horse ID
    function getRace(uint256 _raceid) public view raceExists(_raceid, true) returns (string memory, string memory, string memory, uint256) {
        return (
            races[_raceid].racecourse,
            races[_raceid].date,
            races[_raceid].time,
            races[_raceid].winnerhorseid
        );
    }

    /// @notice Get the list of races stored on-chain. 
    /// @return uint[] race list
    function listRaces() public view returns(uint256[] memory) {
        return raceList;
    }

    /// @dev string helper functions
    function bytes32ToString(bytes32 _bytes32) internal pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }
    
    //https://ethereum.stackexchange.com/questions/10811/solidity-concatenate-uint-into-a-string
    function uintToString(uint v) internal pure returns (string memory) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = bytes1(uint8(48 + remainder));
        }
        bytes memory s = new bytes(i);
        for (uint j = 0; j < i; j++) {
            s[j] = reversed[i - 1 - j];
        }
        return string(s);
    }
    
    //https://ethereum.stackexchange.com/questions/10811/solidity-concatenate-uint-into-a-string
    function appendUintToString(string memory inStr, uint v) internal pure returns (string memory) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = bytes1(uint8(48 + remainder));
        }
        bytes memory inStrb = bytes(inStr);
        bytes memory s = new bytes(inStrb.length + i);
        uint j;
        for (j = 0; j < inStrb.length; j++) {
            s[j] = inStrb[j];
        }
        for (j = 0; j < i; j++) {
            s[j + inStrb.length] = reversed[i - 1 - j];
        }
        return string(s);
    }
   
    //https://ethereum.stackexchange.com/questions/10932/how-to-convert-string-to-int 
    function stringToUint(string memory s) internal pure returns (uint) {
        bytes memory b = bytes(s);
        uint result = 0;
        for (uint i = 0; i < b.length; i++) { // c = b[i] was not needed
            if (uint8(b[i]) >= 48 && uint8(b[i]) <= 57) {
                result = result * 10 + (uint8(b[i]) - 48); // bytes and int are not compatible with the operator -.
            }
        }
        return result; // this was missing
    }
}

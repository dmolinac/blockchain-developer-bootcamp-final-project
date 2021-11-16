// SPDX-License-Identifier: MIT
//pragma solidity >=0.6.0;
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./MetaturfHorseRacingData.sol";
import "./Base64.sol";

/// @title Contract to mint NFTs 100% on-chain
/// @notice inpired in generative NFTs and Loot project [https://www.lootproject.com]
/// @author Daniel Molina
/// @custom:experimental Experimental contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721]
contract MetaturfNFT is ERC721 {

    using Counters for Counters.Counter;

    Counters.Counter private _horseTokenIds;
 
    MetaturfHorseRacingData public metaturfHorseRacingData;

    address private owner; 
 
    struct HorseToken {
        uint horseid;
        address owner;
        string tokenURI;
    }

    mapping (uint256 => HorseToken) horseToken;

    mapping (uint256 => uint256) horseidToTokenid;

    uint256[] private tokenList;

    /// @dev LogMint event: horseid arg
    event LogMint(uint horseid);

    modifier isContractOwner() {
      require (msg.sender == owner, "isContractOwner: caller is not the contract owner");
      _;
    }
   
    modifier isTokenOwner(uint _horseTokenId) {
      require (msg.sender == horseToken[_horseTokenId].owner, "isTokenOwner: caller is not the token owner");
      _;
    }
    
    /// @notice Contract constructor
    /// @dev defaults to the token name and token symbol
    /// @dev initial owner is construct
    constructor() ERC721("Metaturf", "MT") {
        owner = msg.sender;
    }
    
    /// @notice Sets the address of the contract containing the on-chain data needed for the tokens 
    /// @param _addressOfMetaturfHorseRacingData address of contract MetaturfHorseRacingData
    function registerMetaturfHorseRacingDataAddress(address _addressOfMetaturfHorseRacingData) public isContractOwner {
        metaturfHorseRacingData = MetaturfHorseRacingData(_addressOfMetaturfHorseRacingData);
    }

    /// @notice Checks if the address of the MetaturfHorseRacingData contract is set
    /// @return bool true if is set
    function isSetMetaturfHorseRacingDataAddress() public view returns(bool) {
        if(address(MetaturfHorseRacingData(metaturfHorseRacingData)) == address(0)) return false;
        return true;
    }

    /// @notice Gets the list of tokens 
    /// @return uint[] token list
    function listTokens() public view returns(uint256[] memory) {
        return tokenList;
    }

    /// @notice Gets the number of tokens 
    /// @return uint256 number of tokens
    function getNumberOfTokens() public view returns (uint256) {
        return _horseTokenIds.current(); 
    }

    /// @notice Get information about a token
    /// @param _horsetokenid token ID
    /// @return uint horse ID
    /// @return string tokenURI
    function getHorseNFTInfo(uint256 _horsetokenid) public view returns (uint,string memory) {
        return (
            horseToken[_horsetokenid].horseid,
            horseToken[_horsetokenid].tokenURI
        );
    }

    /// @notice Checks if a horse ID has been minted
    /// @param _horseid horse ID
    /// @return bool true if is minted
    function horseIsMinted(uint256 _horseid) public view returns(bool) {
        if (horseidToTokenid[_horseid] == 0) return false;
        return true;
    }
    
    /// @notice Mints a token based on a horse ID
    /// @param _horseid horse ID
    /// @return uint token ID
    function mint(uint _horseid, address _to) public returns (uint256) {
        require(_to != address(0), "ERC721: mint to the zero address");
        require(!horseIsMinted(_horseid), "ERC721: token for this horse already minted");
        require(horseidToTokenid[_horseid] == 0, "Token already minted");
        require(metaturfHorseRacingData.theHorseExists(_horseid), "mint: the horse does not exist");

        _horseTokenIds.increment();

        uint256 newHorseTokenId = _horseTokenIds.current();

        horseToken[newHorseTokenId] = HorseToken({
            horseid: _horseid,
            owner: _to,
            tokenURI: ""
        });

        tokenList.push(newHorseTokenId);

        horseidToTokenid[_horseid] = newHorseTokenId;

        _safeMint(_to, newHorseTokenId);

        return newHorseTokenId;
    }
    
    /// @notice Builds the tokenURI 100% on-chain
    /// @notice base image under Creative Commons License created by potrace 1.15 and written by Peter Selinger
    /// @dev uses horse attributes: name and wins
    /// @dev it could be extended to more attributes
    /// @param _tokenId token ID
    /// @return string tokenURI
    function tokenURI(uint256 _tokenId) view override public returns (string memory) {

        uint256 horseid = horseToken[_tokenId].horseid;

        string memory horse_name;
        uint256 wins;
        (horse_name,wins) = metaturfHorseRacingData.getHorse(horseid);
        
        string[17] memory parts;
        
        parts[0] = '<svg version="1.0" xmlns="http://www.w3.org/2000/svg" fill="#17252A" width="128.000000pt" height="134.6000000pt" viewBox="0 0 1280.000000 1346.000000" preserveAspectRatio="xMidYMid meet">';
        parts[1] = '<metadata>Created by potrace 1.15, written by Peter Selinger 2001-2017</metadata><rect width="100%" height="100%" fill="#DEF2F1" /><g transform="translate(0.000000,946.000000) scale(0.100000,-0.100000)" stroke="none"><path fill="#2B7A78" d="M6985 9451 c-323 -53 -617 -257 -764 -533 -75 -138 -106 -237 -121 -380 -40 -387 199 -809 554 -982 182 -88 344 -123 530 -113 490 25 ';
        parts[2] = '877 366 971 854 28 143 19 253 -35 438 -118 407 -517 706 -960 720 -69 2 -147 0 -175 -4z"/><path fill="#2B7A78" d="M11060 8573 c-575 -85 -1000 -208 -1405 -408 -362 -179 -682 -418 -944 -706 -232 -255 -389 -464 -876 -1169 -201 -291 -462 -662 -491 -699 -5 -6 -246 86 -377 144 -357 160 -617 379 -772 651 -118 207 -182 451 -240 909 -29 234 -54 ';
        parts[3] = '347 -101 459 -60 142 -145 232 -261 277 -70 27 -229 32 -308 10 -125 -35 -268 -139 -357 -259 -206 -279 -214 -611 -26 -1092 68 -175 232 -469 366 -659 322 -455 913 -780 1598 -880 l116 -17 -84 -80 c-340 -322 -1092 -607 -1878 -713 -264 -36 -234 -38 -330 30 -171 123 -360 228 -590 329 -275 121 -900 353 -1030 381 -139 31 -364 33 -454 6 -148 -46 -250 -126 -341 -266 -114 -176 -150 -350 -100 -493 8 -23 13 -43 12 -45 -10 -10 -852 86 -1167 133 -409 61 -521 78 -725 113 ';
        parts[4] = '-126 22 -231 39 -232 37 -6 -5 -61 -271 -58 -277 3 -3 21 -9 42 -12 21 -3 153 -25 293 -50 689 -123 1239 -192 1842 -232 248 -17 242 -15 381 -118 213 -159 424 -245 1017 -413 423 -120 530 -165 675 -282 122 -98 221 -254 219 -344 -6 -158 -205 -519 -428 -774 -627 -714 -1165 -1311 -1499 -1662 -261 -274 -286 -302 -318 -365 l-20 -38 38 7 c21 3 65 15 98 26 77 25 496 248 875 466 162 93 435 249 605 347 398 229 562 339 765 514 604 522 939 1012 1040 1520 44 225 18 397 -93 616 -64 124 -158 251 -316 423 -67 72 -121 132 -119 132 2 0 48 9 103 20 593 115 1015 245 1360 417 161 81 194 99 325 186 152 101 ';
        parts[5] = '180 124 335 283 l140 143 750 11 c1006 14 1111 22 1171 93 l26 31 -28 8 c-38 10 -214 34 -394 53 -390 41 -519 61 -827 125 -349 72 -404 85 -405 93 0 5 63 97 140 205 76 108 213 305 302 437 440 647 650 923 884 1164 432 443 936 712 1631 871 181 41 394 79 399 71 2 -3 43 -110 91 -236 226 -599 261 -690 565 -1485 73 -190 149 -390 170 ';
        parts[6] = '-445 21 -55 115 -302 210 -550 95 -247 185 -484 200 -525 16 -41 65 -169 109 -283 44 -115 77 -215 74 -224 -7 -18 -168 -126 -449 -301 -152 -95 -219 -132 -242 -132 -37 0 39 -59 -1107 859 -573 459 -897 712 -932 728 -66 30 -108 26 -158 -18 -39 -35 -59 -86 -50 -128 9 -44 73 -110 208 -218 67 -53 152 -121 189 -151 l67 -54 3 -1552 c3 ';
        parts[7] = '-1461 4 -1553 21 -1579 24 -38 71 -59 143 -65 62 -5 62 -4 79 28 53 103 50 -1 55 1523 l5 1409 205 -168 c250 -205 759 -611 1049 -838 200 -156 215 -166 235 -153 11 8 242 155 511 327 270 171 500 321 513 333 12 11 22 30 22 42 0 29 -41 146 -143 410 -47 121 -144 375 -217 565 -73 190 -154 401 -180 470 -43 112 -145 380 -390 1020 -43 113 -113 295 -155 405 -42 110 -135 353 -205 540 -71 187 -165 436 -209 554 -45 117 -81 215 -81 217 0 7 -62 2 -160 -13z"/></g>';
        parts[8] = '<text x="10" y="1120" font-weight="bold" font-size="7em">';
        parts[9] = horse_name;
        parts[10] = '</text><text x="10" y="1300" font-size="7em">#';
        parts[11] = String.toString(_tokenId);
        parts[12] = ' (';
        parts[13] = String.toString(horseid);
        parts[14] = ')</text><text x="800" y="1300" font-size="7em">Wins: ';
        parts[15] = String.toString(wins);
        parts[16] = '</text></svg>';

        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7]));
        output = string(abi.encodePacked(output, parts[8], parts[9], parts[10], parts[11], parts[12], parts[13]));
        output = string(abi.encodePacked(output, parts[14], parts[15], parts[16]));

        return output;
    }
}

/// @notice String library
library String {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}
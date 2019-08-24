pragma solidity ^0.5.0;

import "./theGraphOracle.sol";

/**
 * The TestCase contract to test theGraphOracle queries.
 *
* MIT License
* 
* Copyright (c) 2019 Alessandro Ricottone
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
 */
contract TestCase {
    
    event BlockNumbersUpdated(uint[] result);
    event KittyOwnersUpdated(address[] result);
    
    theGraphOracle public oracle;
    uint[] public bns;
    address[] public kittyOwners;
    address public owner;

    // Permits modifications only by the owner of the contract.
    modifier only_owner() {
        require(msg.sender == owner, "Only contract owner can call this function.");
        _;
    }

    // Permits modifications only by the oracle contract.
    modifier from_oracle() {
        require(msg.sender == address(oracle), "Only oracle contract can call this function.");
        _;
    }
    
    /**
     * @dev Constructs a new theGraphOracle contract.
     */
    constructor(address _oracleAddress) public {
        oracle = theGraphOracle(_oracleAddress);
        owner = msg.sender;
    }

    /**
     * @dev Updates the theGraphOracle contract.
     * @param _newOracle The new oracle address.
     */
    function updateOracle(address _newOracle) only_owner public {
        oracle = theGraphOracle(_newOracle);
    }

    /**
     * @dev Creates a query on theGraphOracle for ENS blockNumbers.
     */
    function queryENS() public {
        string memory _company = "ensdomains";
        string memory _product = "ens";
        string memory _queryString = "{transfers(first:5){blockNumber}}";
        bytes4 _callback = bytes4(keccak256("updateBlockNumber(uint256[])"));
        oracle.createQuery(_company, _product, _queryString, false, address(this), _callback);
    }
    
    /**
     * @dev Callback function passed to the oracle.
     * @param _result The result of the query.
     */
    function updateBlockNumber(uint[] calldata _result) from_oracle external {
        require(_result.length == 5, "This function requires a length 5 array.");
        emit BlockNumbersUpdated(_result);
        bns = _result;
    }
    
     /**
     * @dev Creates a query on theGraphOracle for ENS blockNumbers.
     */
    function queryCryptoKitties() public {
        string memory _company = "thomasproust";
        string memory _product = "cryptokitties-explorer";
        string memory _queryString = "{cryptoKitties(where:{birthTime_gte:1514761200,birthTime_lt:1519858800},first:10) {owner}}";
        bytes4 _callback = bytes4(keccak256("updateBlockNumber(uint256[])"));
        oracle.createQuery(_company, _product, _queryString, false, address(this), _callback);
    }
    
    /**
     * @dev Callback function passed to the oracle.
     * @param _result The result of the query.
     */
    function updateKittyOwner(address[] calldata _result) from_oracle external {
        require(_result.length == 10, "This function requires a length 10 array.");
        emit KittyOwnersUpdated(_result);
        kittyOwners = _result;
    }
    
}
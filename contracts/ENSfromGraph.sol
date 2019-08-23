pragma solidity ^0.5.0;

import "./theGraphOracle.sol";

contract ENSfromGraph {
    
    theGraphOracle public oracle;

    constructor(address _oracleAddress) public {
        oracle = theGraphOracle(_oracleAddress);
    }

    function getOracleAddress() view public returns (address) {
        return oracle.oracleAddress();
    }

    function createBlockNumbersQuery(uint _number) public returns (bytes32) {
        bytes32 _schema = oracle.stringToBytes32("transfers");
        bytes32 _parameter = oracle.stringToBytes32("blockNumber");
        return oracle.createQuery(_schema, _parameter, _number);
    }
    
    function resolveBlockNumbersQuery(bytes32 _queryHash) public returns (uint) {
        bytes32 _schema = oracle.stringToBytes32("transfers");
        bytes32 _parameter = oracle.stringToBytes32("blockNumber");
        return oracle.results(_queryHash);
    }
}
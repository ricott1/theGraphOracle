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

    function queryBlockNumber() public returns (bytes32) {
        string memory _company = "ensdomains";
        string memory _product = "ens";
        string memory _queryString = "{transfers(first: 5){blockNumber}}";
        return oracle.createQuery(_company, _product, _queryString);
    }
    
    function resolveBlockNumber(bytes32 _queryId) public view returns (uint) {
        return oracle.results(_queryId);
    }
}
pragma solidity ^0.5.0;

import "./theGraphOracle.sol";

contract ENSfromGraph {
    
    event ResultUpdated(uint indexed result);

    
    theGraphOracle public oracle;
    address public oracleAddress;
    uint public bn;

    constructor(address _oracleAddress) public {
        oracle = theGraphOracle(_oracleAddress);
        oracleAddress = oracle.oracleAddress();
    }

    function queryBlockNumber() public {
        string memory _company = "ensdomains";
        string memory _product = "ens";
        string memory _queryString = "{transfers(first: 5){blockNumber}}";
        bytes4 _callback = bytes4(keccak256("updateBlockNumber(uint256)"));
        oracle.createQuery(_company, _product, _queryString, address(this), _callback);
    }
    
    function updateBlockNumber(uint _bn) external {
        //require(msg.sender == oracleAddress);
        emit ResultUpdated(_bn);
        bn = _bn;
    }
}
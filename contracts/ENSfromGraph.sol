pragma solidity ^0.5.0;

import "./theGraphOracle.sol";

contract ENSfromGraph {
    
    event ResultUpdated(uint indexed result, uint indexed resultLength);
    
    theGraphOracle public oracle;
    uint public bn;

    modifier from_oracle() {
        require(msg.sender == address(oracle));
        _;
    }

    constructor(address _oracleAddress) public {
        oracle = theGraphOracle(_oracleAddress);
    }

    function queryBlockNumber() public {
        string memory _company = "ensdomains";
        string memory _product = "ens";
        string memory _queryString = "{transfers(first: 5){blockNumber}}";
        bytes4 _callback = bytes4(keccak256("updateBlockNumber(uint256[])"));
        oracle.createQuery(_company, _product, _queryString, address(this), _callback);
    }
    
    function updateBlockNumber(uint[] calldata _bns) from_oracle external {
        emit ResultUpdated(_bns[0],_bns.length);
        //require(_bns.length == 5);
       
        bn = _bns[0];
    }
}
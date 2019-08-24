pragma solidity ^0.5.0;

contract theGraphOracle {

    event QueryCreated(bytes32 indexed queryId, string company, string product, string queryString, address _queryContract, bytes4 _callback, uint time);
    event ResultUpdated(bytes32 indexed queryId, uint result);

    address public oracleAddress;
    
    constructor (address _oracleAddress) public {
        oracleAddress = _oracleAddress;
    }

    function createQuery (string calldata _company, string calldata _product, string calldata _queryString, address _queryContract, bytes4 _callback) external {
        uint t = now;
        bytes32 _queryId = keccak256(abi.encode(_company, _product, _queryString, _queryContract, _callback, t));
        emit QueryCreated(_queryId, _company, _product, _queryString, _queryContract, _callback, t);
    }

    function updateQuery(address _queryContract, bytes4 _callback, uint _result) public returns (bool){
        require(msg.sender == oracleAddress);
        (bool status,) = _queryContract.call(abi.encodePacked(_callback, _result));
        return status;

    }
}

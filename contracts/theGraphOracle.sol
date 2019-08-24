pragma solidity ^0.5.0;

contract theGraphOracle {

    event QueryCreated(bytes32 indexed queryId, string company, string product, string queryString, uint time);
    event ResultUpdated(bytes32 indexed queryId, uint result);

    mapping(bytes32 => uint) public results;
    
    address public oracleAddress;
    
    constructor (address _oracleAddress) public {
        oracleAddress = _oracleAddress;
    }

    function createQuery (string calldata _company, string calldata _product, string calldata _queryString) external returns(bytes32) {
        uint t = now;
        bytes32 _queryId = keccak256(abi.encode(_company, _product, _queryString, t));
        emit QueryCreated(_queryId, _company, _product, _queryString, t);

        return _queryId;
    }

    function updateQuery(bytes32 _queryId, uint _result) external {
        require(msg.sender == oracleAddress);
        results[_queryId] = _result;
        emit ResultUpdated(_queryId, _result);
    }
}

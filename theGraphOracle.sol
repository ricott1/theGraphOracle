pragma solidity ^0.5.0;

contract theGraphOracle {

    event QueryCreated(bytes32 indexed queryHash, bytes32 indexed schema, bytes32 parameter, uint number, uint time);
    event ResultUpdated(bytes32 indexed queryHash, uint result);

    struct Query {
        bytes32 schema;
        bytes32 parameter;
        uint number;
        uint timestamp;
    }
    
    mapping(bytes32=>Query) public queries;
    mapping(bytes32 => uint) public results;
    
    address public oracleAddress;
    
    constructor (address _oracleAddress) public {
        oracleAddress = _oracleAddress;
    }

    function createQuery (bytes32 _schema, bytes32 _parameter, uint _number) public returns(bytes32) {
        uint t = now;
        Query memory _query = Query(_schema, _parameter, _number, t);
        bytes32 _queryHash = keccak256(abi.encode(_schema, _parameter, _number, t));
        queries[_queryHash] = _query;
        emit QueryCreated(_queryHash, _schema, _parameter, _number, t);

        return _queryHash;
    }

    function updateQuery(bytes32 _queryHash, uint _result) external {
        require(msg.sender == oracleAddress);
        results[_queryHash] = _result;
        emit ResultUpdated(_queryHash, _result);
    }
}

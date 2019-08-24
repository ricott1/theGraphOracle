pragma solidity ^0.5.0;

contract theGraphOracle {

    event QueryCreated(string company, string product, string queryString, address _queryContract, bytes4 _callback);

    address public oracleAddress;
    
    constructor (address _oracleAddress) public {
        oracleAddress = _oracleAddress;
    }

    function createQuery (string calldata _company, string calldata _product, string calldata _queryString, address _queryContract, bytes4 _callback) external {
        emit QueryCreated(_company, _product, _queryString, _queryContract, _callback);
    }

    function updateQuery(address _queryContract, bytes4 _callback, uint[] memory _result) public returns (bool){
        require(msg.sender == oracleAddress);
        (bool status,) = _queryContract.call(abi.encodePacked(_callback, uint(32), uint(_result.length), _result));
        require(status);
        return true;
    }
    
    function updateQuery(address _queryContract, bytes4 _callback, address[] memory _result) public returns (bool){
        require(msg.sender == oracleAddress);
        (bool status,) = _queryContract.call(abi.encodePacked(_callback, uint(32), uint(_result.length), _result));
        require(status);
        return true;
    }

    
}

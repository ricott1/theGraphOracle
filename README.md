# The Graph Oracle

The Graph Oracle (TGO) provides an oracle that allows users to exploit the power of the Graph directly from their smart contracts.
```javascript
// Define query
string memory _queryString = "{cryptoKitties(where:{birthTime_gte:1514761200,birthTime_lt:1519858800},first:10) {owner}}";
// Define call back function that would be called when the query is completed
bytes4 _callback = bytes4(keccak256("updateKittyOwner(address[])"));
// Execute the query
oracle.createQuery(_queryHash, _company, _product, _queryString, false, _callback);

```

## Inspiration

[Oracles](https://www.mycryptopedia.com/blockchain-oracles-explained/) are a third-party information source that allow smart contracts to process data coming from the real world directly on the blockchain. They are based on trusted agents, off-chain entities that provide the data.

[The Graph](https://thegraph.com/) is a powerful tool that allows users to query data from leading decentralized projects using an *off-chain* API.

TGO is the last piece of the puzzle, bridging the Graph queries and making them available directly to the blockchain.

We leverage the capabilities of [Skale Sidechains](https://skalelabs.com/) to have lightning fast oraclized Graph queries. Furthermore, using the Skale decentralized file storage API we store the result of queries of any level of complexity, returning their storage ID to retrieve them.

We wrote and deployed the [the TGO subgraph](https://thegraph.com/explorer/subgraph/ricott1/the-graph-oracle) on ropsten, to get data on the oracle itself.

## How we built it

The backbone of TGO is `theGraphOracle.sol` smart contract, written in solidity. The off-chain agent is a python script logging to the oracle events, performing the off-chain API calls and submitting the results. The TGO subgraph is built in graphql.


## How does it work 

TGO works as follows: 

- A smart contract creates a query calling `createQuery` and passing the query company, product and string as parameters
- `theGraphOracle` emits a `QueryCreated` event, which the off-chain agent intercepts
- The off-chain agent performs the query on the Graph API and returns the result (in array form) to the original querying contract by calling a callback function
- If the query has the `_isStorage` flag, the agent stores the result in a file using the Skale storage API

Query examples are provided by the `TestCase.sol` contract.

## What's next

Ideally we would like to provide users with more flexibile queries, allowing them to get arbitrary JSON data instead of only arrays.

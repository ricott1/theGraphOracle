from web3.auto import Web3
import time
from secrets import graph_token
import requests
import json

w3 = Web3(Web3.HTTPProvider("http://ethberlin02.skalenodes.com:10013"))

raw_address = '0xa2545e7ecbe6c7d386e1535d012050f31a0221e6'
contractAddress = Web3.toChecksumAddress(raw_address)
with open("abi.json") as f:
    abi = json.load(f)

contract = w3.eth.contract(address=contractAddress, abi=abi)
contract.address = contractAddress  # THIS LINE!

def create_graphql_request(query):
    url = 'https://api.thegraph.com/subgraphs/name/ensdomains/ens'
    json = { 'query' : query}
    headers = {'Authorization': 'token %s' % graph_token}
    r = requests.post(url=url, json=json, headers=headers)
    print (r.text)
    return 2

while True:
    event_filter = contract.events.QueryCreated.createFilter(fromBlock=0)
    print(event_filter.get_all_entries())

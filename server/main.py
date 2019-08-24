from web3.auto import Web3
import time
from secrets import graph_token, p_key
import requests
import json

w3 = Web3(Web3.HTTPProvider("http://ethberlin02.skalenodes.com:10013"))

contract_address = '0x3e56f8fe5ca525a3e4b80826a70b4265bf9875dd'
contractAddress = Web3.toChecksumAddress(contract_address)
account =  w3.eth.account.from_key(p_key)
w3.eth.defaultAccount = account.address

with open("abi.json") as f:
    abi = json.load(f)

contract = w3.eth.contract(address=contractAddress, abi=abi)
contract.address = contractAddress  # THIS LINE!

def create_graphql_request(company, product, query):
    url = 'https://api.thegraph.com/subgraphs/name/{}/{}'.format(company, product)
    json = { 'query' : query}
    headers = {'Authorization': 'token %s' % graph_token}
    response = requests.post(url=url, json=json, headers=headers)
    return response

length = 0
while True:
    event_filter = contract.events.QueryCreated.createFilter(fromBlock=0)
    print(event_filter.get_all_entries())
    if length < len(event_filter.get_all_entries()):
        event_args = event_filter.get_all_entries()[-1]["args"]
        company = event_args["company"]
        product = event_args["product"]
        query = event_args["queryString"]
        is_storage = event_args.get("isStorageQuery", False)
        response = create_graphql_request(company, product, query)
        con_add = event_args["queryContract"]
        con_call = event_args["callback"]
        x = contract.functions.updateQuery("0x68656c6c6f0000000000000000000000", w3.toChecksumAddress(con_add), w3.toBytes(con_call), [w3.toInt(1), w3.toInt(1), w3.toInt(12), w3.toInt(31), w3.toInt(311)])
        if not is_storage:
            nonce = w3.eth.getTransactionCount(account.address)  
            quert_txn = x.buildTransaction({
                'gas': 300000,
                'gasPrice': w3.toWei('1', 'gwei'),
                'nonce': nonce,
            })
            signed_txn = w3.eth.account.sign_transaction(quert_txn, private_key=p_key)
            w3.eth.sendRawTransaction(signed_txn.rawTransaction)  
        length = len(event_filter.get_all_entries())
    time.sleep(2)

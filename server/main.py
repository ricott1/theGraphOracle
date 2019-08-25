from web3.auto import Web3
import time
from secrets import graph_token, p_key
import requests
import json
import subprocess
import random
import string

w3 = Web3(Web3.HTTPProvider("http://ethberlin02.skalenodes.com:10013"))

contract_address = '0x1f1e8f456f60b7a5435920b54da5525974ab6bfd'
contractAddress = Web3.toChecksumAddress(contract_address)
account =  w3.eth.account.from_key(p_key)
w3.eth.defaultAccount = account.address

with open("abi.json") as f:
    abi = json.load(f)

contract = w3.eth.contract(address=contractAddress, abi=abi)
contract.address = contractAddress  # THIS LINE!

def create_graphql_request(company, product, query):
    url = 'https://api.thegraph.com/subgraphs/name/{}/{}'.format(company, product)
    json_query = { 'query' : query}
    headers = {'Authorization': 'token %s' % graph_token}
    response = requests.post(url=url, json=json_query, headers=headers)
    return json.loads(response.content)

def process_val(val):
    if isinstance(val, int):
        return w3.toInt(val)
    if w3.isAddress(val):
        return w3.toChecksumAddress(val)
    return val

def process_graphql_response(response, is_storage):
    response_data = response["data"]
    if is_storage:
        return response_data
    result = []
    def _get_normalized_response(data):
        if not isinstance(data, list) and not isinstance(data, dict):
            if data is not None:
                result.append(process_val(data))
            return
        for x in data:
            if isinstance(data, list):
                _get_normalized_response(x)
            elif isinstance(data, dict):
                _get_normalized_response(data[x])
    _get_normalized_response(response_data)
    return result

length = 0
while True:
    event_filter = contract.events.QueryCreated.createFilter(fromBlock=0)
    if length < len(event_filter.get_all_entries()):
        event_args = event_filter.get_all_entries()[-1]["args"]
        company = event_args["company"]
        product = event_args["product"]
        query = event_args["queryString"]
        queryhash = event_args["_queryHash"]
        is_storage = event_args.get("isStorageQuery", False)
        response = create_graphql_request(company, product, query)
        con_add = event_args["queryContract"]
        con_call = event_args["callback"]
        print("Query ------> ", query)
        print("")
        graph_result = process_graphql_response(response, is_storage)
        print("Result -----> ", graph_result)
        print("")
        if is_storage:
            file_name = ''.join(random.choices(string.ascii_uppercase + string.digits, k=16))
            return_value = file_name
        else:
            return_value = graph_result

        x = contract.functions.updateQuery(queryhash, w3.toChecksumAddress(con_add), w3.toBytes(con_call), return_value)
        nonce = w3.eth.getTransactionCount(account.address)  
        quert_txn = x.buildTransaction({
            'gas': 300000,
            'gasPrice': w3.toWei('1', 'gwei'),
            'nonce': nonce,
        })
        signed_txn = w3.eth.account.sign_transaction(quert_txn, private_key=p_key)
        w3.eth.sendRawTransaction(signed_txn.rawTransaction)
        if is_storage:
            subprocess.run(["node", "skale_storage.js", file_name, json.dumps(graph_result)])
        length = len(event_filter.get_all_entries())
        print("--------------------------------------")
    time.sleep(2)

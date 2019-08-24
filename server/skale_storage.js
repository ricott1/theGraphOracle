const Filestorage = require('@skalenetwork/filestorage.js/src/index')
const Web3 = require("web3")
const btoa = require("btoa")
async function uploadJson(name, dict) {
    //create web3 connection
    const web3Provider = new Web3.providers.HttpProvider(
        "http://ethberlin02.skalenodes.com:10013"
    );
    let web3 = new Web3(web3Provider);

    //get filestorage instance
    let filestorage = new Filestorage(web3, true);

    //provide your account & private key
    //note this must include the 0x prefix
    let privateKey = '0x' + '[YOUR_PRIVATE_KEY]';
    let account = "[YOUR_ACCOUNT_ADDRESS]";

    //get file data from file upload input field
    let dictstring = JSON.stringify(dict);
    const enc = stringToUint(dictstring);
    //let dec = JSON.parse(uintToString(enc));
    
    let link = filestorage.uploadFile(
        account,
        name,
        enc,
        privateKey
    ).then((res) => {
        console.log(res)
    }).catch((err) => {
        console.log(err)
    });
    console.log(link)
}

function stringToUint(string) {
    var string = btoa(unescape(encodeURIComponent(string))),
        charList = string.split(''),
        uintArray = [];
    for (var i = 0; i < charList.length; i++) {
        uintArray.push(charList[i].charCodeAt(0));
    }
    return new Uint8Array(uintArray);
}

function uintToString(uintArray) {
    var encodedString = String.fromCharCode.apply(null, uintArray),
        decodedString = decodeURIComponent(escape(atob(encodedString)));
    return decodedString;
}

uploadJson("wow2", {"shshs": "dsdsds"})

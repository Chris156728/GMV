import Web3 from "web3";
window.ethereum.enable();

const web3 = new Web3(window.web3.currentProvider);
const kovanDaiAddress = "0xE7d541c18D6aDb863F4C570065c57b75a53a64d3";
//const kovanDaiAddress = "0xe11A86849d99F524cAC3E7A0Ec1241828e332C62";
const minABI = [
      // balanceOf
      {
        "constant":true,
        "inputs":[{"name":"_owner","type":"address"}],
        "name":"balanceOf",
        "outputs":[{"name":"balance","type":"uint256"}],
        "type":"function"
      },
      // decimals
      {
        "constant":true,
        "inputs":[],
        "name":"decimals",
        "outputs":[{"name":"","type":"uint8"}],
        "type":"function"
      },
      {
        "constant": false,
        "inputs": [{name: "_to",type: "address",},{name: "_value",type: "uint256",},],
        "name": "transfer",
        "outputs": [{name: "",type: "bool",},],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function",
      },
      {
        "constant": false,
        "inputs": [{name: "usr",type: "address",},{name: "wad",type: "uint256",},],
        "name": "approve",
        "outputs": [{name: "",type: "bool",},],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function",
      },
	  {
        "constant": false,
        "inputs": [{name: "usr",type: "address",},{name: "wad",type: "uint256",},],
        "name": "allowance",
        "outputs": [{name: "allowance",type: "uint256",},],
        "payable": false,
        "stateMutability": "view",
        "type": "function",
      },
	  
	  //{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"address","name":"spender","type":"address"}],"name":"allowance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},
	  
    ];

export default new web3.eth.Contract(minABI, kovanDaiAddress);
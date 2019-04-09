require("dotenv").config();
const fs = require('fs');

let ContractJsonPath = './build/contracts/WRKChainRoot.json'

function main() {
    let args = process.argv.slice(2);
    let cmd = args[0];
    let network_id = args[1];
    let contract_type = args[2];

    if(cmd === null || cmd === undefined) {
        console.log("Error: No command specified. Requires 'addr' or 'abi'");
        help();
        return;
    }

    if(network_id === null || network_id === undefined) {
        console.log("Error: No Mainchain Network ID.");
        help();
        return;
    }

    if (contract_type == 'slim' || process.env.WRKCHAIN_CONTRACT == 'slim') {
        ContractJsonPath = './build/contracts/WRKChainRootSlim.json';
    }

    let contract = JSON.parse(fs.readFileSync(ContractJsonPath, 'utf8'));

    switch (cmd) {
       case 'abi':
       default:
           abi(contract);
           break;
       case 'addr':
           contract_address(contract, network_id);
           break;
    }
}

function abi(contract) {
    console.log(JSON.stringify(contract.abi));
}

function contract_address(contract, network_id) {
    console.log(contract.networks[network_id].address);
}

function help() {
    console.log("Run:");
    console.log("node abi.js [cmd] [network_id] ([type])")
    console.log("e.g.:")
    console.log("node abi.js addr 50005 slim")
    console.log("node abi.js abi 50005")
}

main();

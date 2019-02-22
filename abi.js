const fs = require('fs');

const ContractJsonPath = './build/contracts/WorkchainRoot.json'


function main() {
    let contract = JSON.parse(fs.readFileSync(ContractJsonPath, 'utf8'));
    console.log(JSON.stringify(contract.abi));
}

main();
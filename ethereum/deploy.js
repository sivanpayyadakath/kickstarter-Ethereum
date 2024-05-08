const HDWalletProvider = require('@truffle/hdwallet-provider');
const { Web3 } = require('web3');
const compiledFactory = require('./build/CampaignFactory.json')

// Very Bad practice
const seedPhase = 'ADD SEED HERE'
const sepholiaNetworkEndpoint = 'https://sepolia.infura.io/v3/675d3f2df71445c4a5ff19cb667d03fc'
const provider = new HDWalletProvider(
    seedPhase,
    sepholiaNetworkEndpoint
);

const web3 = new Web3(provider);

async function deploy() {
    const accounts = await web3.eth.getAccounts();

    console.log('Attempting to deploy from account', accounts[0]);

    const result = await new web3.eth.Contract(JSON.parse(compiledFactory.interface))
        .deploy({ data: compiledFactory.bytecode })
        .send({ gas: 1000000, from: accounts[0] })

    console.log('Contract deployed to', result.options.address);

    provider.engine.stop();
}

deploy();

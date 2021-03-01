const ballot = artifacts.require('ballot');
const Web3 = require('web3');

contract('BallotSmartContract', () => {
   it ('Should deploy the smart contract properly', async () => {
        const ballotSmartContract = await ballot.deployed();
        console.log(ballotSmartContract.address);
        assert(ballotSmartContract.address != '');
   }),

   it ('Should display the winnerName', async () => {
    const ballotSmartContract = await ballot.deployed();
    const winnerNameAscii = await ballotSmartContract.winnerName();
    let winnerName =  Web3.utils.padLeft(Web3.utils.toAscii(winnerNameAscii));
    console.log(winnerName);
    assert(winnerNameAscii == '0x4d616e6f6c6f0000000000000000000000000000000000000000000000000000');
    })
});

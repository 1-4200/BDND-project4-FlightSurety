# BDND-project4-FlightSurety
Udacity Blockchain Developer Nanodegree project4 (Flight Surety)

## Project overview
- Flight Surety is flight delay insurance for passengers
- Managed as a collaboration between multiple airlines
- Passengers purchase insurance prior to flight
- If flight is delayed due to airline fault, passengers are paid 1.5X the amount they paid for the insurance
- Oracles provide flight status information

## Prerequisits
1. Download node_modules by `npm install`
2. Set Ganache workspace https://www.trufflesuite.com/docs/ganache/reference/ganache-settings
    * In section "Server", set the PORT NUMBER as 8545
    * In section "Accounts & Keys", TOTAL ACCOUNTS TO GENERATE shoud be set as 100 accounts
    * In section "Accounts & Keys", copy the mnemonic here
    * In section "Chain", change the GAS LIMIT to 9999999
3. Create `.secret` file and set the above mnemonic in the file, and locate it in the same folder as `truffle.js`
4. Truffle migration by `truffle migrate`

### To run truffle tests:
Test each files separately as follows
- `truffle test ./test/flightSurety.js`
- `truffle test ./test/oracles.js`

### To use the dapp:
`npm run dapp`

### To view dapp:
http://localhost:8000

## Versions
- Truffle v5.0.36 (core: 5.0.36)
- Solidity v0.5.8 (solc-js)
- Node v10.15.3
- Web3.js v1.2.1


## Requirements
1. Separation of Concerns
  - FlightSuretyData contract => data persistence
  - FlightSuretyApp contract => app logic and oracles code
  - Dapp client => triggering contract calls
  - Server app => simulating oracles
2. Airlines
  - Register first airline when contract is deployed
  - Only existing airline may register a new airline until there are at least four airlines registered
  - Registration of fifth and subsequent airlines requires multi-party consensus of 50% of registered airlines
  - Airline can be registered, but does not participate in contract until it submits funding of 10 ether
3. Passengers
  - Passengers may pay upto 1 ether for purchasing flight insurance
  - Flight numbers and timestamps are fixed for the purpose of the project and can be defined in the Daap client
  - If the flight is delayed due to airline fault, passenger receives credit of 1.5X the amount they paid
  - Funds are transferred from contract to the passenger wallet only when they initiate a withdrawal
4. Oracles
  - Oracles are implemented as a server app
  - Upon startup, 20+ oracles are registered and their assigned indexes are persisted in memory
  - Client dapp is used to trigger request to update flight status generating OracleRequest event that is captured by server
5. General
  - Contracts must have operational status control
  - Functions must fail fast -use require() at the start of functions

## Resources

* [How does Ethereum work anyway?](https://medium.com/@preethikasireddy/how-does-ethereum-work-anyway-22d1df506369)
* [BIP39 Mnemonic Generator](https://iancoleman.io/bip39/)
* [Truffle Framework](http://truffleframework.com/)
* [Ganache Local Blockchain](http://truffleframework.com/ganache/)
* [Remix Solidity IDE](https://remix.ethereum.org/)
* [Solidity Language Reference](http://solidity.readthedocs.io/en/v0.4.24/)
* [Ethereum Blockchain Explorer](https://etherscan.io/)
* [Web3Js Reference](https://github.com/ethereum/wiki/wiki/JavaScript-API)

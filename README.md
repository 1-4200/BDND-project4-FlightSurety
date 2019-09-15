# BDND-project4-FlightSurety
Udacity Blockchain Developer Nanodegree project4 (Flight Surety)

## Project overview
- Flight Surety is flight delay insurance for passengers
- Managed as a collaboration between multiple airlines
- Passengers purchase insurance prior to flight
- If flight is delayed due to airline fault, passengers are paid 1.5X the amount they paid for the insurance
- Oracles provide flight status information

## Requirements
1. Separation of Concerns
2. Airlines
  - Register first airline when contract is deployed
  - Only existing airline may register a new airline until there are at least four airlines registered
  - Registration of fifth and subsequent airlines requires multi-party consensus of 50% of registered airlines
  - Airline can be registered, but does not participate in contract until it submits funding of 10 ether
3. Passengers
4.


## How to set up
`npm install`
`ganache-cli -a 50 -l 9999999`

truffle compile
truffle test
truffle migrate

### Develop Client
To run truffle tests:

`truffle test ./test/flightSurety.js`

`truffle test ./test/oracles.js`

To use the dapp:

`truffle migrate`

`npm run dapp`

To view dapp:

http://localhost:8000

### Develop Server
`npm run server`
`truffle test ./test/oracles.js`

### Deploy
To build dapp for prod: 
`npm run dapp:prod`

Deploy the contents of the ./dapp folder

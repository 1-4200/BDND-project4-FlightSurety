pragma solidity ^0.4.25;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract FlightSuretyData {
    using SafeMath for uint256;

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    address private contractOwner;                      // Account used to deploy contract
    bool private operational = true;                    // Blocks all state changes throughout the contract if false

    struct Airline {
        bool isRegistered;
        string name;
        address wallet;
    }
    struct Flight {
        string name;
        bool isRegistered;
        address airline;
        uint8 statusCode;
        uint256 updatedTimestamp;
    }
    struct Insurance {
        Flight flight;
        uint256 value;
        address customer;
    }

    uint private airlineCount = 0;                      // Count how many airlines are registerd
    uint private insuranceCount = 0;                    // Count how many insurances are purchased

    mapping(address => Airline) private airlines;       // Mapping for storing airlines
    mapping(bytes32 => Flight) private flights;         // Mapping for storing flights
    bytes32[] private flight_keys = new bytes32[](0);   // To track all the flights registered
    mapping(uint => Insurance) private insurances;      // Mapping for storing insurances
    address[] private insurees = new address[](0);      // To track all the passenger addresses that have purchased the insurance
    mapping(address => uint256) private refunds;        // Mapping for storing insurance refund refunds
    mapping(address => uint256) private funds;          // Mapping for storing funds
    mapping(address => uint256) private authorizedContracts;    //Mapping for storing authorizedContracts
    
    uint256 public constant INSURANCE_MAX_FEE = 1 ether;    //maximum value of purchasing flight insurance
    uint256 public constant AIRLINE_MIN_FUNDS = 10 ether;   //minimum value of participating in contract

    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/
    event InsureeCredited(address insuree, uint credit, uint total);
    event debug(uint i, address insuree, bytes32 id, address airline, string flight, uint256 ftimestamp, uint256 value);


    /**
    * @dev Constructor
    *      The deploying account becomes contractOwner
    */
    constructor() public {
        contractOwner = msg.sender;
    }

    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
    * @dev Modifier that requires the "operational" boolean variable to be "true"
    *      This is used on all state changing functions to pause the contract in
    *      the event there is an issue that needs to be fixed
    */
    modifier requireIsOperational() {
        require(operational, "Contract is currently not operational");
        _;  // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner(){
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    modifier isCallerAuthorized() {
        require(authorizedContracts[msg.sender] == 1, "Caller is not authorized");
        _;
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    /**
    * @dev Get operating status of contract
    *
    * @return A bool that is the current operating status
    */
    function isOperational() public view returns(bool) {
        return operational;
    }


    /**
    * @dev Sets contract operations on/off
    *
    * When operational mode is disabled, all write transactions except for this one will fail
    */
    function setOperatingStatus(bool mode) external requireContractOwner {
        operational = mode;
    }

    function authorizeCaller(address caller) public requireContractOwner {
        require(authorizedContracts[caller] == 0, "Address already authorized");
        authorizedContracts[caller] = 1;
    }

    function deauthorizeCaller(address caller) public requireContractOwner {
        require(authorizedContracts[caller] == 1, "Address was not authorized");
        authorizedContracts[caller] = 0;
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

   /**
    * @dev Add an airline to the registration queue
    *      Can only be called from FlightSuretyApp contract
    *
    */
    function registerAirline (string name, address wallet) external isCallerAuthorized {
        airlines[wallet] = Airline({
            isRegistered: true,
            name: name,
            wallet: wallet
        });
        airlineCount = airlineCount.add(1);
    }

    function isAirlineRegistered(address wallet) external view returns (bool) {
        return airlines[wallet].isRegistered;
    }

    function isAirlineFunded (address wallet) external view returns (bool) {
        return funds[wallet] >= AIRLINE_MIN_FUNDS;
    }

    function getAirlineCount () external view returns (uint256) {
        return airlineCount;
    }
   /**
    * @dev Register a future flight for insuring.
    *
    */
    function registerFlight(string name, uint256 timestamp, address airline) external isCallerAuthorized {
        bytes32 id = getFlightKey(airline, name, timestamp);
        require(!flights[id].isRegistered, "Flight is already registered.");
        flights[id].name = name;
        flights[id].isRegistered = true;
        flights[id].airline = airline;
        flights[id].statusCode = 0;
        flights[id].updatedTimestamp = timestamp;
        flight_keys.push(id);
    }
    function isFlightRegistered(string name, uint256 timestamp, address airline) external view returns (bool) {
        bytes32 id = getFlightKey(airline, name, timestamp);
        return flights[id].isRegistered;
    }
   /**
    * @dev Buy insurance for a flight
    * passengers purchase insurance prior to flight
    */
    function buy(string flight, uint256 timestamp, address airline, address insuree)external payable isCallerAuthorized{
        bytes32 id = getFlightKey(airline, flight, timestamp);
        require(flights[id].isRegistered, "Flight does not exist");

        uint insurance_value = 0;

        if (msg.value >= INSURANCE_MAX_FEE) {
            insurance_value = INSURANCE_MAX_FEE;
        } else {
            insurance_value = msg.value;
        }

        insurances[insuranceCount].flight = flights[id];
        insurances[insuranceCount].customer = insuree;
        insurances[insuranceCount].value = insurance_value;
        insuranceCount = insuranceCount.add(1);
        insurees.push(insuree);
    }

    /**
     *  @dev Credits refund payouts to insurees
     *  If flight is delayed due to airline fault,
     *  passengers are paid 1.5X the amount they paid for the insurance
    */
    function creditInsurees (string flight, uint256 timestamp, address airline) external isCallerAuthorized{
        bytes32 id = getFlightKey(airline, flight, timestamp);
        for (uint i = 0; i < insurees.length; ++i) {
            address insuree = insurances[i].customer;
            bytes32 id2 = getFlightKey(insurances[i].flight.airline, insurances[i].flight.name, insurances[i].flight.updatedTimestamp);
            emit debug(i, insurances[i].customer, id, airline, flight, timestamp, 0);
            emit debug(i, insurances[i].customer, id2, insurances[i].flight.airline, insurances[i].flight.name, insurances[i].flight.updatedTimestamp, insurances[i].value);
            if(insurances[i].value == 0) continue;
            if (id == id2) {
                uint256 value = insurances[i].value;
                uint256 half = value.div(2);
                insurances[i].value = 0;
                uint256 refund = value.add(half);                   // calculating 1.5X the amount the passenger paid for the insurance
                refunds[insuree] = refunds[insuree].add(refund);
                emit InsureeCredited(insuree, refund, refunds[insuree]);
            }
        }
    }

    /**
     *  @dev Transfers eligible payout funds to insuree
     *
    */
    function pay(address insuree)external payable isCallerAuthorized{
        uint refund = refunds[insuree];
        refunds[insuree] = 0;
        insuree.transfer(refund);
    }

   /**
    * @dev Initial funding for the insurance. Unless there are too many delayed flights
    *      resulting in insurance refunds, the contract should be self-sustaining
    *
    */
    function fund(address sender) external payable isCallerAuthorized{
        require(msg.value > 0, "No funds are not allowed");
        funds[sender] = funds[sender].add(msg.value);
    }


    function getFlightKey(address airline, string memory flight, uint256 timestamp) pure internal returns(bytes32) {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    /**
    * @dev Fallback function for funding smart contract.
    * when someone just sent Ether to the contract without providing any data
    * or if someone messed up the types so that they tried to call a function that does not exist.
     */
    function() external payable{
        require(msg.value > 0, "No funds are not allowed");
        funds[msg.sender] = funds[msg.sender].add(msg.value);   //receive funds instead of causing an exception
    }
}


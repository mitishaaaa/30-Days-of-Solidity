
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TipJar {
    address public owner;
    
    uint256 public totalTipsReceived;
    
    // For example, if 1 USD = 0.0005 ETH, then the rate would be 5 * 10^14
    mapping(string => uint256) public conversionRates;

    mapping(address => uint256) public tipPerPerson;
    string[] public supportedCurrencies;  // List of supported currencies
    mapping(string => uint256) public tipsPerCurrency;
    
    constructor() {
        owner = msg.sender;
        addCurrency("USD", 5 * 10**14);  // 1 USD = 0.0005 ETH
        addCurrency("EUR", 6 * 10**14);  // 1 EUR = 0.0006 ETH
        addCurrency("JPY", 4 * 10**12);  // 1 JPY = 0.000004 ETH
        addCurrency("INR", 7 * 10**12);  // 1 INR = 0.000007ETH ETH
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    
}

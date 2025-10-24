// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// THis is a standalone contract that only holds state variables --- it doesnt include any functions

contract SubscriptionStorageLayout{
    address public logicContract; // this stores current implementation address. its used by the proxy contract to know where to forward calls using delegatecall
    address public owner; //  this keeps the track of the admin of the contract

    struct Subscription{
        uint8 planId; //the identifier for the user's plan
        uint256 expiry; // timestamp indicating the expiry
        bool paused; // a toggle to temporarily deactivate user's subscription
    }

    mapping(address => Subscription) public subscriptions; // each user (address) gets their own Subcription object
    mapping(uint8 => uint256) public planPrices; // this defines how much Eth each plan costs
    mapping(uint8 => uint256) public planDuration; // this tells how long each plan lasts
}

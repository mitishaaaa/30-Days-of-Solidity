  
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SubscriptionStorageLayout.sol"; // the logic contract

  
contract SubscriptionLogicV1 is SubscriptionStorageLayout {

    // this contract handles: adding new plans, susbcribing users, checking active status

function addPlan(uint8 planId, uint256 price, uint256 duration) external{
    planPrices[planId] = price; // each planId represents unique plan (1= Basic, 2 = pro). stored in mapping. Plan ID -> Price
    planDuration[planId] = duration; // Plan ID -> Duration
}

function subscribe(uint8 planId) external payable{
    require(planPrices[planId] > 0, "Invalid pland"); // check if the plan is valid
    require(msg.value >= planPrices[planId], "Insufficient payment"); 


Subscription storage s = subscriptions[msg.sender];
if (block.timestamp < s.expiry){ 
    s.expiry += planDuration[planId]; // if the user already has time left: add new duration to current expiry
}
else{
    s.expiry = block.timestamp + planDuration[planId];
}// if the subscription expired: add new duration to the current expiry. It's a fresh subscription.

s.planId = planId; // to record the plan they chose
s.paused = false; // unpause the subscription 
}

function isActive(address user) external view returns (bool){ 
    Subscription memory s = subscriptions[user];
    return (block.timestamp < s.expiry && !s.paused);
} // let anyone check if a user's subscription is currently active.
}

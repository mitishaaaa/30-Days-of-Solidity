// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SubscriptionStorageLayout.sol";

contract SubscriptionStorage is SubscriptionStorageLayout{
    modifier onlyOwner(){ // this modifier is used to protect sensitive functions likek upgrading the contract
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _logicContract){ // this is the function that runs once when the proxy is first deployed
        owner = msg.sender; // the deployer becomes the owner
        logicContract = _logicContract; // you pass in the address of ur initial logic contract
    }
    
    function upgradeTo(address _newLogic) external onlyOwner{ // this function is what makes the entire upgradeable architecture possible
        logicContract = _newLogic; // it updates logicContract to point to a new contract (like SubscriptionLogicV2)
    }

    fallback() external payable{ // fallback is a special function that gets triggered whenever a user calls a function that doesn't exist in this proxy contract
        address impl = logicContract; // makes sure a logic contract has been set
        require(impl != address(0), "Logic contract not set"); // store it in impl

        assembly{
            calldatacopy(0, 0, calldatasize()) // copy the input data(function signature + arguments) to memory slot 0
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0,0)
           // this is the main event. we're saying: " hey, run this input on the logic contract(impl).."
           // delegatecall runs the logic code, but uses this proxy’s storage and this proxy’s context.

            returndatacopy(0, 0, returndatasize())
            //Copy whatever came back from the logic contract’s execution to memory.
            //Could be a return value or an error message.
            
            switch result
            case 0 { revert(0, returndatasize()) }
            default {return(0, returndatasize()) }

            //if the logic call failed, we revert and return the error.
            //Otherwise, we return the result back to the original caller — as if the proxy had executed it itself.
        }

    }

    receive() external payable{}
    // A safety net that lets the proxy **accept raw ETH transfers**.

}

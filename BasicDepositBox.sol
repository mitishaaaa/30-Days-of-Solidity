// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BaseDepositBox.sol";

contract BasicDepositBox is BaseDepositBox{

 function getBoxType() external pure override returns(string memory){
    return "Basic";
 } 
}
 /* externanl: this function is only meant to be called from outside the contract
 pure: it doesnt read or write any storage. it simply returns a hardcoded string
 override: its overriding the abstract getBoxType() function declared in IDepositBox
 
 Why is this useful?
 lets say you have many boxes deployed - Basic, Premium, TimeLocked and you want to know what type each box is.
 */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BaseDepositBox.sol";

contract TimeLockedDepositBox is BaseDepositBox{ // This contract introduces a twist: you can store a secret, but cant retrieve it until a specific time has passed


  uint256 private unlockTime;

  constructor(uint256 lockDuration){
    unlockTime = block.timestamp + lockDuration;
  }

  modifier timeUnlocked(){
    require(block.timestamp >= unlockTime, "Box is still time locked");
    _;
  }

  function getBoxType() external pure override returns (string memory){
    return "TimeLocked";
  }

  function getSecret() public view override onlyOwner timeUnlocked returns (string memory){
    return super.getSecret(); 
    //timeUnlocked: only after the unlock time has passed
    // super.getSecret() = “Call the base contract’s version of getSecret().”
    // Used when you want to add conditions or modify access but still use the parent’s implementation.
  }

  function getUnlockTime() external view returns (uint256){
    return unlockTime;
  } // getter function to know when the box becomes unlockable


  function getRemainingLockTime() external view returns (uint256){
    if (block.timestamp >= unlockTime) return 0; // if the current time is already past the unlock time, we return 0.
    return unlockTime - block.timestamp; // or else we subtract now from unlockTime and return the number of seonds left untilit can be opened
  } 

}
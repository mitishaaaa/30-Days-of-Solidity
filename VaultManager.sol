// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IDepositBox.sol";
import "./BasicDepositBox.sol"; 
import "./PremiumDepositBox.sol";
import "./TimeLockedDepositBox.sol";

contract VaultManager{

 mapping(address => address[]) private userDepositBoxes; // Maps a user’s address to all the deposit boxes they own (as contract addresses).
 mapping(address => string) private boxNames; // Lets users assign custom names to each of their boxes. 

 event BoxCreated(address indexed owner, address indexed boxAddress, string boxType); // emits every time a user creates a new box
 event BoxNamed(address indexed boxAddress, string name); // fires when a user gives a nickname to their box

 function createBasicBox() external returns (address){
    BasicDepositBox box = new BasicDepositBox(); // this line deploys a new BasicDepositBox contract and stores its address in the variable box
    userDepositBoxes[msg.sender].push(address(box)); // adds the new box to the list of boxes owned by the sender
    emit BoxCreated(msg.sender, address(box), "Basic");
    return address(box);

 }


 function createPremiumBox() external returns (address){
    PremiumDepositBox box = new PremiumDepositBox(); // when this line runs, the contract PremiumDepositBox is deployed on chain and the user who called becomes the owner
    userDepositBoxes[msg.sender].push(address(box)); 
    //This line adds the address of the new box to the list of deposit boxes owned by the user.
    // userDepositBoxes is a mapping of users -> list of their box addresses. updating the list by addind thhis new box
    emit BoxCreated(msg.sender, address(box), "Premium");
    // who created, which box was created, what type of box
    return address(box);
 }

 function createTimeLockedBox(uint256 lockDuration) external returns (address){
    TimeLockedDepositBox box = new TimeLockedDepositBox(lockDuration);
    userDepositBoxes[msg.sender].push(address(box));
    emit BoxCreated(msg.sender, address(box), "TimeLocked");
    return address(box);
 }


 function nameBox(address boxAddress, string calldata name) external{
    /* box address is a function parameter
     when nameBox is called, owner must pass the address of the box they want to name(boxAddress)
     the nickname they want to give(name) */
    IDepositBox box = IDepositBox(boxAddress);
    // it treats the given address (boxAddress) as a contract that follows IDepositBox interface
    require(box.getOwner() == msg.sender, "Not the box owner");
    // This checks that the caller of this function (msg.sender) is the actual owner of that box.

    boxNames[boxAddress] = name; //This saves the nickname in a mapping.
    emit BoxNamed(boxAddress, name);
 }

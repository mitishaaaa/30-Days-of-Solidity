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
       /* this function lets user give a nickname to one of their deposit boxes:
       it take two inputs: boxAddress - the address of the deposit box contract the user wants to name
       name - the nickname the user wants to asasign 
       it treats the given address(boxAddress) as a contract that follows the IDepositBox interface. */
    IDepositBox box = IDepositBox(boxAddress);
       // it treats the given address (boxAddress) as a contract that follows IDepositBox interface
    require(box.getOwner() == msg.sender, "Not the box owner");
       // This checks that the caller of this function (msg.sender) is the actual owner of that box.

    boxNames[boxAddress] = name; //This saves the nickname in a mapping.
    emit BoxNamed(boxAddress, name);
 }
  
 function storeSecret(address boxAddress, string calldata secret) external{
    /* address boxAddress: the address of the box you want to store the secret in.
      string calldata secret: the secret message (a string) you want to store.
      external: means this function is meant to be called from outside, like from a frontend or another contract.
   */
    IDepositBox box = IDepositBox(boxAddress);
    require(box.getOwner() == msg.sender, "Not the owner");

    box.storeSecret(secret);
 }
 
 function transferBoxOwnership(address boxAddress, address newOwner) external{
   
   IDepositBox box = IDepositBox(boxAddress);
   //turn the given address(boxAddress) into a usable contract, using the IDepositBox interface
   
   require(box.getOwner() == msg.sender,"Not the box owenr");

   box.transferOwnership(newOwner);

   address[] storage boxes = userDepositBoxes[msg.sender];
   for (uint i = 0; i < boxes.length; i++){ // Loop through each box you own
      if (boxes[i] == boxAddress){  // If this is the one being transferred...
         boxes[i] = boxes[boxes.length - 1]; // Replace it with the last one
         boxes.pop(); // Remove the last one (now duplicated)
         break; // Stop looping since we’re done
      }
   }

   // Add box to new owner
   userDepositBoxes[newOwner].push(boxAddress);
 } 


 function getUserBoxes(address user) external view returns (address[] memory){
   return userDepositBoxes[user];
 }

 function getBoxName(address boxAddress) external view returns (string memory){
   return boxNames[boxAddress];
 }

 function getBoxInfo(address boxAddress) external view returns(
   string memory boxType,
   address owner,
   uint256 depositTime,
   string memory name
 )
 
 {
   IDepositBox box = IDepositBox(boxAddress);
   return(
      box.getBoxType(),
      box.getOwner(),
      box.getDepositTime(),
      boxNames[boxAddress]
   );
 }
}

 

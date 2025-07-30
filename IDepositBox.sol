 //SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; 

interface IDepositBox {
    function getOwner() external view returns (address); // returns the current owner of the box
    function transferOwnership(address newOwner) external; //  allows transferring ownership to someone else
    function storeSecret(string calldata secret) external; // a function to save a string ("our secret") inside the vault
    function getSecret() external view returns (string memory); // retrieves the stored secret
    function getBoxType() external pure returns (string memory); // let us know what kind of box it is
    function getDepositTime() external view returns (uint256); // returns when the bpx was created
}


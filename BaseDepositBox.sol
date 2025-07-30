// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IDepositBox.sol";

abstract contract BaseDepositBox is IDepositBox{ // abstract means this contract can't be deployed directly but serves as a base for other contracts
    address private owner; // stores the address of the person who owns this deposit box
    string private secret; // a private strinf that user can store securely
    uint256 private depositTime; // records the exact timie when the box was deployed

    event OwnerTransferred(address indexed previousOwner, address indexed newOwner);
    event SecretStored(address indexed owner);

    modifier  onlyOwner() {
        require(msg.sender == owner, "Not the box owner");
        _;
    }

    constructor(){
        owner = msg.sender;
        depositTime = block.timestamp;
    }

    function getOwner() public view override returns (address)
{
    return owner;
}

function transferOwnership(address newOwner) external virtual override onlyOwner{ // only owner ensures that only the curretn owner can transfer ownership
    require(newOwner != address(0), "New owner cannot be zero address");
    emit OwnerTransferred(owner, newOwner); // emits an event to signal the ownership chane
    owner = newOwner;
}

function storeSecret(string calldata _secret) external virtual override onlyOwner{
    // we use callData cos its cheaper on gas when passing in string arguments
    secret = _secret;
    emit SecretStored(msg.sender);
}

function getSecret() public view virtual override onlyOwner returns (string memory){
    return secret;
}

function getDepositTime() external view virtual override returns (uint256){
    return depositTime;
}

}

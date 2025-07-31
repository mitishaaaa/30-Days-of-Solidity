// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BaseDepositBox.sol";

contract PremiumDepositBox is BaseDepositBox{
    string private metadata;

    event MetadataUpdated(address indexed owner);

    function getBoxType() external pure override returns(string memory){
        return "Premium";
    }

    function setMetaData(string calldata _metadata) external onlyOwner{ 
        /* external: only callable from outside the contract (not internally)
        onlyOwner: uses our modifier from BaseDepositBox to restrict access
        */
       
        metadata = _metadata;
        emit MetadataUpdated(msg.sender);
    }
    
    function getMetadata() external view onlyOwner returns (string memory) {
    return metadata;
    }

}
   
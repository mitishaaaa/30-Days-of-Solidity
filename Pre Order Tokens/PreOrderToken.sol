// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./MyToken.sol";

contract PreOrderToken is MyToken {
    uint256 public tokenPrice;
    uint256 public saleStartTime;
    uint256 public saleEndTime;
    uint256 public minPurchase;
    uint256 public maxPurchase;
    uint256 public totalRaised;
    address public projectOwner;
    bool public finalized = false;
    bool private initialTransferDone = false;

    event TokenPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount);
    event SaleFinalized(uint256 totalRaised, uint256 totalTokenSold);

    constructor(
        uint256 _initialSupply,
        uint256 _tokenPrice, 
        uint256 _saleDurationInSeconds,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        address _projectOwner
    )

    MyToken(_initialSupply){
        tokenPrice = _tokenPrice,
        saleStartTime = block.timestamp;
        saleEndTime = block.timestamp + _saleDurationInSeconds;
    }
}

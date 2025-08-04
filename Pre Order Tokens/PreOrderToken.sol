//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./MyToken.sol";

contract PreOrderToken is MyToken { //this contract inherits from MyToken so it uses the same logic

   uint256 public tokenPrice;             // Price of 1 token in wei
uint256 public saleStartTime;         // Timestamp when the sale starts
uint256 public saleEndTime;           // When sale ends
uint256 public minPurchase;           // Minimum ETH a buyer must send
uint256 public maxPurchase;           // Maximum ETH a buyer can send
uint256 public totalRaised;           // Total ETH collected
address public projectOwner;          // Who can finalize the sale
bool public finalized = false;        // Is sale over and unlocked?
bool private initialTransferDone = false; // Used to lock tokens during sale

    event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount);
    event SaleFinalized(uint256 totalRaised, uint256 totalTokensSold);

    constructor( 
        uint256 _intitialSupply, // Calls the base token contract with _initialSupply.
        uint256 _tokenPrice,
        uint256 _saleDurationInSeconds,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        address _projectOwner)
        MyToken(_intitialSupply){
        tokenPrice = _tokenPrice;
        saleStartTime = block.timestamp;
        saleEndTime = block.timestamp + _saleDurationInSeconds;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        projectOwner = _projectOwner;
     

    _transfer(msg.sender, address(this), totalSupply); // Moves all tokens from the deployer to the contract so that the contract can sell them to users.
    initialTransferDone = true; // Used later to check if tokens are locked.
    }

    function isSaleActive()public view returns(bool){
        return(!finalized && block.timestamp >= saleStartTime && block.timestamp <= saleEndTime);
    }

    function buyTokens() public payable{
        require(isSaleActive(), "Sale is not active");
        require(msg.value >= minPurchase, "Amount is below min purchase");
        require(msg.value <= maxPurchase, "Amount is above max purchase");
        uint256 tokenAmount = (msg.value * 10**uint256(decimals))/ tokenPrice;
        require(balanceOf[address(this)] >= tokenAmount, "Not enough tokens left for sale");
        totalRaised+= msg.value;
        _transfer(address(this),msg.sender,tokenAmount);
        emit TokensPurchased(msg.sender, msg.value, tokenAmount);
        
    }

    function transfer(address _to, uint256 _value)public override returns(bool){
        if(!finalized && msg.sender != address(this) && initialTransferDone){
            require(false, "Tokens are locked until sale is finalized");
        }

        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value)public override returns(bool){
        if(!finalized && _from != address(this)){
            require(false, "Tokens are locked until sale is finalized");
        }
        return super.transferFrom(_from, _to, _value);
        //Locks transfers until sale ends, except:
       // If sale is finalized
       // Or sender is the contract itself (used for selling tokens)
      //Prevents people from reselling during the sale.
    }

    function finalizeSale() public payable{
        require(msg.sender == projectOwner, "Only owner can call this function");
        require(!finalized,"Sale is already finalized");
        require (block.timestamp > saleEndTime, "Sale not finished yet");
        finalized = true;
        uint256 tokensSold = totalSupply - balanceOf[address(this)];
        (bool sucess,) = projectOwner.call{value:  address(this).balance}("");
        require(sucess, "Transfer failed");
        emit SaleFinalized(totalRaised, tokensSold);
    }

    function timeRemaining() public view  returns(uint256){
        if(block.timestamp >= saleEndTime){
            return 0;
        }
        return (saleEndTime - block.timestamp);
    }

    function tokensAvailable()public view returns(uint256){
        return balanceOf[address(this)];
    }

    receive() external payable{
        buyTokens();
    }
}



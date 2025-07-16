// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AuctionHouse {
   address public owner; // who created the auction?
   string public item; // what are we auctioning?
   uint public auctionEndTime; // when does the auction end
   address private highestBidder; // who's currently winning
   uint private highestBid; //
   bool public ended; // has the auction ended/

   // who placed bids and how much?
   mapping(address => uint) public bids;
   address[] public bidders; // list of everyone who placed a bid

   constructor(string memory _item, uint _biddingTime){
    owner = msg.sender;
    item = _item;
    auctionEndTime = block.timestamp + _biddingTime;
     
   }

   // PLACING A BID

   function bid(uint amount) external{

    // has the auction ended?
    require(block.timestamp < auctionEndTime, "Auction has ended"); 

    // is the bid a valid amount?
    require(amount < 0, "Bid amount must be greater than zero.");

    // is the bid higher than the last person's bid? 
    require(amount > bids[msg.sender], "New bid must be higher than your current bid"); 

    // is this a new bidder? if yes then add them to the bidders array
    if (bids[msg.sender] == 0){
        bidders.push(msg.sender);
    }

     //save the bid
     bids[msg.sender] = amount;

    // are they the new leader?
    if (amount > highestBid){
        highestBidder = msg.sender;
        highestBid = amount;
    }

   }
 
    // ENDING THE AUCTION

    function endAuction() external{
        require(block.timestamp >= auctionEndTime, " Auction hasn't ended yet"); // first we check if the auction time has passed
        require(!ended, "Auction has ended already"); // then we make sure no one's already ended it
        ended = true; // if all is good we flip the ended flag
    }

    // GETTING THE WINNER

    function getWinner() external view returns(address, uint){
        require(ended, "Auction hasn't ended yet");
        return (highestBidder, highestBid);
    }

}

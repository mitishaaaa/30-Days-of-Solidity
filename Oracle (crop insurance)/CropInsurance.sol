
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CropInsurance is Ownable {
    AggregatorV3Interface private weatherOracle;
    AggregatorV3Interface private ethUsdPriceFeed;

    uint256 public constant RAINFALL_THRESHOLD = 500;
    uint256 public constant INSURANCE_PREMIUM_USD = 10;
    uint256 public constant INSURANCE_PAYOUT_USD = 50;

    mapping(address => bool) public hasInsurance;
    mapping(address => uint256) public lastClaimTimestamp;

    event InsurancePurchased(address indexed farmer, uint256 amount);
    event ClaimSubmitted(address indexed farmer);
    event ClaimPaid(address indexed farmer, uint256 amount);
    event RainfallChecked(address indexed farmer, uint256 rainfall);

    constructor(address _weatherOracle, address _ethUsdPriceFeed) payable Ownable(msg.sender) { 
        // - `address _weatherOracle`: This is the address of our rainfall oracle (like the mock we built earlier).
        // - `address _ethUsdPriceFeed`: This is the address of a Chainlink price feed that gives us ETH → USD conversion.
        weatherOracle = AggregatorV3Interface(_weatherOracle); // We save both oracle addresses for use in later functions.
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
    }

    function purchaseInsurance() external payable {
        uint256 ethPrice = getEthPrice();
        uint256 premiumInEth = (INSURANCE_PREMIUM_USD * 1e18) / ethPrice; 
        // premiumInEth: We convert our $10 premium into ETH (multiplied by 1e18 for wei precision).

        require(msg.value >= premiumInEth, "Insufficient premium amount");
        require(!hasInsurance[msg.sender], "Already insured");

        hasInsurance[msg.sender] = true;
        emit InsurancePurchased(msg.sender, msg.value);
    }

    function checkRainfallAndClaim() external {
        require(hasInsurance[msg.sender], "No active insurance");
        require(block.timestamp >= lastClaimTimestamp[msg.sender] + 1 days, "Must wait 24h between claims");
        // This ensures they can only claim once every 24 hours, enforced earlier:
        (
            uint80 roundId, // store 1st returned value
            int256 rainfall, // store 2nd returned value
            ,               // ignore 3rd returned value (startedAt) 
            uint256 updatedAt, // store 4th returned value
            uint80 answeredInRound // store 5th returned value
        ) = weatherOracle.latestRoundData();

        require(updatedAt > 0, "Round not complete");
        require(answeredInRound >= roundId, "Stale data");

        uint256 currentRainfall = uint256(rainfall);
        emit RainfallChecked(msg.sender, currentRainfall);

        // CHECKS IF INSURANCE CONDITON IS MET
        //if rainfall is LESS THAN 500 mm → crops are assumed damaged → pay insurance
        if (currentRainfall < RAINFALL_THRESHOLD) {
            lastClaimTimestamp[msg.sender] = block.timestamp; // Store timestamp so they can't keep claiming + require(block.timestamp >= lastClaimTimestamp[msg.sender] + 1 days, "Must wait 24h between claims");

            emit ClaimSubmitted(msg.sender);

            uint256 ethPrice = getEthPrice();
            uint256 payoutInEth = (INSURANCE_PAYOUT_USD * 1e18) / ethPrice;

            (bool success, ) = msg.sender.call{value: payoutInEth}(""); // call{value: ...}("") is the recommended way to send ETH now.
            require(success, "Transfer failed");

            emit ClaimPaid(msg.sender, payoutInEth);
        }
        /** 1. Oracle says rainfall = X
            2. If X < threshold (500 mm)
            ✅ mark claim time
            ✅ calculate $50 → ETH based on real-time price
            ✅ send ETH to wallet
            ✅ log events
            3. Else → do nothing, no payout */
 

    }

    function getEthPrice() public view returns (uint256) {
        (
            ,
            int256 price,
            ,
            ,
        ) = ethUsdPriceFeed.latestRoundData();

        return uint256(price);
    }

    function getCurrentRainfall() public view returns (uint256) {
        (
            ,
            int256 rainfall,
            ,
            ,
        ) = weatherOracle.latestRoundData();

        return uint256(rainfall);
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    receive() external payable {}

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

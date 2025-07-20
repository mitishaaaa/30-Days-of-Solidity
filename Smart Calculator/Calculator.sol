// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ScientificCalculator.sol";

contract Calc{
  address public owner;
  address public scientificCalcAddress;

  constructor(){
    owner = msg.sender;
  }

  modifier onlyOwner(){
    require(msg.sender == owner, "Only owner can do this action");
    _;
  }

  function setScientificCalc(address _address) public onlyOwner{
    scientificCalcAddress = _address;
  }

  function add(uint256 a, uint256 b) public pure returns (uint256){
    uint256 result = a + b;
    return result;
  }

  function subtract(uint256 a, uint256 b) public pure returns (uint256){
    uint256 result = a - b;
    return result;
  }
 function multiply(uint256 a, uint256 b) public pure returns (uint256)
{
  uint256 result = a * b;
  return result;
    
}

function divide(uint256 a, uint256 b) public pure returns (uint256)
{
    require(b != 0, "Cannot divide by zero");
    uint256 result = a / b;
    return result;
}



function calculatePower(uint256 base, uint256 exponent) public view returns (uint256) {
    ScientificCalculator scientificCalc = ScientificCalculator(scientificCalcAddress);
    // Address Casting: SomeContract myContract = SomeContract(someAddress);
    uint256 result = scientificCalc.power(base, exponent);
    return result;
}


function calculateSquareRoot(uint256 number) public returns (uint256){

  require (number >= 0, " Cannot calculate square root of negative number");

  bytes memory data = abi.encodeWithSignature("squareRoot(uint256)", number);
  (bool success, bytes memory returnData) = scientificCalcAddress.call(data);
  require(success, "External call failed");
  uint256 result = abi.decode(returnData, (uint256));
  return result;
    }

}

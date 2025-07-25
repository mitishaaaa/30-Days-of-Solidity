// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PollStation{

string[] public candidateNames;
mapping(string => uint256) voteCount;

function addCandidateNames(string memory _candidateNames) public {
    candidateNames.push(_candidateNames);
    voteCount[_candidateNames]= 0;
}

function vote(string memory _candidateNames) public{
    voteCount[_candidateNames] += 1;
}

function getCandidateNames() public view returns(string[] memory){
    return candidateNames;
}

function getVotesByCandidateName(string memory _candidateNames)public view returns (uint256){
    return voteCount[_candidateNames];
 }
}

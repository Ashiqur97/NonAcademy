// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract voting {
    address public owner;

    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
    }

     mapping(uint256 => Candidate) public candidates;
    mapping (address => bool) public voters;
    uint256 public candidatesCount;


    function initialize() public {
        require(owner == address(0), "Contract is already initialized");
        owner = msg.sender;
    }

    function addCandidate(string memory _name) public {
        require(msg.sender == owner, "Only owner can add the candidate");
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
    }

  function getVotes(uint256 _candidateId) public view returns (uint256) {
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate ID");
        return candidates[_candidateId].voteCount; 
    }

    




}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    struct Proposal {
        string description;
        uint256 yesVotes;
        uint256 noVotes;
        bool exists;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(address => mapping(uint256 => bool)) public hasVoted;
    uint256 public proposalCount;

    event ProposalCreated(uint256 indexed proposalId, string description);
    event Voted(uint256 indexed proposalId, address indexed voter, bool support);

    function createProposal(string memory _description) public {
        uint256 newProposalId = proposalCount + 1;
        proposals[newProposalId] = Proposal({
            description: _description,
            yesVotes: 0,
            noVotes: 0,
            exists: true
        });
        proposalCount = newProposalId;
        emit ProposalCreated(newProposalId, _description);
    }

    function vote(uint256 _proposalId, bool _support) public {
        require(proposals[_proposalId].exists, "Proposal does not exist");
        require(!hasVoted[msg.sender][_proposalId], "Already voted");

        if (_support) {
            proposals[_proposalId].yesVotes++;
        } else {
            proposals[_proposalId].noVotes++;
        }

        hasVoted[msg.sender][_proposalId] = true;
        emit Voted(_proposalId, msg.sender, _support);
    }

    function getResults(uint256 _proposalId) public view returns (uint256 yesVotes, uint256 noVotes) {
        require(proposals[_proposalId].exists, "Proposal does not exist");
        Proposal memory proposal = proposals[_proposalId];
        return (proposal.yesVotes, proposal.noVotes);
    }
}

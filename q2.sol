// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 < 0.9.0;

contract VotingSystem {
    struct Proposal {
        string description;
        uint256 voteCount;
    }

    address public owner;
    Proposal[] public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    event ProposalCreated(uint256 proposalId, string description);
    event Voted(uint256 proposalId, address voter);

    constructor() {
        owner = msg.sender;
    }

    // Function to propose a new option
    function propose(string calldata _description) external {
        require(bytes(_description).length > 0, "Description cannot be empty");

        proposals.push(Proposal({
            description: _description,
            voteCount: 0
        }));

        emit ProposalCreated(proposals.length - 1, _description);
    }

    // Function to cast a vote
    function vote(uint256 _proposalId) external {
        require(_proposalId < proposals.length, "Invalid proposal ID");
        require(!hasVoted[_proposalId][msg.sender], "Address has already voted for this proposal");

        hasVoted[_proposalId][msg.sender] = true;
        proposals[_proposalId].voteCount += 1;

        emit Voted(_proposalId, msg.sender);
    }

    // Function to get the number of proposals
    function getProposalsCount() external view returns (uint256) {
        return proposals.length;
    }

    // Function to get proposal details
    function getProposal(uint256 _proposalId) external view returns (string memory description, uint256 voteCount) {
        require(_proposalId < proposals.length, "Invalid proposal ID");
        Proposal storage proposal = proposals[_proposalId];
        return (proposal.description, proposal.voteCount);
    }

    // Function to get the winning proposal
    function getWinningProposal() external view returns (uint256 winningProposalId) {
        require(proposals.length > 0, "No proposals available");

        uint256 winningVoteCount = 0;
        winningProposalId = 0;

        for (uint256 i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winningProposalId = i;
            }
        }
    }
}


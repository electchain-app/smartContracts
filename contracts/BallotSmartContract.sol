// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.5.16 <=0.8.0;

/** 
 * @title BallotSmartContract
 * @dev Implements voting process
 */
contract BallotSmartContract {
   
    struct Voter {
        uint weight; // 1 if eligible to vote
        bool voted;  // if true, that person already voted
        uint proposalVote;   // index of the voted proposal
        uint presidentialVote;  // index of the voted presidential candidate
        uint senatorialVote;  // index of the voted senatorial candidate
    }

    struct Candidate {
        // If you can limit the length to a certain number of bytes, 
        // always use one of bytes1 to bytes32 because they are much cheaper
        bytes32 name;   // short name (up to 32 bytes)
        uint voteCount; // number of accumulated votes
    }

    struct Proposal {
        // If you can limit the length to a certain number of bytes, 
        // always use one of bytes1 to bytes32 because they are much cheaper
        bytes32 name;   // short name (up to 32 bytes)
        uint voteCount; // number of accumulated votes
    }

    // Election Officials that can start/end the election.
    address[] public officials;
    address public chairperson;

    mapping(address => Voter) public voters;

    Proposal[] public proposals;
    Candidate[] public presidentialCandidates;
    Candidate[] public senatorialCandidates;

    /** 
     * @dev Create a new ballot to choose a proposal and candidate.
     * @param proposalNames names of proposals
     * @param presidentialNames names of candidates
     * @param senatorialNames position of candidate
     */
    constructor(bytes32[] memory proposalNames, 
                bytes32[] memory presidentialNames,
                bytes32[] memory senatorialNames) public {
    
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        for (uint i = 0; i < proposalNames.length; i++) {
            // 'Proposal({...})' creates a temporary
            // Proposal object and 'proposals.push(...)'
            // appends it to the end of 'proposals'.
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }

        for (uint i = 0; i < presidentialNames.length; i++) {
            presidentialCandidates.push(Candidate({
                name: presidentialNames[i],
                voteCount: 0
            }));
        }        

        for (uint i = 0; i < senatorialNames.length; i++) {
            senatorialCandidates.push(Candidate({
                name: senatorialNames[i],
                voteCount: 0
            }));
        }
    }
    
    /** 
     * @dev Give 'voter' the right to vote on this ballot. May only be called by 'chairperson'.
     * @param voter address of voter
     */
    function giveRightToVote(address voter) public {
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote."
        );
        require(
            !voters[voter].voted,
            "The voter already voted."
        );
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

    /**
     * @dev Give your vote (including votes delegated to you) to proposal 'proposals[proposal].name'.
     * @param proposal index of proposal in the proposals array
     */
    function vote(uint proposal, uint president, uint senator) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.presidentialVote = president;
        sender.senatorialVote = senator;
        sender.proposalVote = proposal;

        // If 'proposal' is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        proposals[proposal].voteCount += sender.weight;
        presidentialCandidates[proposal].voteCount += sender.weight;
        senatorialCandidates[proposal].voteCount += sender.weight;
    }

    /** 
     * @dev Computes the winning proposal taking all previous votes into account.
     * @return winningProposal_ index of winning proposal in the proposals array
     */
    function winningProposal() public view
            returns (uint winningProposal_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    /**
     * @dev Computes the winning presidential candidate taking all previous votes into account.
     * @return winningCandidate_ index of winning candidate in the presidentialCandidates array
     */
    function winningPresidentialCandidate() public view
            returns (uint winningCandidate_)
    {
        uint winningVoteCount = 0;
        for (uint c = 0; c < presidentialCandidates.length; c++) {
            if (presidentialCandidates[c].voteCount > winningVoteCount) {
                winningVoteCount = presidentialCandidates[c].voteCount;
                winningCandidate_ = c;
            }
        }
    }

    /**
     * @dev Computes the winning senatorial candidate taking all previous votes into account.
     * @return winningCandidate_ index of winning candidate in the senatorialCandidates array
     */
    function winningSenatorialCandidate() public view
            returns (uint winningCandidate_)
    {
        uint winningVoteCount = 0;
        for (uint c = 0; c < senatorialCandidates.length; c++) {
            if (senatorialCandidates[c].voteCount > winningVoteCount) {
                winningVoteCount = senatorialCandidates[c].voteCount;
                winningCandidate_ = c;
            }
        }
    }

    /** 
     * @dev Calls winningProposalName() function to get the index of the winner contained in the proposals array and then
     * @return winnerName_ the name of the winner
     */
    function winningProposalName() public view
            returns (bytes32 winnerName_)
    {
        winnerName_ = proposals[winningProposal()].name;
    }

    /** 
     * @dev Calls winningPresidentialName() function to get the index of the winner contained in the presidentialCandidates array and then
     * @return winnerName_ the name of the winner
     */
    function winningPresidentialName() public view
            returns (bytes32 winnerName_)
    { 
        winnerName_ = presidentialCandidates[winningPresidentialCandidate()].name;
    }

    /** 
     * @dev Calls winningSenatorialName() function to get the index of the winner contained in the senatorialCandidates array and then
     * @return winnerName_ the name of the winner
     */
    function winningSenatorialName() public view
            returns (bytes32 winnerName_)
    {
        winnerName_ = senatorialCandidates[winningSenatorialCandidate()].name;
    }
}

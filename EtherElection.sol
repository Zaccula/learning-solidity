// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <=0.8.17;

contract EtherElection {
    struct Candidate {
        bool enrolled;
        uint8 votes;
    }
    uint8 candidateCount = 0;
    mapping(address => Candidate) candidates;
    mapping(address => bool) hasVoted;
    address private winner;
    address private host;
    bool contestOver;
    bool rewardClaimed;

    constructor() {
        host = msg.sender;
    }

    function enroll() public payable {
        // Write your code here
        require(!candidates[msg.sender].enrolled, "You've already enrolled.");
        require(candidateCount < 3, "Three candidates have already enrolled.");
        require(msg.value == 1 ether, "Enrollment costs exactly 1 ETH.");
        candidateCount++;
        candidates[msg.sender].votes = 0;
        candidates[msg.sender].enrolled = true;
    }

    function vote(address candidate) public payable {
        // Write your code here
        require(!hasVoted[msg.sender], "You may only vote once.");
        require(candidates[candidate].enrolled, "This candidate has not enrolled.");
        require(!contestOver, "The contest is already over.");
        require(msg.value == 10000, "Voting costs exactly 10,000 wei.");
        candidates[candidate].votes++;
        if (candidates[candidate].votes == 3) {
            contestOver = true;
            winner = candidate;
        }
        hasVoted[msg.sender] = true;
    }

    function getWinner() public view returns (address) {
        // Write your code here
        require(contestOver, "The contest is not yet over!");
        return winner;
    }

    function claimReward() public {
        // Write your code here
        require(contestOver, "The contest is not yet over!");
        require(msg.sender == winner, "Only the contest winner may claim the reward.");
        require(!rewardClaimed, "You already claimed the reward!");
        rewardClaimed = true;
        (bool sent,) = payable(winner).call{value: 3 ether}("");
        require(sent, "Reward claim could not be processed. Reverting.");
    }

    function collectFees() public {
        // Write your code here
        require(contestOver, "This function cannot be executed until the contest is over.");
        require(rewardClaimed, "The winner has not yet claimed their reward.");
        require(msg.sender == host, "Only the host may execute this function.");
        selfdestruct(payable(host));
    }

    function getEnrolledCount() public view returns (uint8) {
        return candidateCount;
    }
}
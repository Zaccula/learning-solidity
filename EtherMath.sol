// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.17;

contract EtherMath {
    address owner; // address type is a the address of a wallet or other contract
    address lastWinner;
    bool latestSolved;
    mapping(address => bool) currentChallengeAttempted; // mapping type is a key-value store
    mapping(address => uint) playerRewards;
    address[] latestSolvers;
    struct Challenge {
        int256[] question;
        int256 target;
        uint256 reward;
        bool solved;
    }
    Challenge currentChallenge;
    event challengeSolved(Challenge challenge, address solver); // event type is a way to log data to the transaction history on-chain

    constructor() { // constructor is a function that runs once when the contract is deployed
        owner = msg.sender; // msg.sender is the address of the account that originally deployed the contract (e.g. your wallet)
        latestSolved = true;
    }

    // modifiers are used to add a repeatable condition to a function
    modifier onlyOwner() {
      require(msg.sender == owner, "Only the contract owner may call this function.");
      // the underscore is a placeholder for the rest of the function body, so this is like a wrapper of sorts
      _;
    }

    // private functions cannot be called from outside the contract, pure functions cannot read or write contract state
    function validAnswer(int256[] memory array, int256 target) private pure returns (bool) {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == target) {
                return true;
            } 
        }
        return false;
    }

    function submitChallenge(int256[] memory array, int256 targetSum) public payable onlyOwner {
        require(latestSolved, "Current challenge has not yet been solved.");
        require(msg.value > 0, "Must offer a non-zero reward in a challenge.");
        latestSolved = false;
        currentChallenge = Challenge(array, targetSum, msg.value, false); 
        for (uint256 i = 0; i < latestSolvers.length; i++) {
            currentChallengeAttempted[latestSolvers[i]] = false;
        }
        delete(latestSolvers);
    }

    function submitSolution(int256[] memory solution) public {
        require(!latestSolved, "This challenge has already been solved.");
        require(!currentChallengeAttempted[msg.sender], "You've already attempted a solution for this challenge.");
        int256 sum = 0;
        for (uint256 j = 0; j < solution.length; j++) {
            if (!validAnswer(currentChallenge.question, solution[j])) {
                revert(); // revert statements are used to revert the transaction if a condition is not met
            }
            sum += solution[j];
        }
        if (sum == currentChallenge.target) {
            // set winner
            currentChallenge.solved = true;
            latestSolved = true;
            playerRewards[msg.sender] += currentChallenge.reward;
            lastWinner = msg.sender;
            emit challengeSolved(currentChallenge, msg.sender); // emit statements are used to log your event data
        }
        latestSolvers.push(msg.sender);
    }

    function claimRewards() public {
        require(playerRewards[msg.sender] > 0, "You currently have no rewards to claim.");
        uint256 reward = playerRewards[msg.sender];
        playerRewards[msg.sender] = 0;
        (bool sent,) = payable(msg.sender).call{value: reward}(""); // send ether to the caller
        require(sent, "Reward claim could not be processed. Reverting.");
    }

    // Debugging Views - Remove before deploying to production
    function getSolvers() public view returns (address[] memory) {
        return latestSolvers;
    }

    function getLastWinner() public view returns (address) {
        return lastWinner;
    }

    function getCurrentChallenge() public view returns (Challenge memory) {
        return currentChallenge;
    }
}
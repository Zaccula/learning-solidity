// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <=0.8.17;

contract GreedyBanker {
    struct Account {
        bool freebieUsed;
        uint balance;
    }
    // using the immutable keyword changes the EVM opcode used when accessing from SLOAD to PUSH32, costing less gas
    address immutable private banker;
    mapping(address => Account) bank;

    constructor() {
        banker = msg.sender;
    }

    receive() external payable {
        if (bank[msg.sender].freebieUsed) {
            require(msg.value > 1000 wei, "Deposit must be greater than 1000 wei.");
            bank[banker].balance += 1000;
            bank[msg.sender].balance += (msg.value - 1000);
        } else {
            bank[msg.sender].freebieUsed = true;
            bank[msg.sender].balance += msg.value;
        }
    }

    fallback() external payable {
        bank[banker].balance += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(bank[msg.sender].balance >= amount, "You cannot withdraw more than your current balance.");
        bank[msg.sender].balance -= amount;
        (bool withdrawn, ) = payable(msg.sender).call{value: amount}("");
	if (!withdrawn) revert();
    }

    function collectFees() external {
        require(msg.sender == banker, "You are not the bank manager.");
        uint oldAmount = bank[banker].balance;
        // Setting balance to 0 before sending to prevent re-entrancy attack
        bank[banker].balance = 0;
        (bool withdrawn,) = payable(banker).call{value: oldAmount}("");
	if (!withdrawn) revert();
    }

    function getBalance() public view returns (uint256) {
        require(bank[msg.sender].freebieUsed || msg.sender == banker, "You have no active account with this bank.");
        return bank[msg.sender].balance;
    }
}

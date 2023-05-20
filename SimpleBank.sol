// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0. <0.9.0;

contract SimpleBank {
    mapping(address => uint) balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function checkBalance() public view returns (uint) {
        return balances[msg.sender];
    }

    function withdraw(uint amount) public {
        uint currentBalance = checkBalance();
        require(currentBalance >= amount, "Insufficient balance to withdraw.");
        address user = msg.sender;
         // set new balance before payment to prevent reentrancy attack
        balances[user] = currentBalance - amount;
        (bool withdrawn,) = payable(user).call{value: amount}("");
        require(withdrawn, "Withdrawal could not be processed.");
        assert(balances[user] == currentBalance - amount);
    }
}
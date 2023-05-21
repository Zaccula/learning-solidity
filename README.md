# Learning Solidity

Just a few short, self-contained contracts written while learning Solidity, following a course online.

**EtherElection** - Run an "election" between three contenders, who each pay 1 ETH. Each address (including the contenders) only gets one vote, and once one contender has three votes they can withdraw 3 ETH from the balance. Afterwards (and only afterwards!) the host can kill the contract and collect all other fees.

**EtherMath** - Run a simple game where the host can post up arithmetic challenges, providing an array of allowed numbers, the desired sum, and the challenge reward. Players then need to submit an array of the allowed numbers that add up to the desired sum. If correct, the reward for that challenge is added to a balance for the player, which can be withdrawn at any time, and the host can submit a new challenge.

**SimpleBank** - Users can deposit funds into the contract and withdraw them at any time, or check their active balance. Contract creator cannot take from the funds, nor is there any function to selfdestruct.

**FancyShirts** - Users can "buy" shirts using a few specific combos of size and color. This one was meant to mostly demonstrate uses of enum, but in figuring out how to solve this problem I also figured out how to use a combo hash as a mapping key. Whether or not this is a good/cost efficient approach... not sure yet.

**GreedyBanker** - Similar to SimpleBank, but after the initial deposit a constant fee of 1,000 wei is sent to the contract owner for each deposit. Withdrawals are always free.
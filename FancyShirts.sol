// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <=0.8.17;

contract FancyShirts {
    enum Size {
        SMALL,
        MEDIUM,
        LARGE
    }

    enum Color {
        RED,
        GREEN,
        BLUE
    }

    struct Customer {
        mapping (bytes32 => uint) purchases;
    }

    mapping (address => Customer) customers;

    function getShirtPrice(Size size, Color color) public pure returns (uint) {
        uint cost = 0;
        if (size == Size.SMALL) {
            cost += 10;
        } else if (size == Size.MEDIUM) {
            cost += 15;
        } else if (size == Size.LARGE) {
            cost += 20;
        }
        if (color == Color.GREEN || color == Color.BLUE) {
            cost += 5;
        }
        return cost;
    }

    function buyShirt(Size size, Color color) external payable {
        require(msg.value == getShirtPrice(size, color));
        // hash the combo of size and color to create a unique identifier to use as a mapping key
        bytes32 comboId = keccak256(abi.encodePacked(size, color));
        customers[msg.sender].purchases[comboId] += 1;
    }

    function getShirts(Size size, Color color) public view returns (uint) {
        bytes32 comboId = keccak256(abi.encodePacked(size, color));
        return customers[msg.sender].purchases[comboId];
    }
}
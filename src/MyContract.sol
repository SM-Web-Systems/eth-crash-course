// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

contract SimpleBank {
    address public owner;
    mapping(address => uint256) public balances;

    event Deposit(address user, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // Implement this function to allow users to withdraw their funds
    function withdraw(uint256 _amount) public {}
}

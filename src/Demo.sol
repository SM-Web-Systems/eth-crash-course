// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

contract Demo {
    /* STATE VARIABLES   */
    uint256 public number;
    address internal owner;
    uint256 private userId;

    struct User {
        address userAddress;
        uint256 numberSet;
        bool isActive;
    }

    // This tracks the number set by each user
    mapping(uint256 userId => User userData) public userData;

    /* MODIFIERS   */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    /* EVENTS   */
    event NumberChanged(uint256 oldNumber, uint256 newNumber);

    /* CONSTRUCTOR   */
    constructor() {
        owner = msg.sender;
        userId = 1;
    }

    /* PUBLIC FUNCTIONS   */
    function setNumber(uint256 _newNumber) public onlyOwner {
        uint256 oldNumber = number;
        number = _newNumber;
        emit NumberChanged(oldNumber, _newNumber);
    }

    function increment() public {
        uint256 oldNumber = number;

        userData[userId] = User({
            userAddress: msg.sender,
            numberSet: number,
            isActive: true
        });

        incrementNumber();

        emit NumberChanged(oldNumber, number);
    }

    /* INTERNAL FUNCTIONS   */
    function incrementNumber() internal {
        number++;
    }

    /* VIEW FUNCTIONS   */
    function getOwner() public view returns (address) {
        return owner;
    }

    /* PURE FUNCTIONS   */
    function add(uint256 _a, uint256 _b) public pure returns (uint256) {
        return _a + _b;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

contract SimpleVault {
    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public minDepositAmount;
    address public owner;

    mapping(address user => uint256 balance) public balances;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event SimpleVaultInitialized(uint256 minDepositAmount, address owner);
    event MinDepositAmountUpdated(uint256 newMinDepositAmount);

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(uint256 _minDepositAmount) {
        minDepositAmount = _minDepositAmount;
        owner = msg.sender;

        emit SimpleVaultInitialized(minDepositAmount, owner);
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function deposit() external payable {
        require(msg.value >= minDepositAmount, "Deposit amount too low");

        balances[msg.sender] += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) external {
        require(_amount > 0, "Cannot withdraw zero");
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        balances[msg.sender] -= _amount;
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Withdrawal failed");

        emit Withdrawal(msg.sender, _amount);
    }

    /*//////////////////////////////////////////////////////////////
                            ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function setMinDepositAmount(
        uint256 _newMinDepositAmount
    ) external onlyOwner {
        minDepositAmount = _newMinDepositAmount;

        emit MinDepositAmountUpdated(_newMinDepositAmount);
    }

    /*//////////////////////////////////////////////////////////////
                           INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _onlyOwner() internal view {
        require(msg.sender == owner, "Only owner can call this function");
    }
}

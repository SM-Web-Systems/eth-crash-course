# Module 3 — Introduction to Solidity

## Goal
By the end of this module, you will be able to:
- Write a complete smart contract
- Understand state variables
- Use functions correctly
- Apply visibility rules
- Work with data types
- Use mappings and structs
- Emit events
- Write basic modifiers
- Avoid common beginner security mistakes

We will move carefully:
- Analogy → Syntax → Line-by-line explanation → Gas notes → Mistakes → Exercises

---

## Topics

### 1. What Is Solidity?

If the EVM is the CPU…
- Solidity is the language we use to write programs for it.

You do NOT write directly in opcodes.
- You write Solidity → it compiles → becomes EVM bytecode.

Solidity is a statically typed, contract-oriented programming language designed for writing smart contracts that run on:
- Ethereum

It compiles to EVM bytecode.

---

### 2. Basic File Structure

Every Solidity file typically begins with:
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
```

#### Line-by-Line Explanation
```solidity
// SPDX-License-Identifier: MIT
```
- License declaration. Required by many tools.

```solidity
pragma solidity ^0.8.20;
```
- Compiler version constraint.
- The `^` means:
  - Compatible with 0.8.20 and above (but below 0.9.0).

Never use floating pragmas like:
```solidity
pragma solidity >=0.8.0;
```
This can introduce unexpected compiler behavior changes.

---

### 3. Contract Structure

Minimal contract:
```solidity
pragma solidity ^0.8.20;

contract MyContract {

}
```
Think of a contract as:
- A class deployed permanently on the blockchain.

But unlike normal classes:
- It persists state
- It has its own address
- It costs gas to interact with

---

### 4. State Variables

State variables are stored permanently in storage.

Example:
```solidity
contract Counter {
    uint256 public count;
}
```
#### Line-by-Line Explanation
```solidity
uint256 public count;
```
- `uint256` → unsigned 256-bit integer
- `public` → auto-generates a getter
- `count` → stored in contract storage

#### Gas Consideration
- **Reading** → cheap
- **Writing** → expensive (`SSTORE`)

Storage writes are among the most expensive operations in the EVM.

---

### 5. Functions

Functions define behavior.

Example:
```solidity
contract Counter {
    uint256 public count;

    function increment() public {
        count += 1;
    }
}
```
#### Line-by-Line Explanation
```solidity
function increment() public
```
- `public` → callable externally and internally

```solidity
count += 1;
```
- Loads from storage
- Adds 1
- Writes back to storage

#### Gas Insight
This operation:
- Performs `SLOAD`
- Performs `ADD`
- Performs `SSTORE`

The `SSTORE` dominates cost.

---

### 6. Function Visibility

Solidity has 4 visibility types:

| Visibility | Who Can Call? |
|------------|---------------|
| `public`   | Anyone         |
| `external` | Only external callers |
| `internal` | Only this contract & derived contracts |
| `private`  | Only inside this contract |

#### Example
```solidity
function internalFunction() internal {}
```

---

### 7. View and Pure Functions

Example:
```solidity
function getCount() public view returns (uint256) {
    return count;
}
```
- `view` → does not modify state
- `pure` → does not read or modify state

#### Why It Matters
- `view`/`pure` functions cost no gas when called off-chain.
- They still cost gas if called inside a transaction.

---

### 8. Data Types

Common types:
- `uint256`
- `int256`
- `bool`
- `address`
- `string`
- `bytes`

#### Example
```solidity
address public owner;
bool public paused;
```

Use smaller types carefully:
- `uint8`
- `uint16`

Packing only saves gas when variables share a storage slot.

---

### 9. Mappings

Mappings are key-value stores.

#### Example
```solidity
mapping(address => uint256) public balances;
```

Like a dictionary in Python:
```python
balances[user] = 100
```

Mappings:
- Cannot be iterated
- Return default value if key doesn’t exist
- Live in storage

Mappings DO NOT behave like arrays.
- They do not store keys.

---

### 10. Structs

Structs group related data.

#### Example
```solidity
struct User {
    uint256 balance;
    bool exists;
}

mapping(address => User) public users;
```

#### Why Structs Matter
They allow more complex data modeling.

---

### 11. Events

Events are logs stored in transaction receipts.

#### Example
```solidity
event Deposit(address indexed user, uint256 amount);

function deposit() public payable {
    emit Deposit(msg.sender, msg.value);
}
```

#### Why Events Matter
Smart contracts cannot:
- Push notifications
- Call webhooks

Events allow off-chain systems to react.

---

### 12. Modifiers

Modifiers enforce reusable rules.

#### Example
```solidity
modifier onlyOwner() {
    require(msg.sender == owner, "Not owner");
    _;
}

function withdraw() public onlyOwner {
}
```

#### What `_` Means
`_` is where the function body executes.

#### Security Importance
Modifiers are heavily used for:
- Access control
- Pausable contracts
- Validation logic

---

### 🧠 Putting It All Together

Example contract combining everything:
```solidity
pragma solidity ^0.8.20;

contract SimpleBank {

    address public owner;

    mapping(address => uint256) public balances;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }
}
```

#### ⚠️ Security Note
The `withdraw` function above is vulnerable to reentrancy if implemented incorrectly (we will fix this in Module 5).

Security thinking starts now.

---

### 🧩 Module 3 Recap

You now understand:
- Solidity structure
- State variables
- Visibility rules
- Gas implications
- Mappings and structs
- Events
- Modifiers

You can now write real smart contracts.

#### 🧠 Reflection Questions
- Why are storage writes expensive?
- What’s the difference between `view` and `pure`?
- Why can’t mappings be iterated?
- Why are events critical for frontends?
- Why is access control so important?

#### 🧪 Exercises

**Exercise 1**
Write a contract that:
- Stores an owner
- Has a function only the owner can call
- Emits an event

**Exercise 2**
Create a contract with:
- A struct for a Product
- A mapping of ID → Product
- A function to create a product

**Exercise 3 (Gas Thinking)**
Which is cheaper and why?
```solidity
balances[msg.sender] += 1;
```
vs
```solidity
uint256 temp = 1;
```
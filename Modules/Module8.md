# Module 8 — Mini Projects (Guided + Practical)

## 🎯 Module Objective

By the end of this module, students will:

- Apply Solidity fundamentals independently
- Design simple state models
- Implement access control correctly
- Use events properly
- Think about security while building
- Deploy and test contracts in Remix
- Debug beginner mistakes confidently

---

## 🧠 Teaching Structure Per Project

Each project follows:

1. 🧩 Problem explanation (analogy first)
2. 📋 Requirements
3. 🧱 State design planning
4. 🧪 Starter code
5. 🔍 Guided walkthrough
6. ⚠️ Common mistakes
7. 🛠 Exercises
8. 🚀 Extension challenges

---

## 🥇 Project 1 — Simple Storage (State Fundamentals)

### 🧩 Analogy First

Imagine a digital whiteboard where anyone can write a number, and anyone can read the latest number written.

That’s it. We are building the simplest persistent storage possible.

### 📋 Requirements

- Store a number.
- Retrieve the number.
- Emit an event when updated.

### 🧠 Step 1 — Design the State

We need:

- One `uint`.
- One event.

### 🧪 Starter Code

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleStorage {

    uint256 private storedNumber;

    event NumberUpdated(address indexed updater, uint256 newValue);

    function set(uint256 _number) public {
        storedNumber = _number;
        emit NumberUpdated(msg.sender, _number);
    }

    function get() public view returns (uint256) {
        return storedNumber;
    }
}
```

### 🔍 Walkthrough

- `uint256 private storedNumber;`
  - Stored in blockchain storage (expensive but persistent).
- `event NumberUpdated`
  - Events are logs — cheaper than storage and useful for frontends.
- `set()`
  - Updates state.
  - Emits event.
- `get()`
  - `view` means no state change.
  - Costs no gas if called off-chain.

### ⚠️ Common Beginner Mistakes

- Forgetting `view`.
- Not understanding events.
- Making storage variable public accidentally.
- Not understanding gas difference between storage vs view calls.

### 🛠 Exercises

1. Modify contract to store two numbers.
2. Add a function to reset to zero.
3. Restrict updates to only the deployer.

### 🚀 Extension Challenge

- Add a timestamp of the last update.

---

## 🥈 Project 2 — Beginner ERC-20 Style Token

We will **NOT** implement the full ERC-20 standard yet. We focus on understanding balances + transfers.

### 🧩 Analogy First

Imagine a spreadsheet:

| Address | Balance |
|---------|---------|
| Alice   | 100     |
| Bob     | 50      |

We are building that spreadsheet on-chain.

### 📋 Requirements

- Assign initial supply to deployer.
- Track balances.
- Allow transfers.
- Emit transfer events.
- Prevent negative balances.

### 🧠 State Design

We need:

- `mapping(address => uint256) balances`
- `uint256 totalSupply`
- `string name`
- `string symbol`
- `event Transfer`

### 🧪 Starter Code

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BasicToken {

    string public name = "Beginner Token";
    string public symbol = "BTK";
    uint256 public totalSupply;

    mapping(address => uint256) public balances;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply;
        balances[msg.sender] = _initialSupply;
    }

    function transfer(address _to, uint256 _amount) public returns (bool) {

        require(_to != address(0), "Invalid address");
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        balances[msg.sender] -= _amount;
        balances[_to] += _amount;

        emit Transfer(msg.sender, _to, _amount);

        return true;
    }
}
```

### 🔍 Walkthrough

- **Mapping**
  - Stores balance per address.
- **Constructor**
  - Runs once. Assigns full supply to deployer.
- **`transfer()`**
  - **CHECKS:**
    - Not zero address.
    - Enough balance.
  - **EFFECTS:**
    - Decrease sender.
    - Increase receiver.
  - **INTERACTION:**
    - None (safe).

### ⚠️ Beginner Mistakes

- Forgetting balance check.
- Updating receiver before sender.
- Not emitting event.
- Sending to zero address.
- Not understanding that mappings return 0 by default.

### 🛠 Exercises

1. Add `mint()` restricted to owner.
2. Add `burn()` function.
3. Prevent transfers if paused (add pause logic from Module 5).

### 🚀 Extension Challenge

- Add simple allowance system (`approve` + `transferFrom`).

---

## 🥉 Project 3 — Voting Contract

Now we introduce:

- Structs.
- Arrays.
- Mappings.
- Access control.
- Multi-user state.

### 🧩 Analogy First

Imagine a classroom vote:

1. Teacher creates proposal.
2. Students vote once.
3. Votes are counted.

We will implement that.

### 📋 Requirements

- Owner creates proposals.
- Users can vote once per proposal.
- Count votes.
- Emit events.

### 🧠 State Design

We need:

- **Proposal:**
  - `string name`
  - `uint voteCount`
- `mapping(address => bool) hasVoted`
- `Proposal[] proposals`
- `address owner`

### 🧪 Starter Code

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Voting {

    struct Proposal {
        string name;
        uint256 voteCount;
    }

    address public owner;
    Proposal[] public proposals;

    mapping(address => bool) public hasVoted;

    event ProposalCreated(string name);
    event Voted(address indexed voter, uint256 proposalIndex);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function createProposal(string memory _name) public onlyOwner {
        proposals.push(Proposal(_name, 0));
        emit ProposalCreated(_name);
    }

    function vote(uint256 proposalIndex) public {
        require(!hasVoted[msg.sender], "Already voted");
        require(proposalIndex < proposals.length, "Invalid proposal");

        hasVoted[msg.sender] = true;
        proposals[proposalIndex].voteCount += 1;

        emit Voted(msg.sender, proposalIndex);
    }

    function getProposalCount() public view returns (uint256) {
        return proposals.length;
    }
}
```

### 🔍 Walkthrough

- **Struct**
  - Custom data type.
- **`Proposal[]`**
  - Dynamic array in storage.
- **Mapping `hasVoted`**
  - Prevents double voting.
- **`vote()`**
  - **CHECKS:**
    - Has not voted.
    - Proposal exists.
  - **EFFECTS:**
    - Mark voted.
    - Increase vote count.
  - No external calls → safe from reentrancy.

### ⚠️ Common Mistakes

- Forgetting to mark `hasVoted`.
- Not validating index.
- Using memory incorrectly.
- Not restricting proposal creation.

### 🛠 Exercises

1. Allow multiple proposals per round.
2. Reset voting.
3. Add deadline using `block.timestamp`.

### 🚀 Advanced Challenge

- Implement per-proposal vote tracking:
  ```solidity
  mapping(uint => mapping(address => bool))
  ```

---

## 🧪 Practical Deployment Assignment

Students must:

1. Deploy all 3 contracts in Remix.
2. Interact manually.
3. Test edge cases:
   - Transfer more than balance.
   - Vote twice.
   - Create proposal as non-owner.
4. Observe events in Remix console.

---

## 🧠 Recap: Skills Built

By now students understand:

✔ State variables.
✔ Mappings.
✔ Structs.
✔ Arrays.
✔ Events.
✔ Access control.
✔ Security patterns.
✔ Checks-Effects-Interactions.
✔ Gas awareness.
✔ Multi-user logic.

They can now read most beginner smart contracts confidently.

---

## 📚 Suggested Homework

1. Combine Token + Voting:
   - Only token holders can vote.
2. Add pause functionality to Voting contract.
3. Add withdraw function with safe pattern.
4. Write 5 test cases in plain English for each contract.

---

## 📊 Suggested Assessment Strategy

### 🧪 Practical Final

Students must build:

1. A token with:
   - Mint.
   - Burn.
   - Pause.
   - Ownership transfer.
2. And explain:
   - Where reentrancy could occur.
   - Why their contract is safe.

---

## 🎓 Instructor Recording Note

At this point emphasize:

- “You are no longer learning Solidity syntax. You are designing state machines.”

That mental shift is what separates developers from smart contract engineers.
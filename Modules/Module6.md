# Module 6 — Smart Contract Security Fundamentals

## 🎯 Module Objective

By the end of this module, students will:

- Understand why smart contract security is different from traditional backend security
- Recognize common beginner vulnerabilities
- Understand how reentrancy works conceptually
- Learn the Checks-Effects-Interactions pattern
- Implement basic access control safely
- Understand why immutability increases risk
- Develop a “security-first” mindset

---

## 🧠 Part 1 — Why Smart Contract Security Is Different

### 🧩 Analogy First

- **In Web2:**
  - If your backend has a bug → You patch the server → Deploy → Done.
- **In Ethereum:**
  - If your contract has a bug → It is deployed on-chain → It cannot be changed → Funds may be lost forever.

Smart contracts are immutable once deployed (unless designed with upgradeability patterns, which we are not covering yet).

### Key Points:

- You cannot SSH into Ethereum.
- You cannot hotfix production.
- You cannot delete the database.

### 🧠 Technical Explanation

Smart contracts are deployed bytecode stored at an address on Ethereum. Once deployed, the code at that address does not change.

Every transaction interacting with that contract executes the same immutable code.

**This is why security is not optional — it is foundational.**

---

## 🛑 Part 2 — Reentrancy (The Most Famous Vulnerability)

### 🧩 Analogy First

Imagine an ATM:

1. You request $100.
2. The ATM hands you the cash.
3. THEN it updates your balance.

If you could somehow interrupt it between step 2 and 3, you could keep requesting more money before your balance updates.

That’s reentrancy.

### 🧠 What Is Reentrancy?

Reentrancy occurs when:

1. A contract sends ETH to an external address.
2. That external address calls back into the original contract **before the first execution finishes.**

Because Ethereum allows contracts to call other contracts, execution can “jump” unexpectedly.

### ❌ Vulnerable Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableVault {
    mapping(address => uint) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint amount) public {
        require(balances[msg.sender] >= amount, "Not enough balance");

        // Interaction happens first
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send");

        // Effect happens after
        balances[msg.sender] -= amount;
    }
}
```

### 🔎 Why Is This Dangerous?

Step-by-step:

1. User calls `withdraw`.
2. Contract sends ETH.
3. Receiving contract executes fallback function.
4. Fallback calls `withdraw()` again.
5. Balance has not yet decreased.
6. Funds are drained.

### 🛡️ Fix: Checks-Effects-Interactions Pattern

**Rule:**

1. Check conditions.
2. Update state.
3. Interact with external contracts.

### ✅ Fixed Version

```solidity
function withdraw(uint amount) public {
    require(balances[msg.sender] >= amount, "Not enough balance");

    // EFFECT
    balances[msg.sender] -= amount;

    // INTERACTION
    (bool sent, ) = msg.sender.call{value: amount}("");
    require(sent, "Failed to send");
}
```

Now if reentry happens:
- Balance is already reduced.

### 🧠 Concept Diagram (Textual)
```
User
  ↓
Contract.withdraw()
  ↓
[Check]
  ↓
[Update state]
  ↓
[External call]
  ↓
Return
```

State is updated **BEFORE** giving control away.

### 💡 Beginner Mistakes

- Sending ETH before updating state.
- Using `call()` without understanding fallback behavior.
- Not considering that contracts can call back.

### 🎯 Reflection Question

Why is reentrancy only possible when interacting with external contracts?

---

## 🔢 Part 3 — Integer Overflows & Underflows

### 🧩 Analogy First

Imagine your calculator only handles numbers 0–999.

- If you subtract 1 from 0, it rolls back to 999.

That’s underflow.

### 🧠 Historical Context

Before Solidity 0.8.0, integers would overflow silently.

**Example:**
```solidity
uint8 x = 255;
x = x + 1; // becomes 0
```

But since Solidity 0.8.0, overflow & underflow automatically revert.

This is built-in protection.

### 💡 Beginner Mistakes

- Assuming older contracts behave the same.
- Using `unchecked {}` without understanding risk.

### 🧠 Key Takeaway

Solidity 0.8+ protects you by default, but arithmetic errors still matter for business logic.

---

## 🔐 Part 4 — Access Control

### 🧩 Analogy First

Imagine your bank app allowed anyone to:

- Reset your balance.
- Transfer your money.

That’s what happens without access control.

### ❌ Vulnerable Example

```solidity
contract Bank {
    uint public totalFunds;

    function setFunds(uint amount) public {
        totalFunds = amount;
    }
}
```

Anyone can change `totalFunds`.

### ✅ Fixed Version

```solidity
contract Bank {
    address public owner;
    uint public totalFunds;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function setFunds(uint amount) public onlyOwner {
        totalFunds = amount;
    }
}
```

### 🔎 Explanation

- `msg.sender` = caller.
- Constructor runs once.
- Modifier restricts function access.

### 💡 Beginner Mistakes

- Forgetting access control on critical functions.
- Assuming frontend prevents misuse.
- Relying on UI restrictions.

**On Ethereum:**
- Backend logic **IS** the contract.

---

## 🧱 Part 5 — Why Immutability Is Dangerous

### 🧩 Analogy First

Deploying a smart contract is like launching a satellite.

- Once it’s in orbit, you cannot climb up and fix the wiring.

### 🧠 What This Means

- Bugs remain forever.
- Funds can be locked permanently.
- You must test before deploying.

### 🛠 Beginner Security Checklist

Before deployment:

✔ Have I restricted admin functions?
✔ Do I update state before external calls?
✔ Do I validate all inputs?
✔ Have I tested edge cases?
✔ Have I considered gas limits?

---

## 🧪 Guided Security Exercise

### Exercise 1 — Identify the Vulnerability

```solidity
function donate(address recipient) public payable {
    recipient.call{value: msg.value}("");
}
```

**Questions:**

- What is missing?
- What risks exist?
- Should this check return values?

### Exercise 2 — Secure This Function

```solidity
function changeOwner(address newOwner) public {
    owner = newOwner;
}
```

Add correct access control.

---

## 🧠 Recap Section

You now understand:

✔ Why smart contract security is critical.
✔ How reentrancy works.
✔ The Checks-Effects-Interactions pattern.
✔ Why access control is essential.
✔ Overflow behavior in Solidity 0.8+.
✔ Why immutability increases risk.

---

## 🧪 Mini Security Project (Beginner Safe Vault)

### Requirements

Build a vault that:

- Accepts deposits.
- Allows withdrawals.
- Prevents reentrancy.
- Restricts emergency pause to owner.

### Starter Code

```solidity
contract SafeVault {
    mapping(address => uint) public balances;
    address public owner;
    bool public paused;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier notPaused() {
        require(!paused, "Paused");
        _;
    }

    function deposit() public payable notPaused {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint amount) public notPaused {
        require(balances[msg.sender] >= amount, "Insufficient");

        balances[msg.sender] -= amount;

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed");
    }

    function togglePause() public onlyOwner {
        paused = !paused;
    }
}
```

### Extension Challenge

- Add event logs.
- Add withdraw limit.
- Add time delay mechanism.

---

## 📚 Suggested Homework

- Explain reentrancy in your own words.
- Write a vulnerable contract and fix it.
- Add access control to one of your previous projects.
- Deploy to Remix and test edge cases manually.

---

## 📊 Suggested Assessment Strategy

### Practical Test

Students must:

- Identify vulnerabilities in 3 small contracts.
- Fix them correctly.
- Explain why the fix works.

### Concept Test

- Explain Checks-Effects-Interactions without notes.
- Describe what happens during a reentrant attack step-by-step.

---

## 🎓 Final Instructor Note

Emphasize repeatedly:

- “Ethereum does exactly what you tell it to do — not what you meant.”

**Security is not an advanced topic.**
It is the foundation of everything that follows.
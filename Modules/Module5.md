# Module 5 — Testing Smart Contracts with Foundry

## 🎯 Module Objective

By the end of this module, students will:

- Understand why testing is critical in smart contract development
- Install and initialize a Foundry project
- Write unit tests in Solidity
- Use assertions correctly
- Test failure cases
- Test access control
- Use cheatcodes (intro level)
- Understand fuzz testing (intro)
- Structure tests professionally

---

## 🧠 Part 1 — Why Testing Is Different in Smart Contracts

### 🧩 Analogy First

- **In Web2:**
  - You deploy → fix bugs → redeploy.
- **In Ethereum:**
  - You deploy → bug exists → funds may be lost forever.

**Testing is not optional.**
It is protection against permanent damage.

### 🧠 What Is Foundry?

Foundry is a smart contract development framework written in Rust that allows you to:

- Compile contracts
- Run tests
- Deploy contracts
- Perform fuzz testing
- Simulate transactions

It uses a CLI tool called:

- `forge` → compile & test
- `cast` → interact with contracts
- `anvil` → local Ethereum node

---

## 🛠 Part 2 — Setting Up Foundry

### 🧱 Install
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 🧱 Initialize Project
```bash
forge init my-project
cd my-project
```

### Project Structure
```
src/     → Smart contracts
test/    → Tests (written in Solidity)
script/  → Deployment scripts
foundry.toml
```

---

## 🧪 Part 3 — Writing Your First Test

### Example Contract

**src/Counter.sol**
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Counter {
    uint256 public count;

    function increment() public {
        count += 1;
    }

    function decrement() public {
        require(count > 0, "Underflow");
        count -= 1;
    }
}
```

### Writing a Test

**test/Counter.t.sol**
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Counter.sol";

contract CounterTest is Test {

    Counter counter;

    function setUp() public {
        counter = new Counter();
    }

    function testInitialValueIsZero() public {
        assertEq(counter.count(), 0);
    }

    function testIncrement() public {
        counter.increment();
        assertEq(counter.count(), 1);
    }
}
```

### 🔍 Line-by-Line Explanation

- `import "forge-std/Test.sol";`
  - Imports testing utilities.
- `contract CounterTest is Test`
  - Inherits from `Test` to access:
    - `assertEq`
    - `vm` cheatcodes
    - Testing helpers
- `setUp()`
  - Runs before each test.
  - Deploys a fresh contract instance.

### 🧪 Running Tests
```bash
forge test
```

You’ll see:
```
[PASS] testInitialValueIsZero()
[PASS] testIncrement()
```

### ⚠️ Common Beginner Mistakes

- Forgetting `setUp()`
- Not deploying a fresh instance
- Testing state from a previous test
- Not testing failure cases

---

## 🧪 Part 4 — Testing Reverts (Failure Cases)

Testing success is not enough. We must test failure.

### Add Failure Test
```solidity
function testDecrementRevertsIfZero() public {
    vm.expectRevert("Underflow");
    counter.decrement();
}
```

### 🧠 What Is `vm.expectRevert()`?

Foundry provides cheatcodes via `vm`.

Here we tell the test:

- “The next call should revert with this message.”
- If it doesn’t → test fails.

### 🧠 Concept Diagram
```
Test
  ↓
Expect Revert
  ↓
Call Function
  ↓
Revert?
  ↓
PASS
```

---

## 🧪 Part 5 — Testing Access Control

### Consider This Contract

```solidity
contract Owned {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function restricted() public view {
        require(msg.sender == owner, "Not owner");
    }
}
```

### Testing Non-Owner Access
```solidity
function testNonOwnerCannotCallRestricted() public {
    Owned owned = new Owned();

    vm.prank(address(1)); // simulate different caller
    vm.expectRevert("Not owner");

    owned.restricted();
}
```

### 🧠 What Is `vm.prank()`?

It simulates a different `msg.sender`.

Very powerful for testing multi-user logic.

---

## 🧪 Part 6 — Testing ERC-20 Logic

### Test Transfer
```solidity
function testTransfer() public {
    BeginnerERC20 token = new BeginnerERC20(1000);

    token.transfer(address(1), 100);

    assertEq(token.balanceOf(address(1)), 100);
}
```

### Test Allowance
```solidity
function testApproveAndTransferFrom() public {
    BeginnerERC20 token = new BeginnerERC20(1000);

    token.approve(address(this), 200);
    token.transferFrom(address(this), address(2), 100);

    assertEq(token.balanceOf(address(2)), 100);
}
```

---

## 🧪 Part 7 — Introduction to Fuzz Testing

### 🧩 Analogy

Instead of manually trying inputs, let the computer try thousands automatically.

### Example
```solidity
function testFuzzIncrement(uint256 x) public {
    counter.increment();

    assertEq(counter.count(), 1);
}
```

### Better Example
```solidity
function testFuzzTransfer(uint256 amount) public {
    vm.assume(amount <= 1000);

    BeginnerERC20 token = new BeginnerERC20(1000);
    token.transfer(address(1), amount);

    assertEq(token.balanceOf(address(1)), amount);
}
```

Foundry will test with many random values.

### 🧠 Why Fuzzing Matters

It helps find:

- Overflow edge cases
- Boundary errors
- Unexpected reverts
- Broken logic

Automatically.

---

## 🧪 Part 8 — Testing Reentrancy Protection

Students should test:

- Withdraw once
- Attempt malicious call
- Confirm balance decreases correctly

Even if we don’t build an attacker contract yet, students should test state consistency.

---

## 🛠 Guided Exercise

Write tests for:

- Voting contract double vote prevention
- Token burn function
- Pausable transfer logic

---

## 🧠 Recap

Students now understand:

✔ Unit tests
✔ Testing reverts
✔ Testing access control
✔ Simulating different users
✔ Basic fuzz testing
✔ Professional test structure

---

## 📚 Homework

- Write 5 test cases for your Voting contract.
- Write a fuzz test for ERC-20 transfer.
- Write a test that ensures the owner cannot be a zero address.
- Break your contract intentionally and confirm tests fail.

---

## 📊 Assessment Strategy

Students must submit:

- A fully tested ERC-20 contract
- At least 10 test cases
- At least 1 fuzz test
- At least 1 failure test
- Explanation of what each test protects against

---

## 🎓 Instructor Emphasis

Reinforce:

- “If it’s not tested, it’s broken.”

Professional smart contract developers:

- Write tests before deployment
- Test edge cases
- Test attack scenarios
- Never trust happy-path logic
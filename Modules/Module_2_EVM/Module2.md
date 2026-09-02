# Module 2 — Understanding the Ethereum Virtual Machine (EVM)

## Goal
Build a deep mental model of how Ethereum actually executes smart contracts.

By the end of this module, you will understand:
- What the EVM really is
- How smart contracts are executed
- What deterministic computation means
- How gas works at the execution level
- Storage vs memory vs calldata
- How state changes occur
- What happens step-by-step when a transaction runs

---

## Topics

### 1. What Is the EVM?

Imagine Ethereum as a global computer. Then the EVM is:
- The CPU that runs every smart contract instruction.

But here’s the twist:
- There isn’t one CPU.
- There are thousands of identical virtual CPUs running across the world.

Each one:
- Executes the same instructions
- On the same input
- Produces the same result

#### 🔬 Technical Definition
The Ethereum Virtual Machine (EVM) is:
- A sandboxed runtime environment that executes smart contract bytecode and computes state transitions on Ethereum.

Ethereum is fundamentally a state transition system:
```
New State = State Transition Function(Current State, Transaction)
```
That state transition function is executed inside the EVM.

#### 📊 Conceptual Diagram
```
Current Global State
        +
    Transaction
        ↓
   EVM Execution
        ↓
    New Global State
```
Every node runs this exact computation. That is why Ethereum remains consistent.

---

### 2. Deterministic Computation

#### 🧠 Analogy
Imagine 10,000 calculators. You press:
```
2 + 2
```
Every calculator must return:
```
4
```
If even one returns 5 — it is broken. Ethereum works the same way.

Deterministic means:
- Same input
- Same code
- Same output

Across all nodes.

The EVM cannot:
- Access random internet APIs
- Use system time unpredictably
- Fetch external data without being provided

Why?
- Because that would break determinism.

Smart contracts CANNOT:
- Call Google APIs
- Fetch live prices
- Access system clock freely

Everything must be provided inside the transaction or via oracles.

---

### 3. EVM Architecture Overview

The EVM has several key components:
- **Stack**
- **Memory**
- **Storage**
- **Program Counter**
- **Gas Counter**

Let’s break these down.

#### 3.1 Stack

Think of a stack of plates. You can:
- Put a plate on top
- Take the top plate off

But you cannot access the one in the middle directly.

The EVM is a stack-based virtual machine:
- 256-bit word size
- Max depth: 1024 items
- Most operations pop values off the stack and push results back

Example:
```
PUSH 2
PUSH 3
ADD
```
Result on stack:
```
5
```

#### 3.2 Memory

Memory is like a whiteboard. You can write on it during execution. When the function ends:
- It is erased.

Memory is:
- Temporary
- Reset after execution
- Cheaper than storage

Used for:
- Function arguments
- Intermediate calculations
- Return values

#### 3.3 Storage

Storage is a permanent filing cabinet. Anything written here:
- Persists forever
- Is expensive to modify

Storage:
- Lives on-chain
- Is part of global state
- Costs significant gas to write
- Is mapped to 32-byte slots

When you write:
```
uint256 public number;
```
You are writing to storage. Storage writes are one of the most expensive operations in Ethereum.

Most gas optimization revolves around minimizing storage writes.

#### 3.4 Calldata

Calldata is:
- Read-only input data
- Passed into a function
- Cheaper than memory
- Cannot be modified

Used heavily in external functions.

---

### 4. Gas at the Execution Level

You learned in Module 1 that gas is fuel. Now we go deeper.

Every single EVM instruction (opcode) costs gas.

Examples:
- **ADD** → cheap
- **SSTORE** (write to storage) → expensive
- **CALL** → expensive

When a transaction begins:
- It includes a gas limit
- The EVM deducts gas per instruction

If gas reaches zero → execution stops and reverts

Gas prevents:
- Infinite loops
- Denial-of-service attacks
- Excessive computation

The current block gas limit is 60 million gas.
A typical transaction has a gas limit of 21,000 units

---

### 5. Step-By-Step: How a Transaction Modifies State

Let’s walk through a real example. We use this contract:
```solidity
contract Counter {
    uint256 public count;

    function increment() public {
        count += 1;
    }
}
```

#### Step 1: User Calls `increment()`
User sends transaction to contract. Transaction includes:
- To address
- Data (function selector)
- Gas limit
- Signature

#### Step 2: Node Validates Transaction
- Signature verified
- Sender has enough ETH
- Nonce correct

#### Step 3: EVM Execution Begins
EVM loads:
- Current contract storage
- Calldata
- Initializes memory
- Sets gas counter

#### Step 4: Opcode Execution
The `increment` function compiles roughly to:
- Load `count` from storage (**SLOAD**)
- Add 1 (**ADD**)
- Store new value (**SSTORE**)

Gas consumed at each step.

#### Step 5: State Update
If execution succeeds:
- New storage value committed
- Gas deducted
- Block updated

If execution fails:
- State reverts
- Gas spent is NOT refunded

#### 📊 Execution Flow Diagram
```
User Transaction
       ↓
Validation
       ↓
EVM Loads State
       ↓
Opcode Execution
       ↓
Gas Deduction
       ↓
State Commit OR Revert
```

---

### 6. The EVM Lifecycle Model

Every transaction follows:
1. Validate
2. Execute
3. Deduct Gas
4. Commit State

Ethereum nodes repeat this process independently. Consensus ensures everyone agrees on the final state.

---

### 7. Module 2 Recap

You now understand:
- The EVM is a deterministic virtual machine
- It is stack-based
- Memory is temporary
- Storage is permanent
- Gas is charged per opcode
- Transactions are state transition triggers
- State changes are atomic (all or nothing)

#### 🧠 Reflection Questions
- Why must Ethereum execution be deterministic?
- Why is storage expensive?
- What happens if gas runs out mid-execution?
- Why are infinite loops dangerous on-chain?
- Why can't smart contracts fetch data from the internet?

#### 🧪 Mini Exercises

**Exercise 1**
Explain the difference between:
- Memory
- Storage
- Calldata

In your own words.

**Exercise 2**
Why does this cost more gas?
```solidity
count = count + 1;
```
Compared to:
```solidity
uint256 temp = 5;
```

**Exercise 3 (Advanced Beginner)**
Predict what happens:
```solidity
function infinite() public {
    while(true) {}
}
```
What happens to:
- State?
- Gas?
- Transaction outcome?

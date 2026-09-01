# Module 1 — Foundations: What Is Ethereum?

## Goal
Build a rock-solid mental model of Ethereum from first principles.

By the end of this module, you should understand:
- What a blockchain is
- What decentralization means
- What problem Ethereum solves
- How Ethereum differs from Bitcoin ans Stellar
- What accounts and transactions are
- What gas is
- How Ethereum runs on the EVM

---

## Topics

### 1. What Is a Blockchain?

Imagine a shared Google Sheet. But instead of:
- Being controlled by Google
- Stored on one company’s servers

It is:
- Stored on thousands of computers
- Anyone can verify the history
- No single person controls it

That shared spreadsheet is a blockchain.

Every time someone edits it:
- The change is recorded
- Everyone agrees on the new version
- The old version cannot be secretly modified

#### 🔬 Technical Definition
A blockchain is:
- A distributed ledger that records transactions in blocks, where each block is cryptographically linked to the previous one.
- Ethereum is a blockchain that maintains a shared “state” across nodes.

In simpler words:
- **Ledger** = record of balances and data
- **Distributed** = copied across many machines
- **Linked blocks** = prevents tampering

Each block:
- Contains transactions
- References the previous block
- Extends the chain

#### ✅ Checkpoint
- Why is it called a “chain”?
- What makes it difficult to change old data?

---

### 2. What Is Decentralization?

#### 🧠 Analogy
Traditional systems:
```
User → Server → Database
```
- One central authority.

If that server:
- Goes down → system stops
- Is hacked → data compromised
- Lies → users must trust them

Ethereum removes the central server.

#### 🔬 Technical Explanation
Ethereum runs on many independent nodes that:
- Store the blockchain
- Validate transactions
- Execute smart contracts

All nodes must agree on the same state transition. This is known as a **replicated state machine**.

That means:
- Every node runs the same computation
- Given the same input
- They all produce the same output

#### 📊 Diagram
```
User submits transaction
          ↓
 Node A executes
 Node B executes
 Node C executes
          ↓
All produce identical result
```
If a node disagrees, it is rejected.

#### ✅ Reflection
- Why is it powerful that no single company controls Ethereum?
- What trade-offs might decentralization introduce?

---

### 3. What Problem Does Ethereum Solve?

#### 🧠 Analogy
Before Ethereum:
If you wanted:
- Online payments → PayPal
- Lending → Bank
- Marketplace → Amazon

You needed a trusted middleman.

Ethereum allows:
- Code to run exactly as written without trusting a company.

#### 🔬 Technical Explanation
Ethereum enables:
- Programmable transactions
- Smart contracts
- Trustless execution

Transactions are cryptographically signed instructions from accounts. This means:
- No one can fake your transaction
- No one can modify it after signing

#### 🎯 Key Idea
Ethereum is not just money. It is a **global execution engine**.

---

### 4. Ethereum vs Bitcoin and Stellar

#### 🧠 High-Level Comparison
All three:
- Maintain distributed ledgers
- Use cryptography
- Do not rely on a central authority

But their design goals and consensus mechanisms differ significantly.

#### 🔶 Bitcoin — Digital Gold
- **Primary Purpose**: Secure, censorship-resistant digital money.
- **Consensus**: Proof of Work (PoW)
  - Thousands of computers compete to solve a difficult puzzle.
  - Security comes from real-world energy expenditure.
- **Characteristics**:
  - ✅ Extremely secure
  - ❌ Energy intensive
  - ❌ ~10 minute block time
  - ❌ Limited programmability

#### 🔷 Ethereum — Programmable Blockchain
- **Primary Purpose**: Smart contracts, tokens, dApps.
- **Consensus**: Proof of Stake (PoS)
  - Validators lock up ETH as collateral.
  - Security comes from economic incentives.
- **Characteristics**:
  - ✅ Energy efficient
  - ✅ ~12 second block time
  - ✅ Full smart contract support (EVM)
  - ⚠️ Requires stake-based economic assumptions

#### 🔵 Stellar — Fast Payment Network
- **Primary Purpose**: Fast, low-cost global payments and asset issuance.
- **Consensus**: Stellar Consensus Protocol (SCP)
  - Nodes choose trusted validators.
  - Consensus emerges from trust configuration.
- **Characteristics**:
  - ✅ Very fast finality (~3–5 seconds)
  - ✅ Very low transaction fees
  - ✅ Energy efficient
  - ⚠️ Limited programmability compared to Ethereum

#### 📊 Comparison Table
| Feature          | Bitcoin         | Ethereum        | Stellar         |
|------------------|-----------------|-----------------|-----------------|
| Primary Goal     | Digital money   | Programmable blockchain | Fast global payments |
| Consensus        | Proof of Work   | Proof of Stake  | SCP (Federated Agreement) |
| Energy Use       | High            | Low             | Low             |
| Block Time       | ~10 minutes     | ~12 seconds     | ~3–5 seconds    |
| Smart Contracts  | Very limited    | Full EVM support| Limited         |

#### 🧩 Reflection Questions
- Why does Bitcoin consume so much electricity?
- Why does Ethereum require staking?
- Why does Stellar rely on trust relationships?
- Which design seems best for global payments?
- Which design seems best for complex smart contracts?

---

### 5. Accounts on Ethereum

Ethereum has two types of accounts:
1. **Externally Owned Accounts (EOAs)**
   - Controlled by a private key
   - Can initiate transactions
   - Owned by users
2. **Contract Accounts**
   - Contain smart contract code
   - Cannot initiate transactions
   - Execute code when called

#### 📊 Diagram
```
EOA (User Wallet)
   ↓ sends tx
Smart Contract
   ↓ modifies
Ethereum State
```

#### 🔑 Critical Insight
- Contracts cannot wake themselves up.
- They only run:
  - When a user calls them
  - Or another contract calls them

#### ✅ Checkpoint
- Why can only EOAs initiate transactions?
- What would happen if contracts could self-trigger?

---

### 6. What Is a Transaction?

#### 🧠 Intuition
A transaction is a signed instruction. Like saying:
- “Transfer 1 ETH”
- “Call this function”
- “Deploy this contract”

#### 🔬 Technical Definition
A transaction:
- Is signed with a private key
- Is broadcast to the network
- Modifies Ethereum state
- Consumes gas

#### 🔄 Transaction Lifecycle
1. User signs transaction
2. Broadcast to network
3. Validator includes in block
4. EVM executes it
5. State updated

#### 📊 Diagram
```
User
 ↓
Signed Transaction
 ↓
Network
 ↓
Block Inclusion
 ↓
EVM Execution
 ↓
New State
```

---

### 7. What Is Gas?

#### 🧠 Analogy
Gas is like fuel for your car. If you want to drive:
- You must pay for fuel
- The more you drive, the more fuel you burn

In Ethereum:
- Computation costs gas
- Storage costs gas
- Complex logic costs more gas

#### 🔬 Technical Explanation
Gas measures computational effort required to execute operations in the EVM.

Why gas exists:
- Prevents infinite loops
- Prevents network spam
- Compensates validators

#### ⛽ Gas vs ETH
- **Gas** = unit of work
- **ETH** = currency used to pay for gas

#### ❓ What If Gas Runs Out?
- Execution stops
- State reverts
- Gas spent is not refunded
---

### 8. How Ethereum Runs on the EVM

#### 🧠 Big Picture Analogy
- Ethereum = World Computer
- EVM = CPU of that computer

Every node:
- Runs the EVM
- Executes the same bytecode
- Produces the same result

#### 🔬 Technical Explanation
The Ethereum Virtual Machine (EVM):
- Executes smart contract bytecode
- Computes deterministic state transitions

Deterministic means:
- Same input
- Same computation
- Same result

Across all nodes.

#### 🧠 Conceptual Model
```
Current State
     +
Transaction
     ↓
EVM Execution
     ↓
New State
```

Ethereum is fundamentally:
- A state transition machine.

---

### 🧩 Module 1 Recap

You now understand:
- A blockchain is a distributed ledger
- Ethereum is programmable blockchain infrastructure
- Transactions change state
- Gas pays for computation
- The EVM executes smart contracts deterministically
- Accounts initiate state transitions

#### 📝 Reflective Questions
- Why must Ethereum execution be deterministic?
- Why does gas protect the network?
- Why can’t smart contracts initiate transactions?
- What is the “state” of Ethereum?

#### 💻 Mini Exercise
Write a 5-sentence explanation answering:
“How does Ethereum process a transaction from start to finish?”

If you can answer that clearly, you understand Module 1.

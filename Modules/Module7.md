# Module 7 — Ethereum Request for Comments (ERC Standards)

## 🎯 Module Objective

By the end of this module, students will:

- Understand what an ERC is
- Understand why standards matter in decentralized systems
- Implement a compliant ERC-20 token
- Understand how ERC-721 NFTs differ from ERC-20 tokens
- Recognize how standards enable interoperability
- Use interfaces properly in Solidity

---

## 🧠 Part 1 — What Is an ERC?

### 🧩 Analogy First

Imagine USB ports:

- If every manufacturer created a different charger:
  - Nothing would connect.
  - No interoperability.
  - No ecosystem.

**USB is a standard.**

ERCs are the USB standards of Ethereum.

### 🧠 Technical Definition

An ERC (Ethereum Request for Comments) is a proposal that defines a standard interface and behavior for smart contracts on Ethereum.

If a contract follows the standard:

- Wallets can recognize it.
- Exchanges can integrate it.
- Other contracts can interact with it.

Standards are discussed and documented through Ethereum’s improvement process.

### 🧠 Why Standards Matter

Without ERC-20:

- Every token would have different function names.
- Wallets couldn’t display balances.
- Exchanges couldn’t support tokens generically.

With ERC-20:

- Every compliant token exposes the same core functions.

---

## 🪙 Part 2 — Deep Dive: ERC-20

### 🧩 Analogy First

ERC-20 defines the rulebook for fungible tokens.

**Fungible means:**

- One token is identical to another.
- Like dollars.
- Like reward points.
- Like game credits.

### 📋 Core ERC-20 Interface

An ERC-20 token must implement:

```solidity
function totalSupply() external view returns (uint256);
function balanceOf(address account) external view returns (uint256);
function transfer(address to, uint256 amount) external returns (bool);
function allowance(address owner, address spender) external view returns (uint256);
function approve(address spender, uint256 amount) external returns (bool);
function transferFrom(address from, address to, uint256 amount) external returns (bool);
```

**Events:**

```solidity
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
```

### 🧠 New Concept: Allowances

**Analogy:**

Imagine giving someone permission to spend $50 from your bank account.

- That’s `approve()`.
- Then they spend it using `transferFrom()`.

### 🧪 Minimal ERC-20 Implementation (Educational)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BeginnerERC20 {

    string public name = "Beginner Token";
    string public symbol = "BTK";
    uint8 public decimals = 18;

    uint256 private _totalSupply;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(uint256 initialSupply) {
        _mint(msg.sender, initialSupply);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return allowances[owner][spender];
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(allowances[from][msg.sender] >= amount, "Allowance exceeded");

        allowances[from][msg.sender] -= amount;
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(to != address(0), "Zero address");
        require(balances[from] >= amount, "Insufficient balance");

        balances[from] -= amount;
        balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _mint(address to, uint256 amount) internal {
        _totalSupply += amount;
        balances[to] += amount;

        emit Transfer(address(0), to, amount);
    }
}
```

### 🔍 Walkthrough Highlights

- **`_mint`**
  - Emits `Transfer` from zero address — required behavior.
- **`approve`**
  - Sets allowance mapping.
- **`transferFrom`**
  - Decreases allowance before transferring.

### ⚠️ Common ERC-20 Mistakes

- Not emitting `Transfer` event on mint.
- Not checking zero address.
- Incorrect allowance subtraction.
- Forgetting to decrease allowance.
- Reentrancy risks when combining token + ETH logic.

### 🧠 Security Discussion

**Allowance race condition:**

- If user sets allowance from 100 → 200, attacker can spend 100 before change finalizes.

**Mitigation strategy:**

- Set allowance to 0 before updating.
- Modern implementations use safer patterns.

---

## 🖼 Part 3 — ERC-721 (NFT Standard)

### 🧩 Analogy First

- ERC-20 tokens are dollars.
- ERC-721 tokens are house deeds.

Each one is unique.

### 🧠 Key Differences

| ERC-20          | ERC-721          |
|-----------------|-----------------|
| Fungible        | Non-fungible    |
| `balanceOf` returns amount | `balanceOf` returns count |
| `mapping(address => uint)` | `mapping(tokenId => owner)` |

### 🧠 Core ERC-721 Concepts

- `ownerOf(tokenId)`
- `safeTransferFrom`
- `approve`
- `tokenURI` (metadata)

Each token has a unique ID.

### 🧪 Minimal Educational NFT

```solidity
contract SimpleNFT {

    mapping(uint256 => address) public ownerOf;
    uint256 public nextTokenId;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    function mint() public {
        uint256 tokenId = nextTokenId;
        ownerOf[tokenId] = msg.sender;
        nextTokenId++;

        emit Transfer(address(0), msg.sender, tokenId);
    }

    function transfer(address to, uint256 tokenId) public {
        require(ownerOf[tokenId] == msg.sender, "Not owner");

        ownerOf[tokenId] = to;

        emit Transfer(msg.sender, to, tokenId);
    }
}
```

### ⚠️ Beginner NFT Mistakes

- Forgetting ownership checks.
- Not handling safe transfers.
- Missing approval logic.
- Not understanding metadata separation.

---

## 📦 Part 4 — ERC-1155 (Conceptual Overview)

### 🧩 Analogy

ERC-1155 is like a warehouse inventory system:

- Some items are fungible.
- Some items are unique.
- All managed in one contract.

**Used for:**

- Gaming.
- Multi-token systems.

We do **NOT** implement it yet — just conceptual awareness.

---

## 🧠 Part 5 — Interfaces & Why They Matter

### 🧩 Analogy

An interface is like a contract between two developers.

It says:

- “If you implement these functions, others can rely on them.”

### 🧪 Example Interface

```solidity
interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
}
```

You can interact with **ANY** ERC-20 using this interface.

That’s interoperability.

### 🧠 Concept Diagram (Textual)
```
Wallet
   ↓
ERC-20 Interface
   ↓
Any compliant token
```

Standards enable composability.

---

## 🧪 Mini Project — Build a Fully Compliant ERC-20

### Requirements

- Implement full interface.
- Add mint (owner only).
- Add burn.
- Prevent zero address.
- Follow Checks-Effects-Interactions.
- Emit required events.

### 🛠 Exercises

- Add pausable transfers.
- Add capped supply.
- Add ownership transfer.
- Write plain English test cases for allowance logic.

---

## 📚 Homework

- Explain why ERC standards are critical for DeFi.
- Compare ERC-20 and ERC-721.
- Explain allowance in your own words.
- Modify your Voting contract to use ERC-20 balances for voting power.

---

## 📊 Assessment Strategy

### Students must:

- Implement a compliant ERC-20.
- Demonstrate `approve` + `transferFrom`.
- Explain why zero address checks exist.
- Identify at least 3 ERC-20 security risks.

---

## 🎓 Instructor Emphasis

At this stage reinforce:

- “Standards are what transform isolated contracts into an ecosystem.”

Without ERC-20:
- No DeFi.

Without ERC-721:
- No NFTs.

Without standards:
- No composability.
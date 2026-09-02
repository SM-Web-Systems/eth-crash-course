# Module 4 — Smart Contract Lifecycle (Foundry Edition)

## Overview
This module focuses on the lifecycle of a smart contract using Foundry tools. We will cover:
- Writing contracts
- Compiling
- Testing
- Deploying
- Interacting
- Verifying

### Tools Used
- **Forge**: Compile, test, build
- **Cast**: Interact with contracts
- **Anvil**: Local Ethereum node

## Goal
By the end of this module, you will be able to:
- Compile a smart contract
- Write a basic unit test
- Deploy a smart contract
- Interact with a deployed contract on local network
- Understand what verification is and why it matters

---

## 4.1 Writing (Foundry Project Structure)

Installation
Foundry is installed using foundryup, the official installer and version manager.

Install foundryup
```
curl -L https://foundry.paradigm.xyz | bash
```

Restart your terminal
Or run 
```
source ~/.bashrc / source ~/.zshrc.
```

This installs the latest stable versions of Forge, Cast, Anvil, and Chisel.

When you run:
```bash
forge init simple-vault
```
You get the following structure:
```
simple-vault/
├── src/
│   └── Counter.sol
├── test/
│   └── Counter.t.sol
├── script/
│   └── Counter.s.sol
├── foundry.toml
```

Place your contract in:
```
src/SimpleVault.sol
```

### Example Contract (Production-Ready Structure)
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleVault {
    mapping(address => uint256) public balances;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient");

        balances[msg.sender] -= amount;

        (bool success, ) = payable(msg.sender).call{value: msg.value}("");
        require(success, "Transfer Failed");

        emit Withdraw(msg.sender, amount);
    }
}
```

---

## 4.2 Compiling (Forge)

Compilation is handled by:
```bash
forge build
```
This:
- Compiles Solidity
- Outputs artifacts to `/out`
- Uses the compiler version defined in `foundry.toml`

### Example Config
```toml
[profile.default]
solc = "0.8.20"
optimizer = true
optimizer_runs = 200
```

#### Why Optimizer Matters
- Reduces bytecode size
- Lowers gas usage
- Changes bytecode hash (important for verification)

---

## 4.3 Testing (Critical Step in Lifecycle)

In Foundry, testing is first-class.

### Create Test File
Place the following in `test/SimpleVault.t.sol`:
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/SimpleVault.sol";

contract SimpleVaultTest is Test {
    SimpleVault vault;

    function setUp() public {
        vault = new SimpleVault();
    }

    function testDeposit() public {
        vault.deposit{value: 1 ether}();
        assertEq(vault.balances(address(this)), 1 ether);
    }
}
```

### Run Tests
```bash
forge test
```
This:
- Spins up a local EVM
- Executes tests
- Reports gas usage

---

## 4.4 Deploying (Script-Based with Forge)

### Create Deployment Script
Place the following in `script/DeployVault.s.sol`:
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/SimpleVault.sol";

contract DeployVault is Script {
    function run() external {
        vm.startBroadcast();
        new SimpleVault();
        vm.stopBroadcast();
    }
}
```

### Deploy to Local Anvil
Start Anvil:
```bash
anvil
```
Then deploy:
```bash
forge script script/DeployVault.s.sol \
--rpc-url http://localhost:8545 \
--private-key YOUR_PRIVATE_KEY \
--broadcast
```

### Deploy to Sepolia
```bash
forge script script/DeployVault.s.sol \
--rpc-url $SEPOLIA_RPC_URL \
--private-key $PRIVATE_KEY \
--broadcast
```

---

## 4.5 Interacting (Cast)

### Read Call
```bash
cast call CONTRACT_ADDRESS \
"balances(address)" YOUR_ADDRESS \
--rpc-url $RPC_URL
```

### Write Call
```bash
cast send CONTRACT_ADDRESS \
"deposit()" \
--value 1ether \
--private-key $PRIVATE_KEY \
--rpc-url $RPC_URL
```

This is raw ABI interaction — no frontend required. Perfect for backend engineers.

---

## 4.6 Verifying (Forge)

Verification via:
```bash
forge verify-contract \
CONTRACT_ADDRESS \
src/SimpleVault.sol:SimpleVault \
--chain-id 11155111 \
--etherscan-api-key $ETHERSCAN_API_KEY
```

### What Happens
- Forge recompiles the contract
- Matches bytecode
- Submits source to Etherscan

---

## 🔬 Foundry-Based Lifecycle Summary

| Stage   | Foundry Tool          |
|---------|-----------------------|
| Write   | `src/`               |
| Compile | `forge build`        |
| Test    | `forge test`         |
| Deploy  | `forge script --broadcast` |
| Interact| `cast call/send`     |
| Verify  | `forge verify-contract` |

This is the professional Ethereum-native workflow.

### Why Foundry?
- Faster
- More gas-aware
- More audit-aligned
- Written in Rust
- Closer to the EVM
- No context swtching

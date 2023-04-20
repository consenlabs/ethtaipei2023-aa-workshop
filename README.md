# ETH Taipei 2023 Account Abstraction Workshop

[ERC-4337](https://eips.ethereum.org/EIPS/eip-4337) account abstraction workshop for ETH Taipei 2023.

## Environment

-   Foundry ([installation](https://book.getfoundry.sh/getting-started/installation))
-   Node.js >= v12 ([installation](https://nodejs.org/en))

## Setup

```bash
$ forge install
$ npm install
```

Use `npm` to run `test:VoidAccount` script to confirm project is ready:

```bash
$ npm run test:VoidAccount

# ...
Running 1 test for test/VoidAccount.t.sol:VoidAccountTest
[PASS] testExecuteUserOp() (gas: 113868)
```

## Folder Layout

-   `contracts`: It contains all the contracts you need to implement in this workshop.
-   `test`: It contains tests for each contract in the `contracts` folder. Tests will fail by default at the beginning, and you have to implement contracts in `contracts` folder to make all tests passed. **You should not modify files in this folder.**

## Tasks

### 1. DepositAccount

Account must have enough ETH balance on `EntryPoint` to pay the gas fee for executing a user operation. Please implement `contracts/DepositAccount.sol` to make `test/DepositAccount.t.sol` passed.

Run the following command to verify:

```bash
$ npm run test:DepositAccount

# Before
# ...
Encountered 1 failing test in test/DepositAccount.t.sol:DepositAccountTest
[FAIL. Reason: FailedOp(0, AA21 didn\'t pay prefund)] testExecuteUserOp() (gas: 32753)

# After
# ...
Running 1 test for test/DepositAccount.t.sol:DepositAccountTest
[PASS] testExecuteUserOp() (gas: 115405)
```

### 2. SignatureAccount

Account should verify signature on user operation is signed by owner. Please implement `contracts/SignatureAccount.sol` to make `test/SignatureAccount.t.sol` passed.

Run the following command to verify:

```bash
$ npm run test:SignatureAccount

# Before
# ...
Encountered 1 failing test in test/SignatureAccount.t.sol:SignatureAccountTest
[FAIL. Reason: Call did not revert as expected] testCannotExecuteUserOpSignedByOther() (gas: 88380)

# After
# ...
Running 2 tests for test/SignatureAccount.t.sol:SignatureAccountTest
[PASS] testCannotExecuteUserOpByOther() (gas: 44437)
[PASS] testExecuteUserOp() (gas: 98404)
```

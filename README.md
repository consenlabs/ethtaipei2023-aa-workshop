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
---
## Bundler Demo
### Deploy 4337 Account on Goerli
```bash
$ export PRIVATE_KEY=${PRIVATE_KEY_OF_DEPLOYER}
$ export ACCOUNT_OWNER_ADDR=${OWNER_ADDRESS_OF_ACCOUNT}
$ export RPC_URL=${GOERLI_RPC_ENDPOINT} 

# Run command at project root:
$ forge script ./script/bundler/DeployAccount.s.sol --rpc-url ${RPC_URL} --broadcast
```
Write down the deployed account address at this step, we will need it when generating userOp. 


### Generate UserOp payload for bundler
*(prerequisite: environment needs python3 installed to run below script)*
```bash
# The private key here corresponds to the account owner address
$ export PRIVATE_KEY=${PRIVATE_KEY_FOR_SIGNING_USER_OP}
$ export RPC_URL=${GOERLI_RPC_ENDPOINT} 
$ export ACCOUNT_ADDR=${4337_ACCOUNT_ADDRESS}

# Run command at project root:
$ ./bash/payload_builder.sh

# Expected output:
# 
# Generating userOperation...
# Building userOp http payload for bundler...

# ------------Result Payload--------------
#
# {"jsonrpc": "2.0", "id": 1, "method": "eth_sendUserOperation",
#  "params": [{"sender": "0xF19518B9424D8B0444b09E5B4631E728367caC20", "nonce": "2", "initCode": "0x", 
#  "callData": ...}
# ...
```

### Generate UserOp payload and send to bundler
*(prerequisite: environment needs python3 installed to run below script)*
```bash
# The private key here corresponds to the account owner address
$ export PRIVATE_KEY=${PRIVATE_KEY_FOR_SIGNING_USER_OP}
$ export RPC_URL=${GOERLI_RPC_ENDPOINT} 
$ export ACCOUNT_ADDR=${4337_ACCOUNT_ADDRESS}
$ export BUNDLER_URL=${BUNDLER_ENDPOINT} # may use stackup free endpoint here

# Run command at project root:
$ ./bash/payload_builder.sh -a

# Expected output:
# 
# Generating userOperation...
# Building userOp http payload for bundler...

# ------------Result Payload--------------
# 
# {"jsonrpc": "2.0", "id": 1, "method":eth_sendUserOperation
# ...}
# 
# ------------Sending payload to bundler--------------
#
# {"id":1,"jsonrpc":"2.0","result":"0xd9fb9b74014af5...."}
```
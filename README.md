\# ETH Taipei 2023 Account Abstraction Workshop

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

### 3. InitCode

With account factory, we can deploy account along with the first user operation by setting `initCode` field. Please implement `contracts/InitCode.sol` to make `test/InitCode.t.sol` passed.

```bash
$ npm run test:InitCode

# Before
# ...
Encountered 1 failing test in test/InitCode.t.sol:InitCodeTest
[FAIL. Reason: EvmError: Revert] testInitCode() (gas: 75414)

# After
# ...
Running 1 test for test/InitCode.t.sol:InitCodeTest
[PASS] testInitCode() (gas: 327206)
```

---

## Bundler Demo

For this demo, we will interact with two pre-deployed 4337 accounts on Sepolia testnet:

1. `0x6137A181E3657A5dfd4Ca97C5bB1d50B3AAdb127`
2. `0xa729a76caadb6fdcD9c198cEd19b5D4e54bA0485`


### Interacting with Account using BANNED OPCODE
The bundler should reject our request since we are calling a banned opcode in this account.
```bash
$ export PRIVATE_KEY=123456
$ export ACCOUNT_ADDR=0x6137A181E3657A5dfd4Ca97C5bB1d50B3AAdb127
$ export RPC_URL=${SEPOLIA_ENDPOINT}
$ export BUNDLER_URL=${BUNDLER_ENDPOINT} # may use stackup free endpoint here

# Run command at project root:
$ ./bash/payload_builder.sh -a

# Expected output:
#
# Generating userOperation...
# Building userOp http payload for bundler...
#
# ------------Result Payload--------------
#
# {
#   "jsonrpc": "2.0",
#   "id": 1,
#   "method": "eth_sendUserOperation",
#   "params": [
#    ...
#     },
#     "0x0576a174D229E3cFA37253523E645A78A0C91B57"
#   ]
# }
# 
# ------------Sending payload to bundler--------------
#
# {
#   "error": {
#     "code": -32502,
#     "data": "account uses banned opcode: SELFBALANCE",
#     "message": "account uses banned opcode: SELFBALANCE"
#   },
#   "id": 1,
#   "jsonrpc": "2.0"
# }
```

### Interacting with Account accessing invalid Storage Slot
The bundler should reject our request since we are not accessing the valid storage slot.
```bash
$ export PRIVATE_KEY=123456
$ export ACCOUNT_ADDR=0xa729a76caadb6fdcD9c198cEd19b5D4e54bA0485
$ export RPC_URL=${SEPOLIA_ENDPOINT}
$ export BUNDLER_URL=${BUNDLER_ENDPOINT} # may use stackup free endpoint here

# Run command at project root:
$ ./bash/payload_builder.sh -a

# Expected output:
#
# Generating userOperation...
# Building userOp http payload for bundler...
#
# ------------Result Payload--------------
#
# {
#   "jsonrpc": "2.0",
#   "id": 1,
#   "method": "eth_sendUserOperation",
#   "params": [
#    ...
#     },
#     "0x0576a174D229E3cFA37253523E645A78A0C91B57"
#   ]
# }
# 
# ------------Sending payload to bundler--------------
#
# {
#   "error": {
#     "code": -32502,
#     "data": "account has forbidden read to 0x87224F6D41DF6044ddd30a87bBdEeBc8c8CAc4f0 slot 4dbb180290de92ae0711e87110c97f6daba9f11cdfc121096b461bdc56cfe39f",
#     "message": "account has forbidden read to 0x87224F6D41DF6044ddd30a87bBdEeBc8c8CAc4f0 slot 4dbb180290de92ae0711e87110c97f6daba9f11cdfc121096b461bdc56cfe39f"
#   },
#   "id": 1,
#   "jsonrpc": "2.0"
# }
```

### Deploy a standard 4337 Account on Sepolia
Try modifying `contracts/bundler/NonStandardAccount.sol` then deploy the account and play with it. You may get some Sepolia eth on https://sepolia-faucet.pk910.de or https://sepoliafaucet.com/

Hint:

1. Comment out codes that will likely cause failure at Bundler's validation stage.  
2. (Optional) The `_validateSignature` function of `NonStandardAccount.sol` isn't properly implemented yet, it doesn't do any signature check. Add a verification logic in the function so only wallet owner can use the account. 

The following script will deploy 4337 account and automatically add deposit (0.01 ether) for it, make sure the deployer has enough funds.  
```bash
$ export PRIVATE_KEY=${PRIVATE_KEY_OF_DEPLOYER}
$ export ACCOUNT_OWNER_ADDR=${OWNER_ADDRESS_OF_ACCOUNT}
$ export RPC_URL=${SEPOLIA_ENDPOINT}

# Run command at project root:
$ forge script ./script/bundler/DeployAccount.s.sol --rpc-url ${RPC_URL} --broadcast
```
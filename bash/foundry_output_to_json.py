import json

lines = open("./results_forge").read().splitlines()

for i, e in enumerate(lines):
    _e = e.replace(' ', '')
    lines[i] = _e

userop_params = [
    {
        "sender": lines[0],
        "nonce": lines[1],
        "initCode": lines[2],
        "callData": lines[3],
        "callGasLimit": lines[4],
        "verificationGasLimit": lines[5],
        "preVerificationGas": lines[6],
        "maxFeePerGas": lines[7],
        "maxPriorityFeePerGas": lines[8],
        "paymasterAndData": lines[9],
        "signature": lines[10]
    },
    "0x0576a174D229E3cFA37253523E645A78A0C91B57"
]

userop = json.dumps({
    "jsonrpc": "2.0",
    "id": 1,
    "method": "eth_sendUserOperation",
    "params": userop_params
})

print(userop)

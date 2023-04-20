#!/bin/bash

if [[ $PRIVATE_KEY == "" ]]; then
    echo "env PRIVATE_KEY must be set!"
    exit 1
fi

if [[ $RPC_URL == "" ]]; then
    echo "env RPC_URL must be set!"
    exit 1
fi

if [[ $ACCOUNT_ADDR == "" ]]; then
    echo "env ACCOUNT_ADDR must be set!"
    exit 1
fi

Help()
{
   # Display Help
   echo "Script: payload_builder.sh [-h|a]"
   echo ""
   echo "Required envs:" 
   echo "  PRIVATE_KEY: The private key used to sign userOperation"
   echo "  RPC_URL: Chain's rpc url "
   echo ""
   echo "options:"
   echo "h   Print this Help."
   echo "a   (Optional)Send userOp payload to bundler automatically. (env BUNDLER_URL needs to be set)"
   echo
}

BuildPayload() 
{
    echo $'Generating userOperation...'
    blk=$(cast block latest --rpc-url $RPC_URL | grep "number" | awk -F 'number' '{print $2}' | xargs)
    PRIVATE_KEY=$PRIVATE_KEY forge test -vvv --fork-url=$RPC_URL --fork-block-number=$blk --force --mp ./test/bundler/BuildUserOp.t.sol | tail -n 13 | head -n 11 > results_forge

    echo $'Building userOp http payload for bundler...\n'
    bundler_payload=$(python3 ./bash/foundry_output_to_json.py)

    echo $'------------Result Payload--------------\n'
    echo $bundler_payload
    echo ""

    rm -rf results_forge
}

SendToBundler()
{   
    echo $'------------Sending payload to bundler--------------\n'
    curl -X POST --data "$bundler_payload" -H "Content-Type: application/json" $BUNDLER_URL
}


# Get the options
while getopts "ha" option; do
   case $option in
      h) # display Help
        Help
        exit;;

      a)    
        if [[ $BUNDLER_URL == "" ]]; then
            echo "env BUNDLER_URL must be set!"
            exit 1
        fi
        BuildPayload
        SendToBundler
        exit;;
   esac
done

# No options pass, just output the bundler payload
if [ $OPTIND -eq 1 ]; then BuildPayload; fi
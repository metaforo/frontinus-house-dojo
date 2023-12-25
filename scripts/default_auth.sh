#!/bin/bash
set -euo pipefail
pushd $(dirname "$0")/..

export RPC_URL="http://localhost:5050";

export WORLD_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.world.address')

export ACTIONS_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.contracts[] | select(.name == "dojo_gov::actions::proposal_actions::proposal_actions" ).address')
export ACTIONS_ADDRESS2=$(cat ./target/dev/manifest.json | jq -r '.contracts[] | select(.name == "dojo_gov::actions::vote_actions::vote_actions" ).address')

echo "---------------------------------------------------------------------------"
echo world : $WORLD_ADDRESS 
echo " "
echo actions : $ACTIONS_ADDRESS
echo actions : $ACTIONS_ADDRESS2
echo "---------------------------------------------------------------------------"

# enable system -> component authorizations
COMPONENTS=("GlobalConfig" "OptionSummary" "Proposal" "Vote" )

for component in ${COMPONENTS[@]}; do
    sozo auth writer $component $ACTIONS_ADDRESS --world $WORLD_ADDRESS --rpc-url $RPC_URL
    sozo auth writer $component $ACTIONS_ADDRESS2 --world $WORLD_ADDRESS --rpc-url $RPC_URL
done

echo "Default authorizations have been successfully set."
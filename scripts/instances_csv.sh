#!/bin/bash -e

command -v aws >/dev/null 2>&1 || { echo >&2 "I require aws cli but it's not installed.  Aborting."; exit 1; }
command -v jq >/dev/null 2>&1  || { echo >&2 "I require jq but it's not installed.  Aborting."; exit 1; }

INSTANCES=`aws ec2 describe-instances`

INSTANCE_IDS=(`echo $INSTANCES | jq -r '.Reservations[].Instances[].InstanceId'`)

INSTANCE_TYPES=(`echo $INSTANCES | jq -r '.Reservations[].Instances[].InstanceType'`)

INSTANCE_NAMES=(`echo $INSTANCES | jq -r '.Reservations[].Instances[].Tags[] | select(.Key == "Name") | .Value'`)

printf "InstanceId,InstanceName,InstanceType\n"
for i in "${!INSTANCE_IDS[@]}"
do
   printf "%s,%s,%s\n" "${INSTANCE_IDS[$i]}" "${INSTANCE_NAMES[$i]}" "${INSTANCE_TYPES[$i]}"
done

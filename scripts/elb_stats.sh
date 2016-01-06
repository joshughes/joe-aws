#!/bin/bash

command -v aws >/dev/null 2>&1 || { echo >&2 "I require aws cli but it's not installed.  Aborting."; exit 1; }
command -v jq >/dev/null 2>&1  || { echo >&2 "I require jq but it's not installed.  Aborting."; exit 1; }

ELBS=`aws elb describe-load-balancers`

ELB_NAMES=(`echo "${ELBS}" | jq -r '.LoadBalancerDescriptions[].LoadBalancerName'`)

get_listener_attrs ()
{
  echo ${2} | jq -r ".Listener.${1}"
}

parse_listeners ()
{
  ELB_LISTENER_PORTS=(`get_listener_attrs "LoadBalancerPort" "${2}"`)
  INSTANCE_PORTS=(`get_listener_attrs "InstancePort" "${2}"`)
  ELB_PROTOCOLS=(`get_listener_attrs "Protocol" "${2}"`)
  INSTANCE_PROTOCOLS=(`get_listener_attrs "InstanceProtocol" "${2}"`)
  for i in "${!ELB_LISTENER_PORTS[@]}"
  do
    echo "${1},${ELB_LISTENER_PORTS[$i]},${INSTANCE_PORTS[$i]},${ELB_PROTOCOLS[$i]},${INSTANCE_PROTOCOLS[$i]}"
  done
}

printf "ELB_Name,ELB_Load_Balancer_Port,Instance_Port,ELB_Protocol,Instance_Protocol\n"
for i in "${!ELB_NAMES[@]}"
do
  LISTENER_DESCRIPTIONS=`echo $ELBS | \
    jq --arg elb_name ${ELB_NAMES[$i]} -r '.LoadBalancerDescriptions[] | select(.LoadBalancerName == $elb_name) | .ListenerDescriptions[]'`
  parse_listeners ${ELB_NAMES[i]} "${LISTENER_DESCRIPTIONS}"
done

#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 <bridge_name>"
    echo "  bridge_name    The name of the bridge to use. Must meet the validation criteria."
    exit 1
}

# Check if the bridge name is provided as an argument
if [[ -z "$1" ]]; then
    echo "Error: Bridge name is required."
    usage
fi

set -e

handle_error(){
	echo "A bridge funtion has failed $1"
	exit 1
}

trap handle_error ERR

BRIDGE_NAME=$1
is_name_clash=""

echo "Running sudo apt install bridge-utils"
sudo apt install bridge-utils -y


create_the_bridge(){
	if [[ $is_name_clash -eq 0 ]]; then
		echo "Running: sudo ip link add $BRIDGE_NAME type bridge"
		sudo ip link add $BRIDGE_NAME type bridge
		bridge_creation_success=$?
		echo "Running: sudo ip link set $BRIDGE_NAME up"
		sudo ip link set $BRIDGE_NAME up
		if [[ $? -ne 0 || $bridge_creation_success -ne 0 ]]; then
			echo "ERROR: An unknonw error occured during the creation of the new bridge"
			exit 1
		fi
	else
		echo "ERROR: The bridge name $BRIDGE_NAME already exists"
		exit 1
	fi
}

name_clash(){

	local existing_bridges=$(ip link show type bridge)

	# LOGIC FOR CHECKING FOR EXISTING CLASH
	# local names_found=$(ip link show type bridge | grep -Po '^[0-9]+: ${BRIDGE_NAME}:')

	# LOGIC FOR RETURNING RESULTING CLASH
	if echo "$existing_bridges" | grep -P "^[0-9]+: ${BRIDGE_NAME}:" > /dev/null; then
		return 1
	else
		return 0
	fi
}

name_clash $BRIDGE_NAME
is_name_clash=$?
create_the_bridge

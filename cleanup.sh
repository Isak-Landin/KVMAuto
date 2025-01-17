#!/bin/bash


NETWORK_PATH=$(pwd)/network_scripts
SESSION_TMP_IP_FILE="$(pwd)/TMP/ip-output.session"
SESSION_CREATED_FILE="$(pwd)/TMP/created.session"

source $SESSION_CREATED_FILE

while IFS='=' read -r key value; do
	STIF=$SESSION_TMP_IP_FILE
	if [[ -e $STIF ]]; then
		sudo rm -f $STIF
	fi

	sudo touch $STIF
	sudo ip link show >> $STIF
	cat $STIF
	echo "$key $value"
	if grep -q '_INTERFACE$'; then
		remove_tuntap $key $value
	elif grep -q 'BRIDGE'; then
		remove_bridge $key $value
	elif grep -q 'VM'; then
		echo "No protocol to remove VMs"
	fi
done < $SESSION_CREATED_FILE

remove_bridge() {
	local key=$1
	local bridge_name=$2
	# SETTING BRIDGE TO DOWN
	sudo ip link set $bridge_name down
	# DELETING BRIDGE
	sudo ip link del $bridge_name type bridge
	echo "Deleted BRIDGE $bridge_name"
}

remove_tuntap() {
	local key=$1
	local tap_name=$2
	# SETTING TAP MODE TO DOWN
	sudo ip link set $tap_name down
	# DELETING TAP
	sudo ip tuntap del mode tap name $tap_name
	echo "Deleted TUNTAP $tap_name"
}

#!/bin/bash

# INITIATE ALL VALUES FOR STATIC SETUP OF DOMAIN

set -e

error_handler() {
	local exit_code=$?
	CLEANUP_FILE="$(pwd)/cleanup.sh"
	sudo bash $CLEANUP_FILE

	echo "ERROR: Cleaning up all devices created during this process due to critical error"
	echo "ERROR: error code $exit_code"
}

trap error_handler ERR

THIS_FILE=$0
SESSION_FILE="$(pwd)/session/configuration_session.conf"

CONFIG_DIR="$(pwd)/configs"
CONFIG_PATH_DC="$CONFIG_DIR/DC01.conf"
CONFIG_PATH_FS="$CONFIG_DIR/FS.conf"
CONFIG_PATH_WS="$CONFIG_DIR/WS.conf"
CONFIG_PATH_NETWORK="$CONFIG_DIR/NETWORK.conf"

TMP_DIR="$(pwd)/TMP"
TMP_FILE="$(pwd)/TMP/created.session"

# FIRSTLY REMOVE OLD TMP FILE, IF EXISTS, AND REPLACE WITH NEW
if [[ -d $TMP_DIR ]]; then
	if [[ ! -e $TMP_FILE ]]; then
		sudo touch $TMP_FILE
	elif [[ -e $TMP_FILE ]]; then
		sudo rm -f $TMP_FILE
		sudo touch $TMP_FILE
	fi

else
	sudo mkdir $TMP_DIR
	sudo touch $TMP_FILE
fi

echo "NEW TMP file created for this session"

IS_CONTINUE_SETUP="z"
while [[ $IS_CONTINUE_SETUP != "n" && $IS_CONTINUE_SETUP != "y" ]]; do
	read -p "Are you sure you want to proceed with installing the current configuration of the domain? (partially-dynamic-setup.sh) (y/n): " IS_CONTINUE_SETUP
done

echo "Proceeding..."

match_keys() {
    local key="$1"
    local value="$2"
    local config_file=""

    # Determine the target configuration file
    if [[ "$key" == DC_* ]]; then
        config_file="$CONFIG_DIR/DC01.conf"
    elif [[ "$key" == FS_* ]]; then
        config_file="$CONFIG_DIR/FS.conf"
    elif [[ "$key" == WS_* ]]; then
        config_file="$CONFIG_DIR/WS.conf"
    elif [[ "$key" == "BRIDGE" || "$key" == "PHYSICAL_INTERFACE" ]]; then
        config_file="$CONFIG_DIR/NETWORK.conf"
    else
        echo "Warning: Unmatched key $key (ignored)."
        return
    fi

    # Update or append the key-value pair in the configuration file
    if grep -q "^$key=" "$config_file"; then
        # Update the value if the key exists
        sed -i "s/^$key=.*/$key=$value/" "$config_file"
    else
        # Append the key-value pair if it doesn't exist
        echo "$key=$value" >> "$config_file"
    fi
}

get_keys() {
    # Source the session file to make variables available
    source "$SESSION_FILE"

    # Read the session file line by line
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue

		# Match and place the key-value pair
		match_keys "$key" "$value"
	done < "$SESSION_FILE"
}

create_network() {
	source $CONFIG_PATH_NETWORK
	source $SESSION_FILE
	local BRIDGE_NAME=$BRIDGE
	local NETWORK_SCRIPTS="$(pwd)/network_scripts"
	local BRIDGE_SCRIPT=$NETWORK_SCRIPTS/bridge.sh
	local TUNTAP_SCRIPT=$NETWORK_SCRIPTS/tuntap.sh

	# CALL BRIDGE SCRIPT AND CREATE BRIDGE
	sudo bash $BRIDGE_SCRIPT $BRIDGE_NAME || exit 1
	# SAVE BRIDGE AS CREATED in TMP
	echo "BRIDGE=$BRIDGE_NAME" > $TMP_FILE

	# CALL TUNTAP SCRIPT AND CREATE TUNTAPS
	sudo bash $TUNTAP_SCRIPT || exit 1
	# SAVE TUNTAPS AS CREATED in TMP
	_TAP_COUNT=0
	for tap in $DC_INTERFACE $FS_INTERFACE $WS_INTERFACE; do
		if [[ _TAP_COUNT -eq 0 ]]; then
			local tap_output="DC_INTERFACE=$DC_INTERFACE"
		elif [[ _TAP_COUNT -eq 1 ]]; then
			local tap_output="FS_INTERFACE=$FS_INTERFACE"
		else
			local tap_output="WS_INTERFACE=$WS_INTERFACE"
		fi
		tap_output > $TMP_FILE
		(TAP_COUNT++)
	done
}
get_keys || exit 1

create_network || exit 1


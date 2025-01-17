#!/bin/bash

set -e

handle_error(){
	echo "A tuntap function has failed to execute: $?"
	exit 1
}

trap handle_error ERR

NETWORK_PATH=$(pwd)/network_scripts
CONFIG_PATH=$(pwd)/configs
echo "This is the apparent config path $CONFIG_PATH"

for file in $CONFIG_PATH/*; do
        if [[ -f "$file" && -r "$file" ]]; then
                source "$file"
        else
                echo "Skipping $file (not readable)"
        fi
done

dc_name=$DC_INTERFACE
fs_name=$FS_INTERFACE
ws_name=$WS_INTERFACE


create_taps(){
	for tap in $dc_name $fs_name $ws_name; do
		echo "RUNNING: sudo ip tuntap add mode tap name $tap"
		sudo ip tuntap add mode tap name $tap
		echo "Setting to UP - $tap"
		sudo ip link set $tap up
	done
}

connect_taps_bridge(){
	for tap in $dc_name $fs_name $ws_name; do
		sudo ip link set tap master $BRIDGE
	done
}

for file in $CONFIG_PATH/*; do
	if [[ -f "$file" && -r "$file" ]]; then
		source "$file"
	else
		echo "Skipping $file (not readable)"
	fi
done

create_taps
connect_taps_bridge

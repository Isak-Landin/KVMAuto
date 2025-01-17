#!bin/bash

QUESTIONS_AND_VALUES=(
	# DOMAIN CONTROLLER
	"Enter domain name: DOMAIN_NAME"
	"Enter VM_NAME for the Domain Controller: DC_NAME"
	"Enter the number of CPUs that will be assigned to the Domain Controller: DC_CPU"
	"Enter the amount of RAM that will be assigned to the Domain Controller: DC_RAM"
	"Enter interface name for the Domain Controller: DC_INTERFACE"
	"Enter ip-address for the Domain Controller (Leave blank if DHCP, default /24): DC_IP"
	"Enter Disk NAME for the Domain Controller (Example DCDisk1): DC_DISK"
	"Enter Disk SIZE for the Domain Controller (B, M, G): DC_DISK_SIZE"
	"Enter hostname for the Domain Controller: DC_HOSTNAME"

	# FILE SERVER
	"Enter VM_NAME for the File server: FS_NAME"
	"Enter the number of CPUs that will be assigned to the File Server: FS_CPU"
	"Enter the amount of RAM that will be assigned to the File Server: FS_RAM"
	"Enter interface name for the File Server: FS_INTERFACE"
	"Enter ip-address for the Domain Controller (Leave blank if DHCP, default /24): FS_IP"
	"Enter Disk NAME for the File Server (Example FSDisk1): FSDISK"
	"Enter Disk SIZE for the File Server (B, M, G): FS_DISK_SIZE"
	"Enter additional disk NAME(S) for the File Server (Separated by ,): FS_DISK_ADDITIONAL"
	"Enter additional disk SIZE(s), IN ORDER by names, (B, M, G): FS_DISK_NAMES_ADDITIONAL"
	"Enter hostname for the File Server: FS_HOSTNAME"

	# WEB SERVER
	"Enter VM_NAME for the Web Server: WS_NAME"
	"Enter the number of CPUs that will be assugned to the Web Server: WS_CPU"
	"Enter the amount of RAM that will be assugned to the Web Server: WS_RAM"
	"Enter interface name for the Web Server: WS_INTERFACE"
	"Enter ip-address for the Web Server (Leave blank if DHCP, default /24): WS_IP"
	"Enter Disk NAME for the Web Server (Example WSDisk1): WS_DISK"
	"Enter Disk SIZE for the Web Server (B, M, G): WS_DISK_SIZE"
	"Enter hostname for the Web Server: WS_HOSTNAME"
	# NETWORK CONFIGURATION
	"Enter bridge new/existing name for the Network: BRIDGE"
	"Enter Physical interface that the bridge is enslaved to (Example enp4s0): PHYSICAL_INTERFACE"
)

LEN=${#QUESTIONS_AND_VALUES[@]}
this_file="$0"
this_file_relative=${this_file##*/}
this_file_absolute="$(pwd)/${this_file_relative}"

# THE LOCATION OF THE CURRENT SESSION CONFIGURATION FILE
SESSION_FILE_LOCATION="$(pwd)/session/configuration_session.conf"
source $SESSION_FILE_LOCATION

#THE LOCATION OF THE SESSION CONFIGURATION TEMPLATE FILE
SESSION_TEMPLATE_LOCATION="$(pwd)/templates/configuration_session_template.conf"

# QUESTIONS ASKED AND RELATED VARS
CONTINUE_SAFE=1
ask_questions() {
	if [[ $INDEX -ne 0 ]]; then
		local IS_RESUME="z"
		while [[ $IS_RESUME != "y" && $IS_RESUME != "n" ]]; do
			read -p "Would you like to resume configurations were you last left off? - ${LAST_STEP##*=} (y/n): " IS_RESUME
		done
		if [[ $IS_RESUME == "n" ]]; then
			# IS THIS A SUFFICENT CLEAN-UP?
			INDEX=0
			$(cp $SESSION_TEMPLATE_LOCATION $SESSION_FILE_LOCATION)
			echo "$SESSION_TEMPLATE_LOCATION $SESSION_FILE_LOCATION"
			source $SESSION_FILE_LOCATION
		fi
	fi

	local index=$INDEX

	for (( i=index; i < $LEN; i++ )); do
		# CHANGE STATE TO NOT SAFE FOR EACH QUESTION
		CONTINUE_SAFE=1

		local question_and_name=${QUESTIONS_AND_VALUES[i]}
		local question=${question_and_name%%:*}
		local name=${question_and_name##*:}
		# CHECK FOR ERROR BEFORE CONTINUATION

		# Check ERROR IN USER INPUT
		while [ $CONTINUE_SAFE == 1 ]; do
			read -p "${question}: " user_input
			check_input_errors "$user_input"
			CONTINUE_SAFE=$?
		done
		if [[ "$user_input" == "exit" ]]; then
			is_exit="z"
			save_last_step $name
			while [[ is_exit != "y" && is_exit != "n" ]]; do
				read -p "Are you sure you want to exit the configuration (y/n): " is_exit
				if [[ "$is_exit" == "y" ]]; then
					exit 0
				elif [[ "$is_exit" == "n" ]]; then
					#echo "$this_file_path"
					"$(sudo bash $this_file_path)"
				fi
			done
		fi

		((index++))
		save_configuration_step $name $user_input $index
		echo "Our new local index is $index"
		echo "Our new global index is $INDEX"
	done
}

# WHEN A USER EXITS, THERE NEEDS TO BE A WAY TO SAVE THE LAST STEP ONLY. IN ORDER TO RESUME LATER
save_last_step() {
	local key="$1"
	local file="$SESSION_FILE_LOCATION"

	if grep -q "^LAST_STEP=" "$file"; then
		sed -i "s/^LAST_STEP=.*/LAST_STEP=$name/" "$file"
	else
		echo "LAST_STEP=$key" >> "$file"
	fi
}

save_configuration_step() {
	local key="$1"
	local value="$2"
	local _index="$3"
	local file="$SESSION_FILE_LOCATION"

	if grep -q "^$key=" "$file"; then
		# IF KEY ALREADY EXISTS IN file.conf, REPLACE EXISTING VALUE
        	sed -i "s/^$key=.*/$key=$value/" "$file"
    	else
		# IF KEY DOES NOT EXIST ADD KEY AND VALUE
        	echo "$key=$value" >> "$file"
    	fi

	# SAME BUT FOR INDEX
	if grep -q "^INDEX=" "$file"; then
		sed -i "s/^INDEX=.*/INDEX=$index/" "$file"
	else
		echo "INDEX=$_index" >> "$file"
	fi

	# SAME BUT FOR LAST KNOWN STEP
	if grep -q "^LAST_STEP=" "$file"; then
		sed -i "s/^LAST_STEP=.*/LAST_STEP=$key/" "$file"
	else
		echo "LAST_STEP=$name" >> "$file"
	fi
	echo "Saving Configuration Step."
}

# resume_configuration() {}

handle_error() {
    echo "Error encountered. What would you like to do?"
    select choice in "Back" "Retry" "Exit"; do
        case $choice in
            Back)
                return 1  # Go back one step
                ;;
            Retry)
                return 0  # Retry the current step
                ;;
            Exit)
                echo "Saving session and exiting."
                exit 1
                ;;
        esac
    done
}

check_input_errors() {
	local input="$1"
	FORBIDDEN_CHARS='\\`"|;:!@#$%^&*()+={}<>?,~'
	if echo "$input" | grep -q "[$FORBIDDEN_CHARS]"; then
		echo "Error: Input contains forbidden characters."
		return 1
	else
		return 0
	fi
}
ask_questions

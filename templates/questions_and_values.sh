#!bin/bash

QUESTIONS_AND_VALUES=(
	# DOMAIN CONTROLLER
	("Enter domain name: " DOMAIN_NAME)
	("Enter VM_NAME for the Domain Controller: " DC_NAME)
	("Enter the number of CPUs that will be assigned to the Domain Controller: " DC_CPU)
	("Enter the amount of RAM that will be assigned to the Domain Controller: " DC_RAM)
	("Enter interface name for the Domain Controller: " DC_INTERFACE)
	("Enter ip-address for the Domain Controller (Leave blank if DHCP, default /24): " DC_IP)
	("Enter Disk NAME for the Domain Controller (Example: DCDisk1): " DC_DISK)
	("Enter Disk SIZE for the Domain Controller (B, M, G): " DC_DISK_SIZE)
	("Enter hostname for the Domain Controller: " DC_HOSTNAME)

	# FILE SERVER
	("Enter VM_NAME for the File server: " FS_NAME)
	("Enter the number of CPUs that will be assigned to the File Server: " FS_CPU)
	("Enter the amount of RAM that will be assigned to the File Server: " FS_RAM)
	("Enter interface name for the File Server: " FS_INTERFACE)
	("Enter ip-address for the Domain Controller (Leave blank if DHCP, default /24): " FS_IP)
	("Enter Disk NAME for the File Server (Example: FSDisk1)" FSDISK)
	("Enter Disk SIZE for the File Server (B, M, G): " FS_DISK_SIZE)
	("Enter additional disk NAME(S) for the File Server (Separated by ,): " FS_DISK_ADDITIONAL)
	("Enter additional disk SIZE(s), IN ORDER by names, (B, M, G): " FS_DISK_NAMES_ADDITIONAL)
	("Enter hostname for the File Server: " FS_HOSTNAME)

	# WEB SERVER
	("Enter VM_NAME for the Web Server: " WS_NAME)
	("Enter the number of CPUs that will be assugned to the Web Server: " WS_CPU)
	("Enter the amount of RAM that will be assugned to the Web Server: " WS_RAM)
	("Enter interface name for the Web Server: " WS_INTERFACE)
	("Enter ip-address for the Web Server (Leave blank if DHCP, default /24): " WS_IP)
	("Enter Disk NAME for the Web Server (Example WSDisk1): " WS_DISK)
	("Enter Disk SIZE for the Web Server (B, M, G): " WS_DISK_SIZE)
	("Enter hostname for the Web Server: " WS_HOSTNAME)
	# NETWORK CONFIGURATION
	("Enter bridge new/existing name for the Network: " BRIDGE)
	("Enter Physical interface that the bridge is enslaved to (Example enp4s0): " PHYSICAL_INTERFACE)
)

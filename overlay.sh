#!/bin/bash

# This script will overlay the flek3s project files onto a fresh Alpine Linux OS
# installation and make sure that:
#  all package dependencies are in place
#  all init scripts are correct
#  user accounts are ready
#  file permissions are set

# Files:
script_dir=$(dirname "$BASH_SOURCE")
echo "Script dir: $script_dir"
cd ${script_dir}
for folder in etc usr; do
	echo cp -r $folder /
done

# Packages:
apk add grep jq linux-pam shadow open-vm-tools open-vm-tools-guestinfo open-vm-tools-deploypkg etcd bash vim openssh sudo open-vm-tools-vix open-vm-tools-hgfs open-vm-tools-timesync open-vm-tools-vmbackup open-vm-tools-plugins-all curl wget etcd-ctl open-iscsi cfssl

# Init:
rc-update add open-vm-tools default
rc-update add local boot

# User accounts: 
# setup / changeme is the default user, launches to configshell 
adduser -s /usr/local/bin/configshell setup
# peer / [user settable] is the peering user (used for cluster setup operations)
adduser -s /bin/bash peer


# File permissions: 
# should be root:root 700 unless specified here
# /usr/local/bin
cd /usr/local/bin/
chown root:root *
chmod 700 *
chown setup:root configshell
chmod +x pause validate_ip mask2cidr cidr2mask
cd -



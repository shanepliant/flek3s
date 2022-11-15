#!/bin/bash

# This script will overlay the flek3s project files onto a fresh Alpine Linux OS
# installation and make sure that:
#  all package dependencies are in place
#  all third party executables and configurations are staged
#  all init scripts are correct
#  user accounts are ready
#  file permissions are set

# Files:
echo "Putting flek3s source files in place..."
script_dir=$(dirname "$BASH_SOURCE")
echo "Script dir: $script_dir"
cd ${script_dir}
for folder in etc usr; do
	echo cp -r $folder /
	cp -r $folder /
done

# Packages:
echo "Adding Alpine packages..."
apk update
apk add grep util-linux jq linux-pam shadow open-vm-tools open-vm-tools-guestinfo open-vm-tools-deploypkg etcd bash vim openssh sudo open-vm-tools-vix open-vm-tools-hgfs open-vm-tools-timesync open-vm-tools-vmbackup open-vm-tools-plugins-all curl wget etcd-ctl open-iscsi cfssl
apk del kubectl

# Init:
echo "Confirming runlevels for default services..."
rc-update add open-vm-tools default
rc-update add local boot

# User accounts: 
# setup / changeme is the default user, launches to configshell 
getent passwd setup > /dev/null 2>&1
if [ $? -ne 0 ]; then 
	echo "Adding setup user..."
	adduser -s /usr/local/bin/configshell setup
else
	echo "Setup user already exists"
fi
# peer / [user settable] is the peering user (used for cluster setup operations)
getent passwd peer > /dev/null 2>&1
if [ $? -ne 0 ]; then 
	echo "Adding peer user..."
	adduser -D -s /bin/bash peer
else
	echo "Peer user already exists"
fi
# update / [user settable] is the update user (used for uploading upgrade files via sftp)
getent passwd update > /dev/null 2>&1
if [ $? -ne 0 ]; then 
	echo "Adding update user..."
	adduser -D --home /usr/src/flek3s update -s /bin/false
else
	echo "update user already exists"
fi

cat << EOF >> /etc/sshd_config
Match user update
  ForceCommand internal-sftp
  ChrootDirectory /usr/src/flek3s

Subsystem       sftp    internal-sftp
EOF

# File permissions: 
# should be root:root 700 unless specified here
# /usr/local/bin
echo "Adjusting default file permissions..."
cd /usr/local/bin/
chown root:root *
chmod 700 *
chown setup:root configshell
chmod +x pause validate_ip mask2cidr cidr2mask
cd -

# Set up the .ssh directory for the peer user
mkdir -p /home/peer/.ssh 
chown peer:peer /home/peer/.ssh

# /usr/libexec/flek3s
chown root:root /usr/libexec/flek3s/*
chmod 700 /usr/libexec/flek3s/*

# Set up initial message in etc/issue
echo "Populating /etc/issue..."
cp /etc/issue.base /etc/issue
echo "Log in to run initial setup" >> /etc/issue
echo "Default user: setup" >> /etc/issue
echo "Default password: changeme" >> /etc/issue
echo "" >> /etc/issue

bash ./stage-k3s-install.sh

bash ./stage-longhorn-install.sh

echo "Update branding"
sed -i /boot/extlinux.conf -e "s_AUTOBOOT Alpine_AUTOBOOT flek3s/Alpine_"

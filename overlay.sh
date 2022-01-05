#!/bin/bash

# This script will overlay the flek3s project files onto a fresh Alpine Linux OS
# installation and make sure that:
#  all package dependencies are in place
#  all third party executables and configurations are staged
#  all init scripts are correct
#  user accounts are ready
#  file permissions are set

# Variables
longhorn_version="1.2.2"

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
apk add grep jq linux-pam shadow open-vm-tools open-vm-tools-guestinfo open-vm-tools-deploypkg etcd bash vim openssh sudo open-vm-tools-vix open-vm-tools-hgfs open-vm-tools-timesync open-vm-tools-vmbackup open-vm-tools-plugins-all curl wget etcd-ctl open-iscsi cfssl
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
	useradd -s /bin/bash peer
else
	echo "Peer user already exists"
fi

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

# Set up initial message in etc/issue
echo "Populating /etc/issue..."
cp /etc/issue.base /etc/issue
echo "Log in to run initial setup" >> /etc/issue
echo "Default user: setup" >> /etc/issue
echo "Default password: changeme" >> /etc/issue
echo "" >> /etc/issue

# Pull files that are not ours and not available via apk
echo "Getting latest k3s install script..."
mkdir -p /usr/libexec/k3s
curl -sfL https://get.k3s.io > /usr/libexec/k3s/install.sh
chmod u+x /usr/libexec/k3s/install.sh

echo "Getting latest k3s executable..."
GITHUB_URL=https://github.com/k3s-io/k3s/releases
INSTALL_K3S_CHANNEL_URL=${INSTALL_K3S_CHANNEL_URL:-'https://update.k3s.io/v1-release/channels'}
INSTALL_K3S_CHANNEL=${INSTALL_K3S_CHANNEL:-'stable'}
version_url="${INSTALL_K3S_CHANNEL_URL}/${INSTALL_K3S_CHANNEL}"
VERSION_K3S=$(curl -w '%{url_effective}' -L -s -S ${version_url} -o /dev/null | sed -e 's|.*/||')
BIN_URL=${GITHUB_URL}/download/${VERSION_K3S}/k3s
curl -o /usr/libexec/k3s/k3s -sfL $BIN_URL 
chmod +x /usr/libexec/k3s/k3s

echo "Getting Longhorn YAML for version ${longhorn_version}..."
mkdir -p /usr/src/longhorn
curl -o /usr/src/longhorn/longhorn.yaml -sfL https://raw.githubusercontent.com/longhorn/longhorn/${longhorn_version}/deploy/longhorn.yaml

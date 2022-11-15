#!/bin/bash
# This is the script that is packaged with a flek3s upgrade tarball to run the upgrade commands

echo "Beginning flek3s upgrade process"

# Upgrade the Alpine components 
 # clear the apk cache path
 rm -rf /var/cache/apk
 # expand the upgrade packages
 tar -xf /usr/src/alpine/apks.tar.gz -C /
 # install the apks 
 cd /var/cache/apk
 apk add --allow-untrusted $(ls *.apk) 
 cd -

# Fix file permissions
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


# IF K3s is installed, upgrade it
k3s --version >/dev/null 2>&1 && k3s_installed=1 || k3s_installed=0
if [ $k3s_installed -eq 1 ]; then 

	cp /usr/libexec/k3s/k3s /usr/local/bin/
	/etc/init.d/k3s restart 
	/usr/local/bin/k3s ctr -n k8s.io  -a /run/k3s/containerd/containerd.sock image import /usr/libexec/k3s/k3s-airgap-images-amd64.tar
	# Is longhorn present? 
	kubectl get namespace longhorn && longhorn_installed=1 || longhorn_installed=0
	if [ $longhorn_installed -eq 1 ]; then
		/usr/local/bin/k3s ctr -n k8s.io  -a /run/k3s/containerd/containerd.sock image import /usr/src/longhorn/longhorn-images.tar
		# Are we the first node?
		
		kubectl apply -f /usr/src/longhorn/longhorn.yaml
	fi
fi

#!/bin/bash

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
PACK_URL=${GITHUB_URL}/download/${VERSION_K3S}/k3s-airgap-images-amd64.tar
curl -o /usr/libexec/k3s/k3s -sfL $BIN_URL 
curl -o /usr/libexec/k3s/k3s-airgap-images-amd64.tar -sfL $PACK_URL 
chmod +x /usr/libexec/k3s/k3s

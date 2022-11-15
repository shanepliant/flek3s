#!/bin/bash

# Script to assemble a package needed to upgrade an air-gapped flek3s instance

# Get the APK packages

bash ./stage-alpine-upgrade.sh

# Get the k3s binary, script and images

bash ./stage-k3s-install.sh

# Get the longhorn YAML and images

bash ./stage-longhorn-install.sh


# Pack it up

tar -czvf flek3s-upgrade-$(cat ./VERSION).tar.gz /usr/src/alpine /usr/src/longhorn /usr/libexec/k3s etc/apk etc/sudoers.d etc/local.d usr/local/bin usr/libexec/flek3s VERSION upgrade-run.sh

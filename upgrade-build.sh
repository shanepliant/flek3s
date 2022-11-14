#!/bin/bash

# Script to assemble a package needed to upgrade an air-gapped flek3s instance

# Get the APK packages

bash ./stage-alpine-upgrade.sh

# Get the k3s binary, script and images

bash ./stage-k3s-install.sh

# Get the longhorn YAML and images

bash ./stage-longhorn-install.sh


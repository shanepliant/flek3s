#!/bin/bash

# get our tools
apk add docker
/etc/init.d/docker start

# images for longhorn-images.tar

docker pull docker.io/longhornio/longhorn-engine:v1.2.0
docker pull docker.io/longhornio/longhorn-manager:v1.2.0
docker pull docker.io/longhornio/longhorn-ui:v1.2.0
docker pull docker.io/longhornio/longhorn-instance-manager:v1_20210731
docker pull docker.io/longhornio/longhorn-share-manager:v1_20210820
docker pull docker.io/longhornio/backing-image-manager:v2_20210820
docker pull k8s.gcr.io/sig-storage/csi-attacher:v3.2.1
docker pull k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.3.0
docker pull k8s.gcr.io/sig-storage/csi-provisioner:v2.1.2
docker pull k8s.gcr.io/sig-storage/csi-resizer:v1.2.0
docker pull k8s.gcr.io/sig-storage/csi-snapshotter:v3.0.3

echo "saving compressed images"

docker save \
docker.io/longhornio/longhorn-engine:v1.2.0 \
docker.io/longhornio/longhorn-manager:v1.2.0 \
docker.io/longhornio/longhorn-ui:v1.2.0 \
docker.io/longhornio/longhorn-instance-manager:v1_20210731 \
docker.io/longhornio/longhorn-share-manager:v1_20210820 \
docker.io/longhornio/backing-image-manager:v2_20210820 \
k8s.gcr.io/sig-storage/csi-attacher:v3.2.1 \
k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.3.0 \
k8s.gcr.io/sig-storage/csi-provisioner:v2.1.2 \
k8s.gcr.io/sig-storage/csi-resizer:v1.2.0 \
k8s.gcr.io/sig-storage/csi-snapshotter:v3.0.3 \
 > ./longhorn-images.tar

# cleanup docker
docker rmi $(docker images -q)
/etc/init.d/docker stop
apk del docker

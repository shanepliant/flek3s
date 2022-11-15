#!/bin/bash

# Variables
longhorn_version="1.3.2"

echo "Getting Longhorn images for version ${longhorn_version}..."
wget https://raw.githubusercontent.com/longhorn/longhorn/v${longhorn_version}/deploy/longhorn-images.txt
if [ -f "longhorn-images.txt" ]; then 

	# get our tools
	apk add docker
	/etc/init.d/docker start
	sleep 30

	# images for longhorn-images.tar
	imglist=""
	for img in $(cat longhorn-images.txt); do 
		echo "Image $img"
		docker pull $img
		if [ $? -ne 0 ]; then exit 1; fi
		imglist="${img} ${imglist}"
	done

	echo "saving compressed images"
	docker save $imglist > /usr/src/longhorn/longhorn-images.tar

	# cleanup docker
	docker rmi $(docker images -q)
	/etc/init.d/docker stop
	apk del docker
	rm longhorn-images.txt
else
	echo "[ ERROR ] longhorn-images.txt file not found. Cannot stage images without the list"
	exit 1
fi

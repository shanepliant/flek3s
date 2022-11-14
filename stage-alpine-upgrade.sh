#!/bin/bash

if [ -d "/var/cahce/apk" ]; then mv /var/cache/apk /var/cache/apk.old; fi
setup-apkcache /var/cache/apk
apk cache download
apk cache -v sync
apk --update-cache upgrade
mkdir -p /usr/src/alpine
tar -czvf /usr/src/alpine/apks.tar.gz


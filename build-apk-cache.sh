#!/bin/bash

setup-apkcache /var/cache/apk
apk cache download
apk cache -v sync
apk --update-cache upgrade



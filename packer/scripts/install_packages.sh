#/bin/sh
set -e
set -x

BUILDDEPS=curl

# install required packages
export DEBIAN_FRONTEND=noninteractive
apt-get update -q
apt-get install -y nginx curl

## Clear unneeded binaries
apt-get remove -y $BUILDDEPS
apt-get autoclean
apt-get --purge -y autoremove
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

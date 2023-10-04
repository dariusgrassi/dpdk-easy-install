#!/bin/bash

set -e
source `dirname $0`/env.sh

if [ -z "$OFED_VERSION" ] ; then
  echo "Environment variables not properly set. Did you run $(dirname $0)/env.sh?"
  exit 1
fi

echo "Downloading OFED to home directory... ($(pwd)/..)"

cd $(pwd)/.. &&
sudo apt-get update &&
wget http://www.mellanox.com/downloads/ofed/MLNX_OFED-${OFED_VERSION}/MLNX_OFED_SRC-debian-${OFED_VERSION}.tgz &&
tar xzf MLNX_OFED_SRC-debian-${OFED_VERSION}.tgz &&
cd MLNX_OFED_SRC-${OFED_VERSION}/ &&
sudo ./install.pl
sudo reboot

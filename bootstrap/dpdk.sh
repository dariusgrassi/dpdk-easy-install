#!/usr/bin/env bash

source `dirname $0`/env.sh

if [ -z "$RTE_VERSION" ] || [ -z "$RTE_SDK" ] || [ -z "$RTE_TARGET" ] || [ -z "$OFED_VERSION" ] || [ -z "$WORKSPACE" ]; then
  echo "Environment variables not properly set. Did you run $(dirname $0)/env.sh?"
  exit 1
fi

# Install OFED
if ofed_info -s ; then
	echo "OFED installed already! Skipping..."
else
	echo "Installing OFED will automatically reboot the server."
	while true; do

	read -p "Do you want to proceed? (y/n) " yn
	case $yn in
		[yY] ) echo Installing OFED...;
			break;;
		[nN] ) echo Exiting...;
			exit;;
		* ) echo invalid response;;
	esac
	done

	sudo .$(pwd)/bootstrap/ofed.sh
fi

# Install DPDK
echo "Installing DPDK..."
sudo apt update
sudo apt install -y python3 ninja-build libnuma-dev
sudo pip3 install meson

echo "Entering $(pwd)/.."
cd $(pwd)/..
wget -nc https://fast.dpdk.org/rel/dpdk-${RTE_VERSION}.tar.xz
tar xJf dpdk-${RTE_VERSION}.tar.xz
echo "Entering ${WORKSPACE}/${RTE_SDK}"
cd ${USERHOME}/${RTE_SDK}

meson --prefix=${USERHOME}/${RTE_SDK}/${RTE_TARGET} build
cd build
ninja
sudo ninja install
sudo ldconfig

# Reserve hugepages
echo "Reserving hugepages..."
sudo ${WORKSPACE}/bootstrap/hugepages.sh

#!/bin/bash

# install build dependencies
echo installing build dependencies...
sudo apt install -y build-essential libnuma-dev pkg-config python3 python3-pip python3-setuptools python3-wheel python3-pyelftools ninja-build 
sudo pip3 install meson

sudo apt install -y libpcap-dev
sudo apt install -y linux-headers-$(uname -r)

# download xilinx qdma dpdk driver and apply opennic patches
git clone https://github.com/Xilinx/dma_ip_drivers.git
cd dma_ip_drivers
git checkout 7859957
cd ..

git clone https://github.com/Xilinx/open-nic-dpdk
cp open-nic-dpdk/*.patch dma_ip_drivers
cd dma_ip_drivers
git apply *.patch
cd ..

# download dpdk and pktgen-dpdk
wget https://fast.dpdk.org/rel/dpdk-20.11.tar.xz
tar xvf dpdk-20.11.tar.xz
cd dpdk-20.11
cp -R ../dma_ip_drivers/QDMA/DPDK/drivers/net/qdma ./drivers/net
cp -R ../dma_ip_drivers/QDMA/DPDK/examples/qdma_testapp ./examples

echo Inserting 'qdma' into $(pwd)/drivers/net/meson.build ...
sudo sed -i '46i\    '"'"'qdma'"'"',' $(pwd)/drivers/net/meson.build

cd ..

wget \
https://git.dpdk.org/apps/pktgen-dpdk/snapshot/pktgen-dpdk-pktgen-20.11.3.tar.xz
tar xvf pktgen-dpdk-pktgen-20.11.3.tar.xz

# build dpdk
cd dpdk-20.11
meson build
cd build
ninja
sudo ninja install
ls -l /usr/local/lib/x86_64-linux-gnu/librte_net_qdma.so
sudo ldconfig
ls -l ./app/test/dpdk-test
cd ../..

cd pktgen-dpdk-pktgen-20.11.3
make RTE_SDK=../dpdk-20.11 RTE_TARGET=build

# install pcimem
cd ..
echo Installing pcimem tool
git clone https://github.com/billfarrow/pcimem.git
cd pcimem
git fetch origin pull/11/head:logger
git checkout logger
make main
sudo cp pcimem /usr/bin/

# configure proc/cmdline and bios if necessary
echo Make sure that IOMMU is enabled within the BIOS settings.
echo 
echo Note: Enable VT-d for Intel processors within the BIOS.
echo 
echo Set grub settings to enable hugepages and IOMMU if necessary. The following example grub command line below is based on an AMD machine with e.g. 16GB of RAM, so please adjust the number of hugepages below as appropriate.
echo 
echo Edit /etc/default/grub to include the following line:
echo 
echo GRUB_CMDLINE_LINUX=" default_hugepagesz=1G hugepagesz=1G hugepages=4"
echo 
echo Note: Add intel_iommu=on above for Intel processors.
echo 
echo Update grub:
echo 
echo sudo update-grub
echo Reboot for the changes to take effect.
echo 
echo sudo reboot
echo Confirm that hugepages appears within the /proc/cmdline:
echo 
echo cat /proc/cmdline

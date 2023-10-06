#!/bin/bash
set -e

# WARNING! before running this script, ensure you have properly installed open nic shell onto your smart nic
# ensure your parameters when generating the bitfile included -num_cmac_port 2 and -num_phys_func 2
# see my guide for installing opennic shell for more information
# "https://wikis.utexas.edu/pages/viewpage.action?spaceKey=utns&title=Programming+FPGA+NICs#ProgrammingFPGANICs-InstallingtheNICShell"
# something like vivado -mode tcl -source build.tcl -tclargs -board au280 -min_pkt_len 64 -max_pkt_len 9600 -num_cmac_port 2 -num_phys_func 2 -impl 1 -post_impl 1 -jobs 64

if [ $# -eq 0 ]; then
    echo "Usage: write-hw-registers.sh DEVICE_BDF DEVICE_BDF_1"
	  echo "Example: sudo ./write_hw_registers 0000:3b:00.0 0000:3b:00.1"
    lspci -d 10ee:
    exit 1
fi

device_bdf=$1
device_bdf_pf2=$2

sudo dpdk-20.11/usertools/dpdk-devbind.py -u ${device_bdf}
sudo dpdk-20.11/usertools/dpdk-devbind.py -u ${device_bdf_pf2}

# enable pcie for writing
sudo setpci -s ${device_bdf} COMMAND=0x02
sudo setpci -s ${device_bdf_pf2} COMMAND=0x02

# these only need to be done for the first bdf because the first one is the master

# write to qdma
sudo pcimem /sys/devices/pci0000:3a/0000:3a:00.0/${device_bdf}/resource2 0x1000 w 0x1
sudo pcimem /sys/devices/pci0000:3a/0000:3a:00.0/${device_bdf}/resource2 0x2000 w 0x00010001

# write to enable cmac 0
sudo pcimem /sys/devices/pci0000:3a/0000:3a:00.0/${device_bdf}/resource2 0x8014 w 0x1
sudo pcimem /sys/devices/pci0000:3a/0000:3a:00.0/${device_bdf}/resource2 0x800c w 0x1

# write to enable cmac 1
sudo pcimem /sys/devices/pci0000:3a/0000:3a:00.0/${device_bdf}/resource2 0xC014 w 0x1
sudo pcimem /sys/devices/pci0000:3a/0000:3a:00.0/${device_bdf}/resource2 0xC00c w 0x1

# read back link status of cmac0 and cmac1
echo read back link status of cmac 0 and cmac 1
sudo pcimem /sys/devices/pci0000:3a/0000:3a:00.0/${device_bdf}/resource2 0x8204
sudo pcimem /sys/devices/pci0000:3a/0000:3a:00.0/${device_bdf}/resource2 0xC204

# bind the interface to vfio
sudo dpdk-20.11/usertools/dpdk-devbind.py -b vfio-pci ${device_bdf} ${device_bdf_pf2}

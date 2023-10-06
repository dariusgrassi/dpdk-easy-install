To install the OpenNIC DPDK driver using these scripts

1. Run `sudo ./dpdk_driver.sh`
2. Configure hugepages and enable iommu in the BIOS according to the output instructions once by dpdk_driver.sh once the script completes
3. Program the FPGA with the OpenNIC shell bitstream and warm reboot the machine (suggested vivado params in write_hw_registers.sh)
4. Run `sudo ./write_hw_registers.sh`

Test with `sudo pktgen-dpdk-pktgen-20.11.3/usr/local/bin/pktgen -a 3b:00.0 -a 3b:00.1 -d librte_net_qdma.so -l 4,6,8,10,12,14,16 -n 4 -a 3a:00.0 -- -m [6:8].0 -m [10:12].1`

the pcie addr in the previous command relies on the device bdfs. run `lspci -d 10ee:` to locate these.

also worth noting in this command is the -l command. the machine used in this build uses numa 0, which only uses even cores. therefore you can only use even, or if you use numa 1 you can only use odd.

notes
-
- if you quit dpdk-pktgen afterwards, you must **rerun** `sudo ./write_hw_registers.sh` before starting dpdk-pktgen again. otherwise it will not be able to receive packets.
- when you start generating packets to the fpga nic port, it seems you must use the proper mac address and not a dummy one. mine was displayed after installing the kernel driver and viewing the dmesg output. strange, but it worked.

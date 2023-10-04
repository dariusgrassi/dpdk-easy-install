#!/bin/bash

source `dirname $0`/env.sh

if [ -z "$RTE_SDK" ] ; then
  echo "Environment variables not properly set. Did you run $(dirname $0)/env.sh?"
  exit 1
fi

echo "Reserving hugepages for NUMA configuration..."
echo 1024 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages
echo 1024 > /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages

# NOTE: reserving hugepages for non-NUMA machines may be different; refer to your guide for more information
# see https://doc.dpdk.org/guides-19.11/linux_gsg/sys_reqs.html#use-of-hugepages-in-the-linux-environment

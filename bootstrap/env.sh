#!/usr/bin/env bash
export USERHOME={TODO: set your home directory (cd ~; pwd)}
export WORKSPACE="$USERHOME/{TODO: your dpdk app dir here}"

export RTE_VERSION={TODO: your desired dpdk version, e.g. 19.11.14}
export RTE_SDK="${USERHOME}/dpdk-stable-$RTE_VERSION"
export RTE_TARGET={TODO, your target, e.g. "x86_64-native-linux-gcc"}

export OFED_VERSION={TODO, your desired OFED version, e.g. 5.6-2.0.9.0}

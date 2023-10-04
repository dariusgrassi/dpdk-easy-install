# dpdk-easy-install
This repository is created with the following specs in mind:
- NIC: Mellanox CX-6 Dx
- OS: Ubuntu 20.04
- DPDK: 19.11.14 LTS
- OFED: 5.6-2.0.9.0

It aims to give some helpful scripts for automating installation of DPDK for these types of machines. Mileage may vary for different NICs, HW architectures, OSes, and DPDK versions.

This code assumes there is a directory `src/` containing the source files for the dpdk application.

## steps
1. configure the file `bootstrap/env.sh` with your specific variables
2. run `sudo ./bootstrap/dpdk.sh` to install OFED and DPDK
3. run `./build.sh` to generate the app binary
4. run `sudo ./app.sh <params>` to execute the app binary

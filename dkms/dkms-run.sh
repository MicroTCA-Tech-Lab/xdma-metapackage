#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "Skipping dkms build/install w/o root privileges."
   exit 0
fi

# Remove module in case it was installed previously
dkms remove xdma/${XDMA_VER_STR} --all

# Build / install module
dkms build xdma/${XDMA_VER_STR}
dkms install xdma/${XDMA_VER_STR}

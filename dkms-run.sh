#!/bin/bash

# Remove module in case it was installed previously
dkms remove xdma/${XDMA_VER_STR} --all

# Build / install module
dkms build xdma/${XDMA_VER_STR}
dkms install xdma/${XDMA_VER_STR}

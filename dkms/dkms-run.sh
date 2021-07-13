#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "Skipping dkms build/install w/o root privileges."
   exit 0
fi

# Remove module in case it was installed previously
bash ${BINDIR}/prerm

# Build dkms & update udev
bash ${BINDIR}/postinst

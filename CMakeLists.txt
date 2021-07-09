cmake_minimum_required (VERSION 3.9)
Project(xdma-metapackage)

# Retrieve version info from xdma source tree.
file(READ dma_ip_drivers/XDMA/linux-kernel/xdma/version.h XDMA_VERSION_H)

foreach(VER_CODE DRV_MOD_MAJOR;DRV_MOD_MINOR;DRV_MOD_PATCHLEVEL)
    # We can't work with ^ and $, as CMake regex works not on lines, but on the whole string
    string(REGEX MATCHALL "#define[ \t]+${VER_CODE}[ \t]+([0-9]+)" _ ${XDMA_VERSION_H})
    set(${VER_CODE} "${CMAKE_MATCH_1}")
    if(${VER_CODE} STREQUAL "")
        message(FATAL_ERROR "Unable to parse XDMA driver version ${VER_CODE}")
    endif()
endforeach()

set(XDMA_VER_STR "${DRV_MOD_MAJOR}.${DRV_MOD_MINOR}.${DRV_MOD_PATCHLEVEL}")
message("Detected XDMA driver version ${XDMA_VER_STR}")

# udev-related stuff

option(INSTALL_UDEV_RULES
    "Install udev rules for xdma driver" ON
)

set(UDEV_RULES_PATH
    "/etc/udev/rules.d"
    CACHE STRING
    "Target directory for udev rules installation"
)

if(INSTALL_UDEV_RULES)
install(FILES
    udev_rules/60-xdma.rules
    udev_rules/xdma-udev-command.sh
    DESTINATION ${UDEV_RULES_PATH}
    COMPONENT "udev_rules"
)
endif()

# dkms-related stuff

set(DKMS_DEST /usr/src/xdma-${XDMA_VER_STR})

install(DIRECTORY DESTINATION ${DKMS_DEST})

configure_file(dkms.conf.in dkms.conf @ONLY)
install(FILES
    "${CMAKE_BINARY_DIR}/dkms.conf"
    DESTINATION ${DKMS_DEST}
    COMPONENT "dkms.conf"
)

install(DIRECTORY
    "dma_ip_drivers/XDMA/linux-kernel/include"
    "dma_ip_drivers/XDMA/linux-kernel/xdma"
    DESTINATION ${DKMS_DEST}
    COMPONENT "source tree"
)
install(FILES
    "dma_ip_drivers/XDMA/linux-kernel/COPYING"
    "dma_ip_drivers/XDMA/linux-kernel/LICENSE"
    "dma_ip_drivers/XDMA/linux-kernel/readme.txt"
    "dma_ip_drivers/XDMA/linux-kernel/RELEASE"
    DESTINATION ${DKMS_DEST}
    COMPONENT "metadata"
)

install(CODE
    "execute_process(COMMAND ${CMAKE_COMMAND} -E env XDMA_VER_STR=${XDMA_VER_STR} bash ${CMAKE_SOURCE_DIR}/dkms-run.sh)"
)

# Create debian package containing dkms module and udev rules

configure_file(postinst.in postinst @ONLY)
configure_file(prerm.in prerm @ONLY)

set(CPACK_GENERATOR "DEB")
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "techlab.desy.de")
set(CPACK_PACKAGE_VERSION_MAJOR ${DRV_MOD_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${DRV_MOD_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${DRV_MOD_PATCHLEVEL})
set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA
    "${CMAKE_BINARY_DIR}/postinst;${CMAKE_BINARY_DIR}/prerm")
include(CPack)

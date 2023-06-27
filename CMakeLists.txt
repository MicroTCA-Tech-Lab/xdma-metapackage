cmake_minimum_required (VERSION 3.5)
Project(xdma-metapackage)

include(GNUInstallDirs)

if("${XDMA_DEBUG}" STREQUAL "1")
    message("Configuring dkms.conf to build the XDMA module with -DDEBUG")
    set(XDMA_EXTRA_MAKE_ARGS "DEBUG=1")
else()
    message("Use cmake -DXDMA_DEBUG='1' to build the XDMA module with -DDEBUG")
endif()


# Retrieve version info from xdma source tree.
set(XDMA_SOURCES "${CMAKE_SOURCE_DIR}/dma_ip_drivers/XDMA/linux-kernel")
set(XDMA_VERSION_FILE "${XDMA_SOURCES}/xdma/version.h")
if(NOT EXISTS ${XDMA_VERSION_FILE})
    message(FATAL_ERROR "Could not find XDMA source tree. Make sure the submodule is there\n(git submodule init && git submodule update)")
endif()

file(READ ${XDMA_VERSION_FILE} XDMA_VERSION_H)

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
    ${CMAKE_SOURCE_DIR}/udev/60-xdma.rules
    ${CMAKE_SOURCE_DIR}/udev/xdma-udev-command.sh
    DESTINATION ${UDEV_RULES_PATH}
    COMPONENT "udev_rules"
)
endif()

# dkms-related stuff

set(DKMS_DEST /usr/src/xdma-${XDMA_VER_STR})

install(DIRECTORY DESTINATION ${DKMS_DEST})

configure_file(${CMAKE_SOURCE_DIR}/dkms/dkms.conf.in dkms.conf @ONLY)
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

configure_file(${CMAKE_SOURCE_DIR}/dkms/dkms-run.sh.in dkms-run.sh @ONLY)
install(CODE
    "execute_process(COMMAND ${CMAKE_COMMAND} -E env XDMA_VER_STR=${XDMA_VER_STR} BINDIR=${CMAKE_BINARY_DIR} bash ${CMAKE_BINARY_DIR}/dkms-run.sh)"
)

# xdma tools

set(XDMA_TOOLS "${XDMA_SOURCES}/tools")
add_executable(xdma-reg-rw "${XDMA_TOOLS}/reg_rw.c")

add_definitions(-D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE -D_LARGE_FILE_SOURCE)
add_executable(xdma-dma-to-device "${XDMA_TOOLS}/dma_to_device.c")
add_executable(xdma-dma-from-device "${XDMA_TOOLS}/dma_from_device.c")
add_executable(xdma-performance "${XDMA_TOOLS}/performance.c")

install(TARGETS
    xdma-reg-rw
    xdma-dma-to-device
    xdma-dma-from-device
    xdma-performance
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Create debian package containing dkms module, udev rules and xdma tools

set(CPACK_GENERATOR "DEB")
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Patrick Huesmann <patrick.huesmann@desy.de>")
set(CPACK_DEBIAN_PACKAGE_HOMEPAGE "https://github.com/MicroTCA-Tech-Lab/xdma-metapackage")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "dkms,udev")
set(CPACK_DEBIAN_PACKAGE_DESCRIPTION "Xilinx XDMA driver with added DKMS and udev support")
set(CPACK_DEBIAN_PACKAGE_SECTION "contrib/kernel")
set(CPACK_PACKAGE_NAME "xdma-dkms")
set(CPACK_PACKAGE_VERSION_MAJOR ${DRV_MOD_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${DRV_MOD_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${DRV_MOD_PATCHLEVEL})
set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA
    "${CMAKE_SOURCE_DIR}/debian/postinst;${CMAKE_SOURCE_DIR}/debian/prerm")
include(CPack)

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

set(XDMA_MAJOR_VERSION ${DRV_MOD_MAJOR})
set(XDMA_MINOR_VERSION ${DRV_MOD_MINOR})
set(XDMA_PATCH_VERSION ${DRV_MOD_PATCHLEVEL})

message("Detected XDMA driver version: ${XDMA_MAJOR_VERSION}.${XDMA_MINOR_VERSION}.${XDMA_PATCH_VERSION}")

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

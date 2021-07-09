cmake_minimum_required (VERSION 3.0.2)
Project(xdma-metapackage)

set(${PROJECT_NAME}_MAJOR_VERSION 00)
set(${PROJECT_NAME}_MINOR_VERSION 01)
set(${PROJECT_NAME}_PATCH_VERSION 00)

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

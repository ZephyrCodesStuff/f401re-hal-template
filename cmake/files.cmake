if(NOT BOARD_STARTUP_FILE)
    if(EXISTS "${BOARD_DIR}/startup.s")
        set(BOARD_STARTUP_FILE "${BOARD_DIR}/startup.s")
    elseif(EXISTS "${BOARD_DIR}/startup.S")
        set(BOARD_STARTUP_FILE "${BOARD_DIR}/startup.S")
    else()
        set(BOARD_STARTUP_FILE "${cmsis_device_SOURCE_DIR}/Source/Templates/gcc/startup_${MCU_STARTUP}.s")
    endif()
endif()

# Add sources to executable
target_sources(${PROJECT_NAME} PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/Src/syscall.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/Src/sysmem.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/Src/main.c"
    ${BOARD_STARTUP_FILE}
)

# Copy board linker script to build directory as flash.ld
configure_file("${BOARD_LINKER_SCRIPT}" "${CMAKE_CURRENT_BINARY_DIR}/flash.ld" COPYONLY)

set_target_properties(${PROJECT_NAME} PROPERTIES LINK_DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/flash.ld")

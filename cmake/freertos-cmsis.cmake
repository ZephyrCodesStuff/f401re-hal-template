# ==============================================================================
# CMSIS-RTOS v2 Adapter for FreeRTOS Kernel
# Provides standard CMSIS-RTOS2 APIs:
#   - osEventFlagsWait / osEventFlagsSet / osEventFlagsNew
#   - osThreadNew / osThreadTerminate / osThreadYield
#   - osDelay / osDelayUntil
#   - osMutex* / osSemaphore* / osMessageQueue*
# ==============================================================================

# Ensure underlying FreeRTOS kernel target exists first
if(NOT TARGET freertos_kernel)
    include(${CMAKE_CURRENT_LIST_DIR}/freertos.cmake)
endif()

include(FetchContent)

# Fetch ARM's official CMSIS-FreeRTOS wrapper containing cmsis_os2.c
# Tag v10.5.1 is aligned with CMSIS 5 (cmsis_core v5.6.0)
FetchContent_Declare(
    cmsis_freertos
    GIT_REPOSITORY https://github.com/ARM-software/CMSIS-FreeRTOS.git
    GIT_TAG        v10.5.1
    GIT_SHALLOW    TRUE
)

FetchContent_MakeAvailable(cmsis_freertos)

# Notify FreeRTOSConfig.h that CMSIS-RTOS2 is active (avoids duplicate SysTick_Handler)
target_compile_definitions(freertos_config INTERFACE
    USE_CMSIS_OS2
)

# Resolve device header name dynamically from board family
set(CMSIS_DEV_HDR "stm32${MCU_FAMILY}xx.h")

# Define CMSIS-RTOS2 library target
add_library(cmsis_os2 STATIC
    ${cmsis_freertos_SOURCE_DIR}/CMSIS/RTOS2/FreeRTOS/Source/cmsis_os2.c
    ${cmsis_freertos_SOURCE_DIR}/CMSIS/RTOS2/FreeRTOS/Source/os_systick.c
)

target_link_libraries(cmsis_os2 PUBLIC
    freertos_kernel
    freertos_config
    stm32_hal
)

target_include_directories(cmsis_os2 PUBLIC
    ${cmsis_freertos_SOURCE_DIR}/CMSIS/RTOS2/FreeRTOS/Include
    ${cmsis_core_SOURCE_DIR}/Include
    ${cmsis_core_SOURCE_DIR}/RTOS2/Include
    ${cmsis_device_SOURCE_DIR}/Include
    ${CMAKE_CURRENT_SOURCE_DIR}/Inc
)

target_compile_definitions(cmsis_os2 PUBLIC
    USE_HAL_DRIVER
    ${MCU_DEF}
    CMSIS_device_header="${CMSIS_DEV_HDR}"
)

target_compile_options(cmsis_os2 PUBLIC
    ${CPU_FLAGS}
)

# Automatically include the device header ONLY for cmsis_os2 (provides NVIC_SetPriority and SVCall_IRQn)
target_compile_options(cmsis_os2 PRIVATE
    -include ${CMSIS_DEV_HDR}
)

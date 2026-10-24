include(FetchContent)

# 1. Define the config interface target BEFORE fetching
# FreeRTOS-Kernel links against this target to find FreeRTOSConfig.h and flags
if(NOT TARGET freertos_config)
    add_library(freertos_config INTERFACE)
    target_include_directories(freertos_config INTERFACE
        ${CMAKE_CURRENT_SOURCE_DIR}/Inc
    )
    # Ensure FreeRTOS compiles with Cortex-M4F flags
    target_compile_options(freertos_config INTERFACE
        ${CPU_FLAGS}
    )
endif()

# 2. Select Port & Heap implementation
# For STM32F4 (Cortex-M4 with FPU) and ST-Clang / GCC:
set(FREERTOS_PORT "GCC_ARM_CM4F" CACHE STRING "FreeRTOS port" FORCE)
set(FREERTOS_HEAP "4"            CACHE STRING "FreeRTOS heap" FORCE)

# 3. Fetch FreeRTOS Kernel
FetchContent_Declare(
    freertos_kernel
    GIT_REPOSITORY https://github.com/FreeRTOS/FreeRTOS-Kernel.git
    GIT_TAG        V11.1.0
    GIT_SHALLOW    TRUE
)

FetchContent_MakeAvailable(freertos_kernel)
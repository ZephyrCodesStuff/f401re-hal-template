include(FetchContent)

# Set shallow clone to avoid downloading full git histories
set(FETCHCONTENT_QUIET FALSE)

# 1. ARM CMSIS Core
FetchContent_Declare(
    cmsis_core
    GIT_REPOSITORY https://github.com/STMicroelectronics/cmsis_core.git
    GIT_TAG        v5.6.0
    GIT_SHALLOW    TRUE
)

# 2. STM32F4 CMSIS Device
FetchContent_Declare(
    cmsis_device_f4
    GIT_REPOSITORY https://github.com/STMicroelectronics/cmsis_device_f4.git
    GIT_TAG        v2.6.9
    GIT_SHALLOW    TRUE
)

# 3. STM32F4 HAL Driver
FetchContent_Declare(
    stm32f4xx_hal_driver
    GIT_REPOSITORY https://github.com/STMicroelectronics/stm32f4xx_hal_driver.git
    GIT_TAG        v1.8.3
    GIT_SHALLOW    TRUE
)

FetchContent_MakeAvailable(cmsis_core cmsis_device_f4 stm32f4xx_hal_driver)

# Create a static library target for HAL & CMSIS
add_library(stm32f4_hal STATIC
    # CMSIS system initialization & SystemCoreClock
    ${cmsis_device_f4_SOURCE_DIR}/Source/Templates/system_stm32f4xx.c

    # Core HAL files
    ${stm32f4xx_hal_driver_SOURCE_DIR}/Src/stm32f4xx_hal.c
    ${stm32f4xx_hal_driver_SOURCE_DIR}/Src/stm32f4xx_hal_cortex.c
    ${stm32f4xx_hal_driver_SOURCE_DIR}/Src/stm32f4xx_hal_rcc.c
    ${stm32f4xx_hal_driver_SOURCE_DIR}/Src/stm32f4xx_hal_rcc_ex.c
    ${stm32f4xx_hal_driver_SOURCE_DIR}/Src/stm32f4xx_hal_pwr.c
    ${stm32f4xx_hal_driver_SOURCE_DIR}/Src/stm32f4xx_hal_pwr_ex.c
    ${stm32f4xx_hal_driver_SOURCE_DIR}/Src/stm32f4xx_hal_gpio.c
    # Add other peripherals as needed (uart, dma, tim, spi, etc.)
)

target_include_directories(stm32f4_hal PUBLIC
    ${cmsis_core_SOURCE_DIR}/Include
    ${cmsis_device_f4_SOURCE_DIR}/Include
    ${stm32f4xx_hal_driver_SOURCE_DIR}/Inc
    ${CMAKE_CURRENT_SOURCE_DIR}/Inc   # Where your stm32f4xx_hal_conf.h lives
)

target_compile_definitions(stm32f4_hal PUBLIC
    USE_HAL_DRIVER
    STM32F401xE   # Nucleo-F401RE chip series definition
)

target_compile_options(stm32f4_hal PUBLIC
    ${CPU_FLAGS}
)
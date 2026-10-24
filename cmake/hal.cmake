include(FetchContent)

# Set shallow clone to avoid downloading full git histories
set(FETCHCONTENT_QUIET FALSE)

# 1. ARM CMSIS Core (Common to both Cortex-M4 targets)
FetchContent_Declare(
    cmsis_core
    GIT_REPOSITORY https://github.com/STMicroelectronics/cmsis_core.git
    GIT_TAG        v5.6.0
    GIT_SHALLOW    TRUE
)

# 2. Family-specific CMSIS Device & HAL Drivers
if(TARGET_MCU STREQUAL "STM32G491RE")
    set(MCU_DEF "STM32G491xx")
    set(LINKER_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/stm32g491xe_flash.ld")

    FetchContent_Declare(
        cmsis_device
        GIT_REPOSITORY https://github.com/STMicroelectronics/cmsis_device_g4.git
        GIT_TAG        v1.2.3
        GIT_SHALLOW    TRUE
    )

    FetchContent_Declare(
        hal_driver
        GIT_REPOSITORY https://github.com/STMicroelectronics/stm32g4xx_hal_driver.git
        GIT_TAG        v1.2.3
        GIT_SHALLOW    TRUE
    )

    FetchContent_MakeAvailable(cmsis_core cmsis_device hal_driver)

    set(HAL_SOURCES
        ${cmsis_device_SOURCE_DIR}/Source/Templates/system_stm32g4xx.c
        ${hal_driver_SOURCE_DIR}/Src/stm32g4xx_hal.c
        ${hal_driver_SOURCE_DIR}/Src/stm32g4xx_hal_cortex.c
        ${hal_driver_SOURCE_DIR}/Src/stm32g4xx_hal_rcc.c
        ${hal_driver_SOURCE_DIR}/Src/stm32g4xx_hal_rcc_ex.c
        ${hal_driver_SOURCE_DIR}/Src/stm32g4xx_hal_pwr.c
        ${hal_driver_SOURCE_DIR}/Src/stm32g4xx_hal_pwr_ex.c
        ${hal_driver_SOURCE_DIR}/Src/stm32g4xx_hal_gpio.c
    )

    # Swap F401 startup with G491 startup in the executable
    get_target_property(_CURRENT_SRCS ${PROJECT_NAME} SOURCES)
    list(FILTER _CURRENT_SRCS EXCLUDE REGEX "startup_stm32f401xx")
    set_target_properties(${PROJECT_NAME} PROPERTIES SOURCES "${_CURRENT_SRCS}")
    target_sources(${PROJECT_NAME} PRIVATE
        ${cmsis_device_SOURCE_DIR}/Source/Templates/gcc/startup_stm32g491xx.s
    )

    # Copy G4 linker script over the destination expected by flags.cmake
    configure_file("${LINKER_SCRIPT}" "${CMAKE_CURRENT_BINARY_DIR}/stm32f401xe_flash.ld" COPYONLY)

else() # Default: STM32F401RE
    set(MCU_DEF "STM32F401xE")
    set(LINKER_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/stm32f401xe_flash.ld")

    FetchContent_Declare(
        cmsis_device
        GIT_REPOSITORY https://github.com/STMicroelectronics/cmsis_device_f4.git
        GIT_TAG        v2.6.9
        GIT_SHALLOW    TRUE
    )

    FetchContent_Declare(
        hal_driver
        GIT_REPOSITORY https://github.com/STMicroelectronics/stm32f4xx_hal_driver.git
        GIT_TAG        v1.8.3
        GIT_SHALLOW    TRUE
    )

    FetchContent_MakeAvailable(cmsis_core cmsis_device hal_driver)

    set(HAL_SOURCES
        ${cmsis_device_SOURCE_DIR}/Source/Templates/system_stm32f4xx.c
        ${hal_driver_SOURCE_DIR}/Src/stm32f4xx_hal.c
        ${hal_driver_SOURCE_DIR}/Src/stm32f4xx_hal_cortex.c
        ${hal_driver_SOURCE_DIR}/Src/stm32f4xx_hal_rcc.c
        ${hal_driver_SOURCE_DIR}/Src/stm32f4xx_hal_rcc_ex.c
        ${hal_driver_SOURCE_DIR}/Src/stm32f4xx_hal_pwr.c
        ${hal_driver_SOURCE_DIR}/Src/stm32f4xx_hal_pwr_ex.c
        ${hal_driver_SOURCE_DIR}/Src/stm32f4xx_hal_gpio.c
    )
endif()

# 3. Create the unified HAL library
add_library(stm32_hal STATIC
    ${HAL_SOURCES}
)

# Compatibility alias
add_library(stm32f4_hal ALIAS stm32_hal)

target_include_directories(stm32_hal PUBLIC
    ${cmsis_core_SOURCE_DIR}/Include
    ${cmsis_device_SOURCE_DIR}/Include
    ${hal_driver_SOURCE_DIR}/Inc
    ${CMAKE_CURRENT_SOURCE_DIR}/Inc
)

target_compile_definitions(stm32_hal PUBLIC
    USE_HAL_DRIVER
    ${MCU_DEF}
)

target_compile_options(stm32_hal PUBLIC
    ${CPU_FLAGS}
)

# Pass the MCU definition to the application executable
target_compile_definitions(${PROJECT_NAME} PUBLIC
    USE_HAL_DRIVER
    ${MCU_DEF}
)

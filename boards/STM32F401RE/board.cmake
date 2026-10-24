# ==============================================================================
# Board Configuration: STM32F401RE
# ==============================================================================
set(BOARD_NAME       "STM32F401RE")
set(MCU_MODEL        "STM32F401RET6")
set(MCU_FAMILY       "f4")
set(MCU_FAMILY_UPPER "STM32F4")
set(MCU_DEF          "STM32F401xE")
set(MCU_CORE         "Cortex-M4")
set(MCU_FPU          "SP_FPU")
set(MCU_DSP          "DSP")
set(MCU_STARTUP      "stm32f401xe")

# CMSIS Device and HAL Driver repository tags
set(CMSIS_DEVICE_TAG "v2.6.9")
set(HAL_DRIVER_TAG   "v1.8.3")

# Hardware Debugger / Flasher configuration
set(PROBE_CHIP       "STM32F401RETx")
set(OPENOCD_TARGET   "target/stm32f4x.cfg")

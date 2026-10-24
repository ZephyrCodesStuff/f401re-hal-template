# ==============================================================================
# Board Configuration: STM32G491RE
# ==============================================================================
set(BOARD_NAME       "STM32G491RE")
set(MCU_MODEL        "STM32G491RET6")
set(MCU_FAMILY       "g4")
set(MCU_FAMILY_UPPER "STM32G4")
set(MCU_DEF          "STM32G491xx")
set(MCU_CORE         "Cortex-M4")
set(MCU_FPU          "SP_FPU")
set(MCU_DSP          "DSP")
set(MCU_STARTUP      "stm32g491xx")

# CMSIS Device and HAL Driver repository tags
set(CMSIS_DEVICE_TAG "v1.2.3")
set(HAL_DRIVER_TAG   "v1.2.3")

# Hardware Debugger / Flasher configuration
set(PROBE_CHIP       "STM32G491RETx")
set(OPENOCD_TARGET   "target/stm32g4x.cfg")

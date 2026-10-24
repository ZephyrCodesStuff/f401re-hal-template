# Target definitions derived from active board configuration
set(CMSIS_Dvendor "STMicroelectronics:13")
set(CMSIS_Dname "${MCU_MODEL}")
set(CMSIS_Dcore "${MCU_CORE}")
set(CMSIS_Dfpu "${MCU_FPU}")
set(CMSIS_Ddsp "${MCU_DSP}")
set(CMSIS_Dmve "NO_MVE")
set(CMSIS_Dendian "Little-endian")
set(CMSIS_Tcompiler "CLANG")

# Set target definition variables needed for the TOOLCHAIN_FILE
set(CPU "${CMSIS_Dcore}")
set(FPU "${CMSIS_Dfpu}")
set(DSP "${CMSIS_Ddsp}")
set(MVE "${CMSIS_Dmve}")

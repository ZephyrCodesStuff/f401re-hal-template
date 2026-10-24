#ifndef STM32_HAL_H
#define STM32_HAL_H

#ifdef STM32_HAL_HEADER
    #include STM32_HAL_HEADER
#else
    #error "STM32_HAL_HEADER is not defined. Please verify your board configuration in boards/<TARGET>/board.cmake"
#endif

#endif /* STM32_HAL_H */

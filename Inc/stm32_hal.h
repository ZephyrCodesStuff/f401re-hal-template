#ifndef STM32_HAL_H
#define STM32_HAL_H

#if defined(STM32F401xE)
    #include "stm32f4xx_hal.h"
#elif defined(STM32G491xx)
    #include "stm32g4xx_hal.h"
#else
    #error "Unknown or unspecified STM32 target MCU! Define STM32F401xE or STM32G491xx."
#endif

#endif /* STM32_HAL_H */

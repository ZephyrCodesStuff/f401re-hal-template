#ifndef FREERTOS_CONFIG_H
#define FREERTOS_CONFIG_H

#include <stdint.h>

extern uint32_t SystemCoreClock;

#define configUSE_PREEMPTION 1
#define configUSE_PORT_OPTIMISED_TASK_SELECTION 0
#define configUSE_TICKLESS_IDLE 0
#define configCPU_CLOCK_HZ ( SystemCoreClock )
#define configTICK_RATE_HZ ( (TickType_t)1000 )
#define configMAX_PRIORITIES ( 56 )
#define configMINIMAL_STACK_SIZE ( (uint16_t)128 )
#define configTOTAL_HEAP_SIZE ( (size_t)( 16 * 1024 ) )
#define configMAX_TASK_NAME_LEN ( 16 )
#define configUSE_16_BIT_TICKS 0
#define configIDLE_SHOULD_YIELD 1
#define configUSE_TASK_NOTIFICATIONS 1
#define configUSE_MUTEXES 1
#define configUSE_RECURSIVE_MUTEXES 1
#define configUSE_COUNTING_SEMAPHORES 1
#define configUSE_TIME_SLICING 1
#define configUSE_TRACE_FACILITY 1

/* Hook function configs */
#define configUSE_IDLE_HOOK 0
#define configUSE_TICK_HOOK 1 /* Used to tick STM32 HAL */
#define configCHECK_FOR_STACK_OVERFLOW 0
#define configUSE_MALLOC_FAILED_HOOK 0

/* Software timer definitions */
#define configUSE_TIMERS 1
#define configTIMER_TASK_PRIORITY ( 2 )
#define configTIMER_QUEUE_LENGTH 10
#define configTIMER_TASK_STACK_DEPTH ( configMINIMAL_STACK_SIZE * 2 )

/* Cortex-M specific definitions */
#ifdef __NVIC_PRIO_BITS
    #define configPRIO_BITS __NVIC_PRIO_BITS
#else
    #define configPRIO_BITS 4
#endif

/* Lowest priority is 15, Syscall priority is 5 */
#define configLIBRARY_LOWEST_INTERRUPT_PRIORITY 15
#define configLIBRARY_MAX_SYSCALL_INTERRUPT_PRIORITY 5

#define configKERNEL_INTERRUPT_PRIORITY \
    ( configLIBRARY_LOWEST_INTERRUPT_PRIORITY << ( 8 - configPRIO_BITS ) )
#define configMAX_SYSCALL_INTERRUPT_PRIORITY \
    ( configLIBRARY_MAX_SYSCALL_INTERRUPT_PRIORITY << ( 8 - configPRIO_BITS ) )

/* Map FreeRTOS interrupt handlers to Cortex-M vector table names */
#define vPortSVCHandler SVC_Handler
#define xPortPendSVHandler PendSV_Handler

/* In CMSIS-RTOS2, cmsis_os2.c implements SysTick_Handler and calls xPortSysTickHandler().
   In pure FreeRTOS, port.c maps directly to SysTick_Handler. */
#if !defined(USE_CMSIS_OS2)
#define xPortSysTickHandler SysTick_Handler
#endif

/* Set the following definitions to 1 to include the API function, or zero to exclude it */
#define INCLUDE_vTaskPrioritySet             1
#define INCLUDE_uxTaskPriorityGet            1
#define INCLUDE_vTaskDelete                  1
#define INCLUDE_vTaskCleanUpResources        0
#define INCLUDE_vTaskSuspend                 1
#define INCLUDE_vTaskDelayUntil              1
#define INCLUDE_vTaskDelay                   1
#define INCLUDE_xTaskGetSchedulerState       1
#define INCLUDE_xTaskGetCurrentTaskHandle    1
#define INCLUDE_uxTaskGetStackHighWaterMark  1
#define INCLUDE_xSemaphoreGetMutexHolder     1
#define INCLUDE_eTaskGetState                1
#define INCLUDE_xTaskAbortDelay              1
#define INCLUDE_xTimerPendFunctionCall       1

/* CMSIS Device Header Mapping for CMSIS-RTOS2 */
#if defined(STM32F401xE)
  #define CMSIS_device_header "stm32f4xx.h"
#elif defined(STM32G491xx)
  #define CMSIS_device_header "stm32g4xx.h"
#endif

#endif /* FREERTOS_CONFIG_H */

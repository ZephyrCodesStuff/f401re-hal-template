#include "FreeRTOS.h"
#include "cmsis_os2.h"
#include "stm32_hal.h"
#include "task.h"

/* FreeRTOS calls this every 1ms SysTick interrupt */
void vApplicationTickHook( void )
{ HAL_IncTick(); }

static void BlinkTask( void* pvParameters )
{
    (void)pvParameters;
    for ( ;; )
    {
        HAL_GPIO_TogglePin( GPIOA, GPIO_PIN_5 );
        vTaskDelay( pdMS_TO_TICKS( 500 ) );
    }
}

int main( void )
{
    HAL_Init();
    __HAL_RCC_GPIOA_CLK_ENABLE();

    GPIO_InitTypeDef gpio = { .Pin = GPIO_PIN_5,
                              .Mode = GPIO_MODE_OUTPUT_PP,
                              .Pull = GPIO_NOPULL,
                              .Speed = GPIO_SPEED_FREQ_LOW };
    HAL_GPIO_Init( GPIOA, &gpio );

    xTaskCreate( BlinkTask, "Blink", 128, NULL, 1, NULL );

    uint32_t res = osEventFlagsWait( NULL, 0x01, osFlagsWaitAny, 0 );
    (void)res;

    vTaskStartScheduler();

    while ( 1 ) {}
}

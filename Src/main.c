#include "FreeRTOS.h"
#include "stm32f4xx_hal.h"
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
        vTaskDelay( pdMS_TO_TICKS( 2500 ) );
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

    vTaskStartScheduler();

    while ( 1 ) {}
}

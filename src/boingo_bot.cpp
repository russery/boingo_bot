#include "stm32f30x.h"
#include "stm32f30x_it.h"
#include <stdio.h>

int main(void) {
    while(1);
}

#ifdef  USE_FULL_ASSERT
void assert_failed(uint8_t* file, uint32_t line)
{ 
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  while (1);
}
#endif

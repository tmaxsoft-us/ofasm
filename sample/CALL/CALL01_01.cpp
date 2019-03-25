#include <stdio.h>

extern "C"{

extern int CALL01_01(char* input)
{
   printf("%s\n", input);
   return 0;
}

}

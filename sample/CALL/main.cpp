#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern "C"
{
    extern int CALL01(char* str);
}

int main(){
    char str[30];
    strcpy(str, "HELLO NATIVE");

    printf("%s\n", str);
    CALL01(str);
    printf("%s\n", str);
   
    return 0;
}


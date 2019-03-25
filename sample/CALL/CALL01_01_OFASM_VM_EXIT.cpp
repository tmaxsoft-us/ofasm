#include <stdlib.h>
#include <string.h>
#include <arpa/inet.h>

extern "C"
{

extern int CALL01_01(char* str);

int CALL01_01_OFASM_VM_EXIT(char* str)
{
    /* call VM */
    int rc = CALL01_01(str);
    return rc;
}

}

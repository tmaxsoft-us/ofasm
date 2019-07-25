# Chapter 1. OFASM interface

This chapter covers the definition of the OFASM interface and describes how to create it on different situations.  

## Section 1. Definition of OFASM interface  

OFASM binary has its own binary format (.asmo) which isn't compatible with the Linux native binary format (.so). Thus, it is impossible to directly call or load among a program in OFASM binary format and one in native binary format. To make the call or load among them, appropriate OFASM interface is required. 

There are three types of OFASM interface.  

1. OFASM_VM_ENTRY  
  
    - This type of interface is used in case the native program directly calls OFASM program.  
    - Naming conventions of OFASM_VM_ENTRY
        - cpp naming convension: PGM_OFASM_VM_ENTRY.cpp
        - so naming convension : PGM.so  

    ![interface_ofasm_vm_entry](interface_ofasm_vm_entry.png)

1. OFASM_VM_EXIT

    - This type of interface is used in case OFASM program directly calls the native program 
    - Naming conventions of OFASM_VM_EXIT
        - cpp naming convension: PGM_OFASM_VM_EXIT.cpp
        - so naming convension : PGM_OFASM_VM_EXIT.so  

    ![interface_ofasm_vm_exit](interface_ofasm_vm_exit.png)  

1. OFASM_VM_LOAD

    - This type of interface is used in case the native program uses EXTC CICS LOAD command.  
    - Naming conventions of OFASM_VM_LOAD
        - cpp naming convension: PGM_OFASM_VM_LOAD.cpp
        - so naming convension : PGM_OFASM_VM_LOAD.so  
    ![interface_ofasm_vm_load](interface_ofasm_vm_load.png)

> **NOTE: The name of the given program(OFASM) must be defined in the online System Definition (SD) as ASSEMBLER to use OFASM_VM_LOAD interface**  

## Section 2. Iplementation of OFASM interface  

This section demonstrates how to implement the OFASM interfaces.

### 1. OFASM_VM_ENTRY  

OFASM_VM_ENTRY interface supports static and dynamic parameter list.  

#### 1.1. Static parameter list (fixed parameter list)  

For static parameter list, the parameter information gets fixed in compile time.
In this case, the number of the parameters and byte length of each parameter need to be defined manually.

Example. Static parameter list with one parameter which is 30 bytes long.

```cpp
#include <stdlib.h>
#include <string.h>
#include <arpa/inet.h>

struct ofasm_param
{
    long long length;
    long long elemCnt;
    char *addr;
    char *elemListAddr;
};

extern int OFASM_VM_ENTRY(const char *progName, ofasm_param param[], int paramCnt); // DEPRECATED
extern int OFASM_VM_ENTRY(const char *progName, const char *entryName, ofasm_param param[], int paramCnt);

extern "C"
{

extern int ofcom_call_parm_get(int index, char* func_name, int *count, int **size_list);

/** @fn       int PGM(char *p0)
*   @brief    Enter OFASM VM entry method
*   @details  Make up ofasm parameters and then enter OFASM VM entry using entry name
*   @params   p0 0th parameter in PLIST
*/
int PGM(char *p0)
{
    /* declare local arguments */
    int rc;
    int paramCnt;
    ofasm_param param[1];

    /* set params */
    param[0].length = 30;
    param[0].addr = p0;
    param[0].elemListAddr = NULL;
    param[0].elemCnt = 0;

    /* set param count */
    paramCnt = 1;

    /* call VM */
    rc = OFASM_VM_ENTRY("PGM", "PGM", param, paramCnt);
    return rc;
}

}
```

#### 1.2. Dynamic parameter list (variable parameter list)  

The dynamic parameter list sets the parameter information at runtime based on the information from ofcom_call_parm_get() function. Please note that the ofcom_call_parm_push() function must be issued before calling the callee program to store the parameter information and ofcom_call_parm_pop() function needs to be executed after returning from the callee to free the parameter information. These push & pop functions are automatically added when the option '--enable-ofasm' is used in OFCOBOL or OFPLI compiler. In other compilers, the push & pop functions may need to be manually added.

Example. Dynamic parameter list with maximum 10 parameters

```cpp
#include <stdlib.h>
#include <string.h>
#include <arpa/inet.h>

struct ofasm_param
{
    long long length;
    long long elemCnt;
    char *addr;
    char *elemListAddr;
};

extern int OFASM_VM_ENTRY(const char *progName, ofasm_param param[], int paramCnt); // DEPRECATED
extern int OFASM_VM_ENTRY(const char *progName, const char *entryName, ofasm_param param[], int paramCnt);

extern "C"
{

extern int ofcom_call_parm_get(int index, char* func_name, int *count, int **size_list);

/** @fn       int PGM(char* p0, char* p1, char* p2, char* p3, char* p4, char* p5, char* p6, char* p7, char* p8, char *p9)
*   @brief    Enter OFASM VM entry method
*   @details  Make up ofasm parameters and then enter OFASM VM entry using entry name
*   @params   p0 0th parameter in PLIST
*   @params   p1 1st parameter in PLIST
*   @params   p2 2nd parameter in PLIST
*   @params   p3 3rd parameter in PLIST
*   @params   p4 4th parameter in PLIST
*   @params   p5 5th parameter in PLIST
*   @params   p6 6th parameter in PLIST
*   @params   p7 7th parameter in PLIST
*   @params   p8 8th parameter in PLIST
*   @params   p9 9th parameter in PLIST
*/
int PGM(char *p0, char *p1, char *p2, char *p3, char *p4, char *p5, char *p6, char *p7, char *p8, char *p9)
{
    /* declare local arguments */
    int rc;
    int paramCnt;
    char prgName[64] = {0};
    int *sizeList;
    ofasm_param param[10];

    /* initiallize parameter */
    for(int i = 0; i < 10; i++)
    {
        param[i].addr = NULL;
        param[i].length = 0;
        param[i].elemListAddr = NULL;
        param[i].elemCnt = 0;
    }

    /* set variable parameter*/
    ofcom_call_parm_get(0, prgName, &paramCnt, &sizeList);

    param[0].addr = p0;
    param[1].addr = p1;
    param[2].addr = p2;
    param[3].addr = p3;
    param[4].addr = p4;
    param[5].addr = p5;
    param[6].addr = p6;
    param[7].addr = p7;
    param[8].addr = p8;
    param[9].addr = p9;

    for(int i = 0; i < paramCnt; i++)
    {
        param[i].length = sizeList[i];
    }
    /* call VM */
    rc = OFASM_VM_ENTRY("PGM", "PGM", param, paramCnt);
    return rc;
}

}
```

### 2. OFASM_VM_EXIT

OFASM_VM_EXIT interface needs to define the number of parameters being passed to the native program.

Example. OFASM_VM_EXIT interface without parameter

```cpp
#include <stdlib.h>
#include <string.h>
#include <arpa/inet.h>

extern "C"
{

extern int PGM();

int PGM_OFASM_VM_EXIT()
{
    /* call VM */
    int rc = PGM();
    return rc;
}

}
```

Example. OFASM_VM_EXIT interface with 3 parameters

```cpp
#include <stdlib.h>
#include <string.h>
#include <arpa/inet.h>

extern "C"
{

extern int PGM(char* p0, char* p1, char* p2);

int PGM_OFASM_VM_EXIT(char* p0, char* p1, char* p2)
{
    /* call VM */
    int rc = PGM(p0, p1, p2);
    return rc;
}

}
```

### 3. OFASM_VM_LOAD

OFASM_VM_LOAD requires below two functions.  

1. PGM_OFASM_VM_LOAD_SIZE() is for the returning byte size of the loaded assembler program. 
2. PGM_OFASM_VM_LOAD_COPY() is for the loading the assembler program into native memory.

Example. OFASM_VM_LOAD interface

```cpp
#include <stdlib.h>
#include <string.h>
#include <arpa/inet.h>
#include <stdio.h>

extern "C"
{

int PGM_OFASM_VM_LOAD_SIZE(int asm_size)
{
    return asm_size;
}

int PGM_OFASM_VM_LOAD_COPY(char *asm_ptr, char *cob_ptr, int asm_size)
{
    memcpy(cob_ptr, asm_ptr, asm_size);
    return 0;
}

}
```

## Section 3. Handling pointer type parameter

Handling pointer type parameter in OFASM interface can be very tricky.
Since the OFASM VM uses it's own virtualized memory, you need to convert the address value between native and OFASM memory in runtime.
Also, you need to consider the byte size difference when running the program in the 64-bit system.

### 1. OFASM_VM_ENTRY

Consider below COBOL program which passes a parameter to a assembler program while having a pointer variable in the parameter.

```cobol
       01  PGM-COMAREA.
           03  PGM-FUNCTION-REQUEST-CODE                  PIC X.
               88  PGM-BUILD-FUNCTION              VALUE  'B'.
               88  PGM-LOCATE-FUNCTION             VALUE  'L'.
           03  PGM-RETURN-CODE                            PIC X.
               88  PGM-RETURN-OK                   VALUE  SPACE.
               88  PGM-RETURN-DUPE                 VALUE  'D'.
               88  PGM-RETURN-NOT-FOUND            VALUE  'N'.
               88  PGM-RETURN-STORAGE-FAIL         VALUE  'S'.
               88  PGM-RETURN-INVALID-REQ          VALUE  'I'.
           03  PGM-TABLE-ENTRY-SIZE                COMP   PIC 9(4).
           03  PGM-TABLE-ENTRY-POINTER             USAGE POINTER.
           03  PGM-ITEM-NO                         COMP-3 PIC 9(5).
           03  PGM-HIGH-VALID-ITEM                 COMP-3 PIC 9(5).
...
           CALL 'PGM' USING BY REFERENCE PGM-COMAREA.
```

To create an OFASM_VM_ENTRY interface on this case, you first have to define two structures which are the views on the parameter from the COBOL and the assembler.
In this particular example, PGM_P0_ASM is representing the view from the assembler and PGM_P0_COB is the view from the COBOL.  

```cpp
struct  __attribute__((packed)) PGM_P0_ASM
{
    uint8_t  tabreqcd;
    uint8_t  tabretcd;
    uint16_t tabsize;
    uint32_t tabeaddr;
    uint32_t tabitemno;
    uint32_t tabhvalitem;
};

struct  __attribute__((packed)) PGM_P0_COB
{
    uint8_t  tabreqcd;
    uint8_t  tabretcd;
    uint16_t tabsize;
    char*    tabeaddr;
    uint32_t tabitemno;
    uint32_t tabhvalitem;
};
```
  
The next step is to push & pop parameter information by using OFASM_PUSH_PARM & OFASM_POP_PARM function before and after the calling the OFASM VM.
Please note that the OFASM_PUSH_PARM & OFASM_POP_PARM function is used to push & pop pointer parameter information to OFASM VM. Please refer to PGM_P0_OFASM_PUSH & PGM_P0_OFASM_POP implemented in below code.

```cpp
int PGM_P0_OFASM_PUSH(PGM_P0_ASM* p0_asm, PGM_P0_COB* p0_cob)
{
    p0_asm->tabreqcd    = p0_cob->tabreqcd;
    p0_asm->tabretcd    = p0_cob->tabretcd;
    p0_asm->tabsize     = p0_cob->tabsize;
    p0_asm->tabeaddr    = htonl(OFASM_PUSH_PARAM(p0_cob->tabeaddr, htonl(p0_cob->tabsize)));
    p0_asm->tabitemno   = p0_cob->tabitemno;
    p0_asm->tabhvalitem = p0_cob->tabhvalitem;

    return 0;
}

int PGM_P0_OFASM_POP(PGM_P0_ASM* p0_asm, PGM_P0_COB* p0_cob)
{
    p0_cob->tabreqcd    = p0_asm->tabreqcd;
    p0_cob->tabretcd    = p0_asm->tabretcd;
    p0_cob->tabsize     = p0_asm->tabsize;
    p0_cob->tabeaddr    = OFASM_POP_PARAM(htonl(p0_asm->tabeaddr));
    p0_cob->tabitemno   = p0_asm->tabitemno;
    p0_cob->tabhvalitem = p0_asm->tabhvalitem;

    return 0;
}

extern "C"
{

extern int ofcom_call_parm_get(int index, char* func_name, int *count, int **size_list);

int PGM(char *p0, char *p1)
{
    /* declare local arguments */
    int rc;
    int paramCnt = 1;
    char prgName[64] = {0};
    int* sizeList;
    ofasm_param param[2];
    PGM_P0_ASM  p0_asm;
    PGM_P0_COB* p0_cob = (PGM_P0_COB*) p0;

    /* push parameter */
    PGM_P0_OFASM_PUSH(&p0_asm, p0_cob);

    param[0].addr = (char*) &p0_asm;
    param[0].length = sizeof(PGM_P0_ASM);
    param[0].elemCnt = 0;
    param[0].elemListAddr = NULL;

    /* call VM */
    rc = OFASM_VM_ENTRY("PGM", "PGM", param, paramCnt);

    /* pop parameter */
    PGM_P0_OFASM_POP(&p0_asm, p0_cob);

    return rc;
}

}
```

### 2. OFASM_VM_EXIT

Pointer type parameter for OFASM_VM_EXIT is not yet supported.  

### 3. OFASM_VM_LOAD

In below example, there is a pointer at the front of the assembler program which points the DATA in the program.

```asm
PGM      CSECT
         DC    A(DATA)    ADDRESS OF FIRST ENTRY
         DC    F'0'       FILLER
DATA     DC    CL256'SOME DATA'
```

Just like other type of interface which have a pointer, you first need to define two views of the memory, native and assembler.

```cpp
/**
 * @brief The PGM_STRUCT_ASM struct (assembler program's view on PGM)
 */
struct __attribute__((packed)) PGM_STRUCT_ASM {
    uint32_t  addr;
    uint32_t  filler;
    uint8_t   data[256];
};

/**
 * @brief The PGM_STRUCT_COB struct (cobol program's view on PGM)
 */
struct __attribute__((packed)) PGM_STRUCT_COB {
    uint8_t*  addr;
    uint32_t  filler;
    uint8_t   data[256];
};
```

Now you need to adjust the program size in PGM_OFASM_VM_LOAD_SIZE function when you use 64-bit system. For the last, you need to build the native memory from the OFASM VM memory by implementing PGM_OFASM_VM_LOAD_COPY function.

```cpp
#include <stdlib.h>
#include <string.h>
#include <arpa/inet.h>
#include <stdio.h>

extern "C"
{

/**
 ** @brief PGM_OFASM_VM_LOAD_SIZE adjust native memory size
 ** @return byte size of PGM in native system view
 **/
int PGM_OFASM_VM_LOAD_SIZE(int asm_size)
{
    int ptr_cnt = 1;
    return asm_size + ( (sizeof(char*) - 4) * ptr_cnt );
}

/**
 ** @brief PGM_OFASM_VM_LOAD_COPY adjust native memory contents
 ** @param asm_ptr address of PGM assembler
 ** @param cob_ptr address of PGM cobol
 ** @param asm_size byte size of PGM.asm
 ** @return 0: success, -1: error
 **/
int PGM_OFASM_VM_LOAD_COPY(char *asm_ptr, char *cob_ptr, int asm_size)
{
    /* handle pointers */
    PGM_STRUCT_COB* struct_cob_ptr = (PGM_STRUCT_COB*) cob_ptr;
    struct_cob_ptr->addr   = &(struct_cob_ptr->first);

    /* handle non-pointers */
    memcpy( ((char*)cob_ptr) + sizeof(char*), ((char*)asm_ptr) + 4 , asm_size - 4);
    return 0;
}

}
```

## Section 4. Using ofasmif to generate OFASM interface

You can generate OFASM_VM_ENTRY interface file using ofasmif tool. ofasmif requires JSON formatted input which is described below.

```json
{
    "entry_list":[
    {
        "entry_name" : "ENTRYNAME1",
        "fixed_parameter_list" : [
        {
            "param_size" : (PARASIZE),
            "param_type" : (PARATYPE)
        },]
    },
    {
        "entry_name" : "ENTRYNAME2",
        "variable_parameter_list" : 
        {    
            "max_length" : (MAXLEN)
        }
    }],
    "program_name" : "PROGNAME",
    "version" : 3
}
```

1. "entry_list": JSONLIST
    - This json list will have an array of json object which describes the entry
    - each entry will contain the name of the entry and the parameter list information
2. "entry_name" : STRING
    - This value must match with the entry point name in the assembler program
3. "fixed_parameter_list": JSONLIST
    - This json list will have an arrary of static or fixed parameter type json object
4. "param_type" : STRING (F) or (V)
    - F: fixed length parameter
    - V: variable length parameter. This type is used when an assembler program is called by the JCL
5. "param_size" : INTEGER
    - define the byte size of the parameter
    - this is used when fixed length parameter is being used
6. "variable_parameter_list" : JSONOBJECT
    - This option allows dynamic or variable parameter list.
    - This is only available with the OFCOBOL or OFPLI is being used and having --enable-ofasm option at compile time.
7. "max_length" : INTEGER
    - Defines the maximum number of parameter can be passed to the OFASM VM.
    - This is only used in variable parameter list
8. "program_name" : STRING
    - This value must match with the name of the asmo object
9. "version" : INTEGER (3)
    - Defines the input json format version for ofasmif

After creating the JSON file, you can use below command to generate the interface file.

```bash
ofasmif -i PGM.json
```



## Section 5. Compiling the interface file

### 1. OFASM_VM_ENTRY

```bash
g++ -shared -fPIC -o PGM.so PGM_OFASM_VM_ENTRY.cpp -L$OFASM_HOME/lib -lofasmVM
```

### 2. OFASM_VM_EXIT

```bash
g++ -shared -fPIC -o PGM_OFASM_VM_EXIT.so PGM_OFASM_VM_EXIT.cpp -L$OFASM_HOME/lib -lofasmVM
```

### 3. OFASM_VM_LOAD

```bash
g++ -shared -fPIC -o PGM_OFASM_VM_LOAD.so PGM_OFASM_VM_LOAD.cpp -L$OFASM_HOME/lib -lofasmVM
```

## Section 6. Reference

1. Native -> OFASM -> Native call
    - https://github.com/tmaxsoft-us/ofasm/tree/master/sample/CALL

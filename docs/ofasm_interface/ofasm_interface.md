# Chapter: OFASM interface

This chapter covers the definition of the OFASM interface and how can create and use the OFASM interface for multiple situations.

## Section 1. Definition of OFASM interface

OFASM binary has it's own binary format (.asmo) and therefore not compatible with the linux native binary (.so). Due to this fact, it is impossible to directly call between programs which are in OFASM binary format and native binary format.  

There are three different types of OFASM interface

1. OFASM_VM_ENTRY
2. OFASM_VM_EXIT
3. OFASM_VM_LOAD

### 1. OFASM_VM_ENTRY

OFASM_VM_ENTRY interface enables the call from native program to OFASM program.  

1. Provides a callable symbol for native program to call a OFASM program
2. Pass parameters to a OFASM program

![ofasm_interface_architecture](ofasm_interface_architecture.png)

### 2. OFASM_VM_EXIT

OFASM_VM_EXIT interface supports the call from OFASM program to native program.  

### 3. OFASM_VM_LOAD

OFASM_VM_LOAD interface is for EXEC CICS LOAD command used in native program.  

## Section 2. Implementing OFASM interface

## Section 3. Generating OFASM interface using JSON manifest file

## Section 4. Examples

### OFASM_VM_ENTRY

### OFASM_VM_EXIT

### OFASM_VM_LOAD

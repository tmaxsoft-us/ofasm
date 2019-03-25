CALL01   CSECT
         LR     12,15
         USING  CALL01,12
         ST     14,SAVE
         L      2,0(1)
         USING  PARAM,2
         MVC    0(30,2),HELLO
         ST     2,PLIST
         OC     PLIST,=X'80000000'
         LA     1,PLIST
         CALL   CALL01_01
         L      14,SAVE
         BR     14
SAVE     DS     F
PLIST    DC     A(0)
HELLO    DC     CL29'HELLO ASM'
         DC     X'00'
*
PARAM    DSECT
PARAM1   DS    CL30
         END

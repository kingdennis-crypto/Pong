DATA SEGMENT
        MSG DB "Hello, World!", "$" ; DB: Define byte, $: Terminates the string
DATA ENDS

CODE SEGMENT
        ASSUME CS:CODE, DS:DATA
        ; INIT SEGMENT REGS
        START:
                MOV AX, DATA
                MOV DS, AX

                MOV AH, 09H
                LEA DX, MSG     ; Print the string
                INT 21H

        STOP:
                MOV AX, 4C00H
                int 21H
CODE ENDS
        END START

stack segment para stack
    db 64 dup (' ')
stack ends

data segment
data ends

code segment
    assume cs:code, ds:data, ss:stack
    mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax

    ; Set the video mode - 320x200 - mode 13h
    mov ah, 00h
    mov al, 13h
    int 10h

    ; Draw pixel - 100 columns | 50 rows - color: red
    mov ah, 0ch
    mov cx, 100
    mov dx, 50
    mov al, 48
    int 10h

    ; Draw pixel - 120 columns | 50 rows - color: green
    mov ah, 0ch
    mov cx, 120
    mov dx, 50
    mov al, 52
    int 10h



    ; Wait for a keypres
    mov ah, 00h
    int 16h

    ; Return video mode back to text mode - 03h
    mov ah, 00h
    mov al, 03h
    int 10h

    ; Terminate the program
    mov ah, 4ch
    int 21h

code ends
end

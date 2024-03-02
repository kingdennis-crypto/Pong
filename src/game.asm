stack segment para stack
    db 64 dup (' ')
stack ends

data segment para 'data'
    windowWidth        dw 140h ; The width of the window (320 pixels)
    windowHeight       dw 0C8h ; The height of the window (200 pixels)
    windowBounds       dw 6    ; Variable used to check for collision early

    paddleLeftX        dw 0Ah  ; Current x position of the left paddle
    paddleLeftY        dw 40h  ; Current y position of the left paddle  

    paddleRightX       dw 130h ; Current x position of the right paddle
    paddleRightY       dw 40h  ; Current y position of the right paddle

    paddleWidth        dw 06h  ; Default paddle width
    paddleHeight       dw 35h  ; Default paddle height
    paddleVelocity     dw 0Fh  ; Default paddle velocity
data ends

code segment para 'code'
main proc far
    assume cs:code, ds:data, ss:stack

    push    ds          ; Push the data segment to the stack
    sub     ax, ax      ; Clean the AX register
    push    ax          ; Push AX to the stack
    mov     ax, data    ; Save the contents of data in the AX register
    mov     ds, ax      ; Save the AX register contents on the data segment
    pop     ax          ; Release the top item from the stack to the AX register
    pop     ax

    ; Initialize Graphics Mode 13 320x200 resolution with 256 colors
    call clearScreen

    call drawPaddles

    ;mov ah, 0Ch             ; Set the configuration to writing a pixel
    ;mov al, 0Fh             ; Choose white as color
    ;mov bh, 00h             ; Set the page number
    ;mov cx, 30h              ; CX -> paddle left x coordinates
    ;mov dx, 10h              ; DX -> paddle left y coordinates
    ;int 10h                 ; Execute

    ;mov ah, 0Ch             ; Set the configuration to writing a pixel
    ;mov al, 0Fh             ; Choose white as color
    ;mov bh, 00h             ; Set the page number
    ;mov cx, 20h              ; CX -> paddle left x coordinates
    ;mov dx, 10h              ; DX -> paddle left y coordinates
    ;int 10h                 ; Execute

    ; Wait for a keypres
    mov ah, 00h
    int 16h
    
    ; Terminates the game
    call exitGame
main endp

; Draw the left and right paddles
drawPaddles proc near
    ; FOR row FROM paddleY to paddleY + paddleHeight:
    ;   FOR col from paddleX to paddleX + paddleWidth:
    ;     DrawPixel(col, row, WHITE)

    ; Initialize row index (Y-coordinate)
    mov cx, paddleLeftX             ; X
    mov dx, paddleLeftY             ; Y

    drawLeftRow:
        mov cx, paddleLeftX
        inc dx

        drawLeftCol: 
            mov ah, 0Ch             ; Set the configuration to writing a pixel
            mov al, 0Fh             ; Choose white as color
            mov bh, 00h             ; Set the page number
            int 10h                 ; Execute

            inc cx

            mov ax, cx
            sub ax, paddleLeftX
            cmp ax, paddleWidth
            jle drawLeftCol
        
        mov ax, dx
        sub ax, paddleLeftY
        cmp ax, paddleHeight
        jle drawLeftRow

    mov cx, paddleRightX            ; X
    mov dx, paddleRightY            ; Y
    
    drawRighRow:
        mov cx, paddleRightX
        inc dx

        drawRightCol:
            mov ah, 0Ch             ; Set the configuration to writing a pixel
            mov al, 0Fh             ; Choose white as color
            mov bh, 00h             ; Set the page number
            int 10h                 ; Execute

            inc cx

            mov ax, cx
            sub ax, paddleRightX
            cmp ax, paddleWidth
            jle drawRightCol
        
        mov ax, dx
        sub ax, paddleRightY
        cmp ax, paddleHeight
        jle drawRighRow

    ret
drawPaddles endp

; Clear the screen by restarting the video mode
clearScreen proc near
    mov ah, 00h         ; Set the configuration to video mode
    mov al, 13h         ; Select the video mode
    int 10h             ; Execute

    mov ah, 0Bh
    mov bh, 00h
    mov bl, 02h         ; Set black as background color
    int 10h             ; Execute

    ret
clearScreen endp

; Go back to text mode
exitGame proc near
    mov ah, 00h         ; Set the configuration to video mode
    mov al, 02h         ; Select the video mode
    int 10h             ; Execute

    mov ah, 4Ch         ; Terminate the program
    int 21h
exitGame endp

code ends
end

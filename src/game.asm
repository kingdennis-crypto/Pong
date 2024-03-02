stack segment para stack
    db 64 dup (' ')
stack ends

data segment para 'data'
    windowWidth        dw 140h ; The width of the window (320 pixels)
    windowHeight       dw 0C8h ; The height of the window (200 pixels)
    windowBounds       dw 06h  ; Variable used to check for collision early

    paddleLeftX        dw 0Ah  ; Current x position of the left paddle
    paddleLeftY        dw 40h  ; Current y position of the left paddle  

    paddleRightX       dw 130h ; Current x position of the right paddle
    paddleRightY       dw 40h  ; Current y position of the right paddle

    paddleWidth        dw 06h  ; Default paddle width
    paddleHeight       dw 35h  ; Default paddle height
    paddleVelocity     dw 0Fh  ; Default paddle velocity
    paddleMoveOffset   dw 10h  ; Offset of paddle movement

    keyPressed         db 00h

    ballX              dw 0A0h
    ballY              dw 64h
    ballSize           dw 06h
    ballVelocityX      dw 01h
    ballVelocityY      dw 01h
    ballBorderWidth    dw 04h
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

    gameLoop:
        ; Listen for keypress
        call listenForKeyPress

        call movePaddles
        call drawPaddles

        call moveBall
        call drawBall

        jmp gameLoop
main endp

listenForKeyPress proc near
    ; Check if any key is being pressed
    mov ah, 01h
    int 16h

    ; Jump if no key was pressed
    jz noKeyPressed

    ; Check which key is being pressed
    mov ah, 00h
    int 16h

    ; If key is 'E' end game
    cmp al, 45h
    je startExitProcedure

    ; If key is 'e' end game
    cmp al, 65h
    je startExitProcedure

    mov keyPressed, al
    jmp endListen

    noKeyPressed:
        mov keyPressed, 00h
        jmp endListen

    startExitProcedure:
        call exitGame
        ret
    
    endListen:
        ret
listenForKeyPress endp

; Draw the left and right paddles
drawPaddles proc near
    ; FOR row FROM paddleY to paddleY + paddleHeight:
    ;   FOR col from paddleX to paddleX + paddleWidth:
    ;     DrawPixel(col, row, WHITE)

    ; Initialize coordinates (X,Y)
    mov dx, paddleLeftY
    sub dx, paddleMoveOffset    ; Y - offset

    mov cx, paddleLeftX
    jmp abovePaddleBlackCol

    abovePaddleBlackRow:
        mov cx, paddleLeftX
        inc dx

        abovePaddleBlackCol:
            mov ah, 0Ch             ; Set the configuration to writing a pixel
            mov al, 00h             ; Choose black as color
            mov bh, 00h             ; Set the page number
            int 10h                 ; Execute

            inc cx

            mov ax, cx
            sub ax, paddleLeftX
            cmp ax, paddleWidth
            jle abovePaddleBlackCol
        
        cmp dx, paddleLeftY
        jl abovePaddleBlackRow

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

    mov cx, paddleLeftY
    add cx, paddleHeight    ; Y + height
    jmp underLeftPaddleBlackCol

    underLefPaddleBlackRow:
        mov cx, paddleLeftX
        inc dx

        underLeftPaddleBlackCol:
            mov ah, 0Ch             ; Set the configuration to writing a pixel
            mov al, 00h             ; Choose black as color
            mov bh, 00h             ; Set the page number
            int 10h                 ; Execute

            inc cx

            mov ax, cx
            sub ax, paddleLeftX
            cmp ax, paddleWidth
            jle underLeftPaddleBlackCol
        
        mov ax, paddleLeftY
        add ax, paddleHeight
        add ax, paddleMoveOffset

        cmp dx, ax
        jle underLefPaddleBlackRow

    ; mov cx, paddleRightX            ; X
    ; mov dx, paddleRightY            ; Y
    mov dx, paddleRightY            ; Y
    sub dx, paddleMoveOffset        ; Y - offset

    mov cx, paddleRightX
    jmp aboveRightPaddleBlackCol
    
    aboveRightPaddleBlackRow:
        mov cx, paddleRightX
        inc dx

        aboveRightPaddleBlackCol:
            mov ah, 0Ch             ; Set the configuration to writing a pixel
            mov al, 00h             ; Choose black as color
            mov bh, 00h             ; Set the page number
            int 10h                 ; Execute

            inc cx

            mov ax, cx
            sub ax, paddleRightX
            cmp ax, paddleWidth
            jle aboveRightPaddleBlackCol

        cmp dx, paddleRightY
        jl aboveRightPaddleBlackRow

    mov cx, paddleRightX
    mov dx, paddleRightY
    jmp drawRightCol

    drawRightRow:
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
        jle drawRightRow

    mov cx, paddleRightY
    add cx, paddleHeight
    jmp underRightPaddleBlackCol

    underRightPaddleBlackRow:
        mov cx, paddleRightX
        inc dx

        underRightPaddleBlackCol:
            mov ah, 0Ch             ; Set the configuration to writing a pixel
            mov al, 00h             ; Choose black as color
            mov bh, 00h             ; Set the page number
            int 10h                 ; Execute

            inc cx

            mov ax, cx
            sub ax, paddleRightX
            cmp ax, paddleWidth
            jle underRightPaddleBlackCol
        
        mov ax, paddleRightY
        add ax, paddleHeight
        add ax, paddleMoveOffset

        cmp dx, ax
        jle underRightPaddleBlackRow

    ret
drawPaddles endp

movePaddles proc near
    cmp keyPressed, 57h ; W
    je  movePaddleUp

    cmp keyPressed, 77h ; w
    je movePaddleUp

    cmp keyPressed, 53h ; S
    je movePaddleDown

    cmp keyPressed, 73h ; s
    je movePaddleDown

    endFunction:
        ret

    movePaddleUp:
        mov ax, paddleLeftY
        
        ; paddleLeftY > 0 -> Out of bounds
        cmp ax, 0
        jle endFunction

        mov ax, paddleMoveOffset

        sub paddleLeftY, ax
        sub paddleRightY, ax
        ret

    movePaddleDown:
        mov ax, paddleLeftY
        add ax, paddleHeight
        add ax, windowBounds

        ; (paddleLeftY + paddleHeight + windowBounds) > windowHeight -> Out of bounds
        cmp ax, windowHeight
        jge endFunction

        mov ax, paddleMoveOffset

        add paddleLeftY, ax
        add paddleRightY, ax
        ret
movePaddles endp

drawBall proc near
    mov cx, ballX       ; X
    mov dx, ballY       ; Y

    ; Start coordinates
    sub cx, ballBorderWidth          ; X - borderWidth
    sub dx, ballBorderWidth          ; Y - borderWidth

    jmp drawHorizontal

    ; from startY to (startY + ballSize + 2 * borderWidth - 1)
    drawVertical:
        mov cx, ballX
        sub cx, ballBorderWidth
        inc dx

        drawHorizontal:
            ; Check if inside the ball boundaries
            cmp dx, ballY
            jl  notInsideBall

            ; TODO: Add also a check to see if the not inside ball is colliding with a paddle

            mov ax, ballY
            add ax, ballSize
            cmp dx, ax
            jge notInsideBall

            cmp cx, ballX
            jl notInsideBall

            mov ax, ballX
            add ax, ballSize
            cmp cx, ax
            jge notInsideBall

            ; Inside the ball boundaries, choose white as color
            mov al, 0Fh             ; Choose white as color
            jmp insideBall

            notInsideBall:
                ; Outise the ball boundary, choose black as color
                mov al, 00h
            
            insideBall:
                mov ah, 0Ch             ; Set the configuration to writing a pixel
                mov bh, 00h             ; Set the page number
                int 10h                 ; Execute
            
                inc cx                  ; Increment the X-coordinate

                mov ax, cx
                sub ax, ballX
                sub ax, ballBorderWidth
                cmp ax, ballSize
                jle drawHorizontal
        
        mov ax, dx
        sub ax, ballY
        sub ax, ballBorderWidth
        cmp ax, ballSize
        jle drawVertical

    ret
drawBall endp

moveBall proc near
    ; Move ball horizontal
    mov ax, ballVelocityX
    add ballX, ax

    ; Move ball vertical
    mov ax, ballVelocityY
    add ballY, ax

    ; Check if the ball has passed the top boundary
    mov ax, windowBounds
    cmp ballY, ax
    jle negateMovementBallVertical

    ; Check if the ball has passed the bottom boundary
    mov ax, windowHeight
    sub ax, ballSize
    sub ax, windowBounds
    cmp ballY, ax
    jge negateMovementBallVertical

    ; Check to see if the ball has touched the left side of the window
    mov ax, windowBounds
    cmp ballX, ax
    jle resetBallPosition
    
    ; Check if the ball collides with the left paddle
    mov ax, ballX
    sub ax, paddleWidth
    cmp ax, paddleLeftX
    je  checkLeftPaddleCollision

    ; Check if the ball collides with the right paddle
    mov ax, ballX
    add ax, ballSize
    cmp ax, paddleRightX
    je  negateMovementBallHorizontal 

    ; Check to see if the ball has touched the right side of the window
    mov ax, windowWidth
    sub ax, ballSize
    sub ax, windowBounds
    cmp ballX, ax
    jge resetBallPosition

    ; On no collision close subroutine
    jmp noCollision

    ; Teleport the ball to the start coordinates and move to right
    resetBallPosition:
        mov ballX, 0A0h
        mov ballY, 64h

        ; TODO: Add a check so that if player 1 scored it moves to player 1.
        ;  If player 2 scored, moves to player 2
        jmp moveBallHorizontal
        ret

    checkLeftPaddleCollision:
        mov ax, ballY
        add ax, ballSize
        cmp ax, paddleLeftY
        jle negateMovementBallHorizontal

        mov ax, paddleLeftY
        add ax, paddleHeight
        cmp ax, ballY
        jge negateMovementBallHorizontal
        ret

    ; Move the ball vertical
    moveBallVertical:
        mov ax, ballVelocityY
        add ballY, ax
        ret

    moveBallHorizontal:
        mov ax, ballVelocityX
        add ballX, ax
        ret

    negateMovementBallVertical:
        neg ballVelocityY
        ret
    
    negateMovementBallHorizontal:
        neg ballVelocityX
        ret
    
    noCollision:
        ret
moveBall endp

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

    ret
exitGame endp

code ends
end

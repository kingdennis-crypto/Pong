stack segment para stack
    db 64 dup (' ')
stack ends

data segment para 'data'
    windowWidth        dw 140h ; The width of the window (320 pixels)
    windowHeight       dw 0C8h ; The height of the window (200 pixels)
    windowBounds       dw 04h  ; Variable used to check for collision early

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

    playerOnePoints    db 0
    playerTwoPoints    db 0

    playerScored       db 0

    playerOnePointsText db '0', '$'
    playerTwoPointsText db '0', '$'
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
    call initializeVideoMode

    gameLoop:
        ; Listen for keypress
        call listenForKeyPress

        call movePaddles
        call drawPaddles

        call drawBall
        call moveBall
        ; call ballPaddleBoundaries

        call drawUI

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

    ; Check if the ball has passed the top window boundary
    mov ax, windowBounds
    cmp ballY, ax
    jle negateMovementVertical

    ; Check if the ball has passed the bottom window boundary
    mov ax, windowHeight
    sub ax, windowBounds
    sub ax, ballSize
    cmp ballY, ax
    jge negateMovementVertical

    ; Check if the ball has reached the left window boundary
    mov ax, windowBounds
    cmp ballX, ax
    jle leftOutOfBounds

    ; Check if the ball has reached the right window boundary
    mov ax, windowWidth
    sub ax, windowBounds
    sub ax, ballSize
    cmp ballX, ax
    jge rightOutOfBounds

    jmp checkPaddleCollisions

    leftOutOfBounds:
        call resetGame
        call playerTwoScores
        ret

    rightOutOfBounds:
        call resetGame
        call playerOneScores
        ret

    negateMovementVertical:
        neg ballVelocityY

    checkPaddleCollisions:
        ; Check left paddle collision
        mov ax, paddleLeftX
        add ax, paddleWidth
        cmp ax, ballX           ; LeftPaddleX < ballX
        jl  noCollision

        ; Check right paddle collision
        mov ax, paddleRightX
        sub ax, ballSize
        cmp ax, ballX           ; RightPaddleX > ballX
        jg  noCollision

        neg ballVelocityX

    checkLeftPaddleCollision:
        ret

    checkRightPaddleCollision:
        ret

    ; Check if the ball on the Y axis is in the boundaries of the paddle
    ; If no, do nothing
    ; If yes, check at which X coordinates the ball is, if colliding with paddle
    ; Negate the movement

    ; Check if between the both paddles
    ; YES -> NO COLLISION
    ; NO -> CHECK FOR COLLISIONS

    ; 20 <-> 100

    ; negateMovementHorizontal:
    ;     neg ballVelocityX

    noCollision:
        ret

    
    
moveBall endp

drawUI proc near
    ; Draw left player points
    mov ah, 02h                     ; Set cursor position
    mov bh, 00h                     ; Set page number
    mov dh, 01h                     ; Set row
    mov dl, 06h                     ; Set column
    int 10h

    mov ah, 09h                     ; Write string to the standard output
    lea dx, playerOnePointsText     ; Load playerOnePoints into DX
    int 21h                         ; Print the string

    ; Draw right player points
    mov ah, 02h                     ; Set cursor position
    mov bh, 00h                     ; Set page number
    mov dh, 01h                     ; Set row
    mov dl, 1Fh                     ; Set column
    int 10h

    mov ah, 09h                     ; Write string to the standard output
    lea dx, playerTwoPointsText     ; Load playerOnePoints into DX
    int 21h                         ; Print the string

    ret
drawUI endp

resetGame proc near
    mov paddleLeftY, 40h
    mov paddleRightY, 40h

    mov ballX, 0A0h
    mov ballY, 64h

    call initializeVideoMode

    ; TODO: Add a delay with a timer for the user to know when it stops
    call moveBall

    ret
resetGame endp

playerOneScores proc near
    mov ah, playerOnePoints
    inc ah

    mov playerOnePoints, ah
    add ah, 30h                     ; Adds 30 hex to get to  decimals in ASCII table
    mov [playerOnePointsText], ah

    ret
playerOneScores endp

playerTwoScores proc near
    mov ah, playerTwoPoints
    inc ah

    mov playerTwoPoints, ah
    add ah, 30h                     ; Add 30 hext to get to decimals in ASCII table
    mov [playerTwoPointsText], ah

    ret
playerTwoScores endp

; Clear the screen by restarting the video mode
initializeVideoMode proc near
    mov ah, 00h         ; Set the configuration to video mode
    mov al, 13h         ; Select the video mode
    int 10h             ; Execute

    mov ah, 0Bh
    mov bh, 00h
    mov bl, 02h         ; Set black as background color
    int 10h             ; Execute

    ret
initializeVideoMode endp

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

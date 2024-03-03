stack segment para stack
    db 64 dup (' ')
stack ends

data segment para 'data'
    windowWidth        dw 140h ; The width of the window (320 pixels)
    windowHeight       dw 0C8h ; The height of the window (200 pixels)
    windowBounds       dw 04h  ; Variable used to check for collision early

    gameMode           db 0h   ; Current in game game mode:
                               ; - 0: Game Menu, 
                               ; - 1: Singleplayer, 
                               ; - 2: Multiplayer,
                               ; - 3: Game Over

    paddleLeftX        dw 0Ah  ; Current x position of the left paddle
    paddleLeftY        dw 40h  ; Current y position of the left paddle  

    paddleRightX       dw 130h ; Current x position of the right paddle
    paddleRightY       dw 40h  ; Current y position of the right paddle

    paddleWidth        dw 04h  ; Default paddle width
    paddleHeight       dw 25h  ; Default paddle height
    paddleVelocity     dw 10h  ; Default paddle velocity

    keyPressed         db 00h  ; Current pressed key  

    ballX              dw 0A0h ; Where the ball is located on a X-axis
    ballY              dw 64h  ; Where the ball is located on a Y-axis
    ballSize           dw 06h  ; The size of the ball X and Y
    ballVelocityX      dw 01h  ; How fast the ball moves sideways
    ballVelocityY      dw 01h  ; How fast the ball moves up and down
    ballBorderWidth    dw 04h  ; The buffer around the ball to be drawn black

    playerOnePoints    db 0    ; How many points player 1 has
    playerTwoPoints    db 0    ; How many points player 2 has

    playerScored       db 0    ; Keeps track of who scored; 1 -> Player one, 2 -> Player two

    playerOnePointsText db '0', '$' ; Points of player one to print to the screen
    playerTwoPointsText db '0', '$' ; Points of player two to print to the screen

    waitTimer          db 3         ; The timer for when the game resets or stars
    waitTimerText      db '3', '$'  ; The timer text that should be displayed

    ; UI-text
    mainMenuTitle      db 'PONG', '$'
    mainMenuSubtitle   db 'You will hate yourself :)', '$'
    menuGameModeOne    db '[1] - Singleplayer', '$'
    menuGameModeTwo    db '[2] - Multiplayer', '$'
    menuGameModeExit   db '[E] - Exit the game', '$' 

    menuPlayerOneCtlr  db 'Player 1: UP: W - DOWN: O', '$'
    menuPlayerTwoCtlr  db 'Player 2: UP: S - DOWN: L', '$'

    gameOverTitle      db 'GAME OVER! GG', '$'
    gameOverWinner     db 'Player 0 won', '$'
    gameOverPlayAgain  db 'Press M to go to the main menu', '$'
    gameOverExit       db 'Press E to exit the game', '$'
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

        cmp  gameMode, 0h
        je   mainMenuGameMode

        ; FIXME: When losing a game and then via menu trying to restart the game
        ;   will open in game over mode
        cmp  gameMode, 3h
        je   gameOverMenuMode

        call moveLeftPaddle
        call moveRightPaddle

        call drawPaddles

        call drawBall
        call moveBall

        call drawUI

        jmp gameLoop

        gameOverMenuMode:
            call drawGameOverMenu
            jmp  gameLoop

        mainMenuGameMode:
            call drawMainMenu
            jmp  gameLoop
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

    ; If key is '1' set singleplayer
    cmp al, 31h
    je  setSinglePlayer

    ; If key is '2' set multiplayer
    cmp al, 32h
    je  setMultiPlayer

    ; If key is 'E' exit the game
    cmp al, 45h
    je  startExitProcedure

    ; If key is 'e' exit the game
    cmp al, 65h
    je  startExitProcedure

    ; If key is 'M' go to the main menu
    cmp al, 4Dh
    je  setToMainMenu

    ; If key is 'm' go to the main menu
    cmp al, 6Dh
    je  setToMainMenu

    mov keyPressed, al
    jmp endListen

    setToMainMenu:
        mov  gameMode, 0h
        call initializeVideoMode
        jmp  endListen

    setSinglePlayer:
        mov  gameMode, 1h
        mov  playerScored, 0h
        call initializeVideoMode
        jmp  endListen

    setMultiPlayer:
        mov  gameMode, 2h
        mov  playerScored, 0h
        call initializeVideoMode
        jmp  endListen

    noKeyPressed:
        mov  keyPressed, 00h
        jmp  endListen

    startExitProcedure:
        call  exitGame
    
    endListen:
        ret
listenForKeyPress endp

; Draw the main menu
drawMainMenu proc near
    ; TODO: Refactor these lines to a separate subroutine with
    ;   row, column, and text pointer as arguments

    ; Draw the main title
    mov ah, 02h                 ; Set cursor position
    mov bh, 00h                 ; Set page number
    mov dh, 03h                 ; Set row
    mov dl, 03h                 ; Set column
    int 10h                     ; Execute

    mov ah, 09h                 ; Set to write string to standard output
    lea dx, mainMenuTitle       ; Load mainMenuTitle as string
    int 21h                     ; Execute

    ; Draw the subtitle
    mov ah, 02h                 ; Set cursor position
    mov bh, 00h                 ; Set page number
    mov dh, 04h                 ; Set row
    mov dl, 03h                 ; Set column
    int 10h                     ; Execute

    mov ah, 09h                 ; Set to wrote string to the standard output
    lea dx, mainMenuSubtitle   ; Load mainMenuSubtitle as string to display
    int 21h                     ; Execute

    ; Draw the first game mode
    mov ah, 02h                 ; Set cursor position
    mov bh, 00h                 ; Set page number
    mov dh, 08h                 ; Set row
    mov dl, 05h                 ; Set column
    int 10h                     ; Execute

    mov ah, 09h                 ; Set to wrote string to the standard output
    lea dx, menuGameModeOne     ; Load mainMenuSubtitle as string to display
    int 21h                     ; Execute

    ; Draw the second game mode
    mov ah, 02h                 ; Set cursor position
    mov bh, 00h                 ; Set page number
    mov dh, 0Ah                 ; Set row
    mov dl, 05h                 ; Set column
    int 10h                     ; Execute

    mov ah, 09h                 ; Set to wrote string to the standard output
    lea dx, menuGameModeTwo     ; Load mainMenuSubtitle as string to display
    int 21h                     ; Execute

    ; Draw the exit game mode
    mov ah, 02h                 ; Set cursor position
    mov bh, 00h                 ; Set page number
    mov dh, 0Ch                 ; Set row
    mov dl, 05h                 ; Set column
    int 10h                     ; Execute

    mov ah, 09h                 ; Set to wrote string to the standard output
    lea dx, menuGameModeExit    ; Load mainMenuSubtitle as string to display
    int 21h                     ; Execute

    ; Draw the Player One controls text
    mov ah, 02h                 ; Set cursor position
    mov bh, 00h                 ; Set page number
    mov dh, 14h                 ; Set row
    mov dl, 03h                 ; Set column
    int 10h                     ; Execute

    mov ah, 09h                 ; Set to wrote string to the standard output
    lea dx, menuPlayerOneCtlr   ; Load mainMenuSubtitle as string to display
    int 21h                     ; Execute

    ; Draw the player two controls text
    mov ah, 02h                 ; Set cursor position
    mov bh, 00h                 ; Set page number
    mov dh, 16h                 ; Set row
    mov dl, 03h                 ; Set column
    int 10h                     ; Execute

    mov ah, 09h                 ; Set to wrote string to the standard output
    lea dx, menuPlayerTwoCtlr   ; Load mainMenuSubtitle as string to display
    int 21h                     ; Execute

    ret
drawMainMenu endp

drawGameOverMenu proc near
    ; Write the game over menu title
    mov ah, 02h                 ; Set cursor position
    mov bh, 00h                 ; Set page number
    mov dh, 04h                 ; Set row
    mov dl, 04h                 ; Set column
    int 10h                     ; Execute

    mov ah, 09h                 ; Write string to the standard output
    lea dx, gameOverTitle       ; Load string into standard output
    int 21h                     ; Execute

    mov al, playerScored        ; Retrieves who scored last
    add al, 30h                 ; Change number to ASCII
    mov [gameOverWinner+7], al  ; Update the winner text with the correct winner

    ; Show who won
    mov ah, 02h                 ; Set cursor position
    mov bh, 00h                 ; Set page number
    mov dh, 06h                 ; Set row
    mov dl, 04h                 ; Set column
    int 10h                     ; Execute

    mov ah, 09h                 ; Write string to the standard output
    lea dx, gameOverWinner      ; Load string into standard output
    int 21h                     ; Execute

    ; Show replay message
    mov ah, 02h                 ; Set cursor position
    mov bh, 00h                 ; Set page number
    mov dh, 0Ah                 ; Set row
    mov dl, 04h                 ; Set column
    int 10h                     ; Execute

    mov ah, 09h                 ; Write string to the standard output
    lea dx, gameOverPlayAgain   ; Load string into standard output
    int 21h                     ; Execute

    ; Show exit game message
    mov ah, 02h                 ; Set cursor position
    mov bh, 00h                 ; Set page number
    mov dh, 0Ch                 ; Set row
    mov dl, 04h                 ; Set column
    int 10h                     ; Execute

    mov ah, 09h                 ; Write string to the standard output
    lea dx, gameOverExit        ; Load string into standard output
    int 21h                     ; Execute

    ret
drawGameOverMenu endp

; Draw the left and right paddles
drawPaddles proc near
    ; FOR row FROM paddleY to paddleY + paddleHeight:
    ;   FOR col from paddleX to paddleX + paddleWidth:
    ;     DrawPixel(col, row, WHITE)

    ; Initialize coordinates (X,Y)
    mov dx, paddleLeftY
    sub dx, paddleVelocity    ; Y - offset

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
        add ax, paddleVelocity

        cmp dx, ax
        jle underLefPaddleBlackRow

    ; mov cx, paddleRightX            ; X
    ; mov dx, paddleRightY            ; Y
    mov dx, paddleRightY            ; Y
    sub dx, paddleVelocity        ; Y - offset

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
        add ax, paddleVelocity

        cmp dx, ax
        jle underRightPaddleBlackRow

    ret
drawPaddles endp

moveLeftPaddle proc near
    cmp keyPressed, 57h ; W
    je  leftPaddleUp

    cmp keyPressed, 77h ; w
    je  leftPaddleUp

    cmp keyPressed, 53h ; S
    je  leftPaddleDown

    cmp keyPressed, 73h ; s
    je  leftPaddleDown

    ret

    leftPaddleUp:
        mov ax, paddleLeftY
        
        cmp ax, windowBounds
        jle endLeftMove

        mov ax, paddleLeftY
        sub ax, paddleVelocity
        mov paddleLeftY, ax
        ret

    leftPaddleDown:
        mov ax, paddleLeftY
        add ax, paddleHeight
        add ax, windowBounds

        cmp ax, windowHeight
        jge endLeftMove

        mov ax, paddleLeftY
        add ax, paddleVelocity
        mov paddleLeftY, ax
        ret

    endLeftMove:
        ret
moveLeftPaddle endp

moveRightPaddle proc near
    cmp gameMode, 2h
    jl  aiControlled
    
    cmp keyPressed, 4Fh ; O
    je  rightPaddleUp

    cmp keyPressed, 6Fh ; o
    je  rightPaddleUp

    cmp keyPressed, 4Ch ; L
    je  rightPaddleDown

    cmp keyPressed, 6Ch ; l
    je  rightPaddleDown

    jmp endRightMove

    ; The paddle is controlled by AI
    aiControlled:
        ; Check if the ball is above the paddle (ballY + ballSize < paddleRightY)
        mov ax, ballY
        add ax, ballSize
        ; If true -> Move paddle up
        cmp ax, paddleRightY
        jl rightPaddleUp

        ; Check if the ball is below the paddle (ballY - paddleHeight > paddleRightY)
        mov ax, ballY
        sub ax, paddleHeight
        ; If true -> Move paddle down
        cmp ax, paddleRightY
        jg rightPaddleDown

        ; If none -> Do nothing
        jmp endRightMove

    rightPaddleUp:
        mov ax, paddleRightY

        cmp ax, windowBounds
        jle endRightMove

        mov ax, paddleRightY
        sub ax, paddleVelocity
        mov paddleRightY, ax
        ret

    rightPaddleDown:
        mov ax, paddleRightY
        add ax, paddleHeight
        add ax, windowBounds

        cmp ax, windowHeight
        jge endRightMove

        mov ax, paddleRightY
        add ax, paddleVelocity
        mov paddleRightY, ax
        ret

    endRightMove:
        ret
moveRightPaddle endp

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

    ; ; Move ball vertical
    ; mov ax, ballVelocityY
    ; add ballY, ax

    ; Check if the ball has passed the left window boundary
    mov ax, windowBounds
    cmp ballX, ax
    jl  leftOutOfBounds

    ; Check if the ball has passed the right window boundary
    mov ax, windowWidth
    sub ax, ballSize
    sub ax, windowBounds
    cmp ballX, ax
    jg rightOutOfBounds

    jmp moveBallVertical

    leftOutOfBounds:
        call playerTwoScores
        ret

    rightOutOfBounds:
        call playerOneScores
        ret

    moveBallVertical:
        mov ax, ballVelocityY
        add ballY, ax

    ; Check if the ball has passed the top window boundary
    mov ax, windowBounds
    cmp ballY, ax
    jl  negateMovementVertical

    ; Check if the ball has passed the bottom boundary
    mov ax, windowHeight
    sub ax, ballSize
    sub ax, windowBounds
    cmp ballY, ax
    jg  negateMovementVertical

    ; Check if the ball is colliding with the right paddle
    mov ax, ballX
    add ax, ballSize
    cmp ax, paddleRightX
    jng checkLeftPaddleCollision

    mov ax, paddleRightX
    add ax, paddleWidth
    cmp ballX, ax
    jnl checkLeftPaddleCollision

    mov ax, ballY
    add ax, ballSize
    cmp ax, paddleRightY
    jng checkLeftPaddleCollision

    mov ax, paddleRightY
    add ax, paddleHeight
    cmp ballY, ax
    jnl checkLeftPaddleCollision

    jmp negateMovementHorizontal

    ; Check if the ball is colliding with the left paddle
    checkLeftPaddleCollision:
        mov ax, ballX
        add ax, ballSize
        cmp ax, paddleLeftX
        jng noCollision

        mov ax, paddleLeftX
        add ax, paddleWidth
        cmp ballX, ax
        jnl noCollision

        mov ax, ballY
        add ax, ballSize
        cmp ax, paddleLeftY
        jng noCollision

        mov ax, paddleLeftY
        add ax, paddleHeight
        cmp ballY, ax
        jnl noCollision

        ; If it reached this point it means that the ball collides with the left paddle
        jmp negateMovementHorizontal

    negateMovementVertical:
        neg ballVelocityY
        ret
    negateMovementHorizontal:
        neg ballVelocityX
        ret

    noCollision:
        ret
moveBall endp

drawUI proc near
    cmp gameMode, 0h
    je endDraw

    cmp gameMode, 3h
    je  endDraw

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

    ; TODO: Add dashed center line
    endDraw:
        ret
drawUI endp

drawTimer proc near
    mov ah, 02h
    mov bh, 00h
    mov dh, 04h
    mov dl, 06h
    int 10h

    mov ah, 09h
    lea dx, waitTimerText
    int 21h

    ret
drawTimer endp

resetGame proc near
    call initializeVideoMode
    call initializeGame

    ; TODO: Add a delay with a timer for the user to know when it stops
    ; Add a delay of 1 second
    ; Increment counter
    mov waitTimer, 3
    mov ah, 3h
    add ah, 30h
    mov [waitTimerText], ah
    call drawTimer

    ; 1 Second delay
    mov cx, 0Fh
    mov dx, 4240h
    mov ah, 86h
    int 15h

    mov waitTimer, 2
    mov ah, 2h
    add ah, 30h
    mov [waitTimerText], ah
    call drawTimer
    
    mov cx, 0Fh
    mov dx, 4240h
    mov ah, 86h
    int 15h

    mov waitTimer, 1
    mov ah, 1h
    add ah, 30h
    mov [waitTimerText], ah
    call drawTimer

    mov cx, 0Fh
    mov dx, 4240h
    mov ah, 86h
    int 15h

    mov waitTimer, 0
    mov ah, 00h
    mov [waitTimerText], ah
    call drawTimer

    neg ballVelocityX
    call moveBall

    ret
resetGame endp

playerOneScores proc near
    mov  playerScored, 1
    mov  ah, playerOnePoints
    inc  ah

    ; If player 1 scored 5 points the game will show a game over menu
    cmp  ah, 02h
    je   showGameOverMenuPlayerOne

    mov  playerOnePoints, ah
    add  ah, 30h                     ; Adds 30 hex to get to  decimals in ASCII table
    mov  [playerOnePointsText], ah
    call resetGame

    ret

    showGameOverMenuPlayerOne:
        mov  gameMode, 3h
        call initializeVideoMode
        ret
playerOneScores endp

playerTwoScores proc near
    mov  playerScored, 2
    mov  ah, playerTwoPoints
    inc  ah

    ; If player 2 scored 5 points the game will show a game over menu
    cmp  ah, 02h
    je   showGameOverMenuPlayerTwo

    mov  playerTwoPoints, ah
    add  ah, 30h                     ; Add 30 hext to get to decimals in ASCII table
    mov  [playerTwoPointsText], ah
    call resetGame

    ret

    showGameOverMenuPlayerTwo:
        mov  gameMode, 3h
        call initializeVideoMode
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

initializeGame proc near
    mov paddleLeftY, 40h
    mov paddleRightY, 40h

    mov ballX, 0A0h
    mov ballY, 64h

    call drawPaddles
    call drawBall
    call drawUI

    ret
initializeGame endp

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

# Space Blaster

You control a spaceship in a 2D space environment and it is your goal to shoot
down enemy spaceships while avoiding obstacles.

## Features

1. Real-Time Movement
1. Physics-Based Shooting
1. Enemy Spaceships
1. Score System
1. Graphics

## Pseudocode

```
; Space Blaster - DOSBox Assembly Pseudocode

; Initialize Game
;    Initialize Graphics Mode 13h ; 320x200 resolution with 256 colors

InitializeGame:
    loadSprites()               ; Load spaceship, enemy, and obstacle sprites
    initializePlayer()          ; Set up player spaceship
    initializeEnemies()         ; Set up enemy spaceships
    initializeObstacles()       ; Set up obstacles
    initializeScore()           ; Set initial score to 0

; Game Loop (while loop)
GameLoop:
    ; Input
    checkInput()                ; Check keyboard input for movement and shooting

    ; Update
    MovePlayer()                ; Update player's position based on input
    MoveEnemies()               ; Update enemy positions with basic AI (Random movement)
    MoveObstacles()             ; Update obstacle positions

    ; Collision detection
    CheckCollisions()           ; Check for collisions between entities

    ; Draw
    DrawBackground()            ; Draw space background
    DrawPlayer()                ; Draw player spaceship
    DrawEnemies()               ; Draw enemy spaceships
    DrawObstacles()             ; Draw obstacles
    DrawScore()                 ; Display current score

    ; Game Over Check
    CheckGameOver()             ; Check if player has lost all lives

    ; Delay for smooth gameplay
    Delay(16)                   ; Aim for approximately 60 frames per second

    ; Loop back to GameLoop
    JMP GameLoop

; Subroutines
LoadSprites:
    ; Use BIOS or DOS interrupts for file loading

InitializePlayer:
    ; Set initial position, speed, and sprite for the player

InitializeEnemies:
    ; Set initial positions, speeds, and sprites for enemy spaceships

InitializeObstacles:
    ; Set initial positions, speeds, and sprites for obstacles

InitializeScore:
    ; Set initial score to 0

CheckInput:
    ; Check keyboard input for arrow keys and spacebar

MovePlayer:
    ; Update player's position based on keyboard input
    ; Apply physics for smooth movement

MoveEnemies:
    ; Update enemy positions with simple AI
    ; Move towards the player or move randomly

CheckCollisions:
    ; Check for collisions between player, enemies, and obstacles
    ; Update score, lives, or other game variables accordingly

DrawBackground:
    ; Draw a space background using color palette

DrawPlayer:
    ; Draw the player's spaceship on the screen

DrawEnemies:
    ; Draw enemy spaceships on the screen

DrawObstacles:
    ; Draw obstacles on the screen

DrawScore:
    ; Display the current score on the screen

CheckGameOver:
    ; Display game over screen or reset game if necessary

Delay:
    ; Implement a delay to control the game's frame rate
    ; Use BIOS or DOS interrupts for delay
```

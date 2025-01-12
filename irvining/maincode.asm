include Irvine32.inc
includelib Winmm.lib
include macros.inc

PlaySound PROTO, pszSound:PTR BYTE, hmod:DWORD,fdwSound:DWORD
GetStdHandle PROTO :DWORD   ; Prototype for GetStdHandle
SetConsoleTextAttribute PROTO :DWORD, :WORD ; Prototype for SetConsoleTextAttribute

.data
    ; Sound handling
    deviceConnect BYTE "DeviceConnect",0
    SND_ALIAS    DWORD 00010000h
    SND_RESOURCE DWORD 00040005h
    SND_FILENAME DWORD 00020000h
    fired BYTE "shootsound.wav",0
    gameMusic BYTE "zumamusic.wav",0  

    ; File Handling
    scoresFile db "scores.txt",0
    namesFile db "names.txt",0
    levelnumFile db "levels.txt",0
    fileHandle  HANDLE ?
    BUFSIZE = 5000
    buffer BYTE BUFSIZE DUP(?)
    bytesRead DWORD ?

initialScreen db '    .-----------------.  .----------------.  .----------------.  .----------------.',13,10 
db '                | .--------------. || .--------------. || .--------------. || .--------------. |',13,10 
db '                | |   ________   | || | _____  _____ | || | ____    ____ | || |      __      | |',13,10 
db '                | |  |  __   _|  | || ||_   _||_   _|| || ||_   \  /   _|| || |     /  \     | |',13,10 
db '                | |  |_/  / /    | || |  | |    | |  | || |  |   \/   |  | || |    / /\ \    | |',13,10 
db '                | |     .`.` _   | || |  | |    | |  | || |  | |\  /| |  | || |   / ____ \   | |',13,10 
db '                | |   _/ /__/ |  | || |   \ `--` /   | || | _| |_\/_| |_ | || | _/ /    \ \_ | |',13,10 
db '                | |  |________|  | || |    `.__.`    | || ||_____||_____|| || ||____|  |____|| |',13,10 
db '                | |              | || |              | || |              | || |              | |',13,10 
db '                |  --------------  ||  --------------  ||  --------------  ||  --------------  |',13,10 
db '                  ----------------    ----------------    ----------------    ---------------- ',13,10 
db 0



gameMenu db ' _______ _________ _______  _______ _________   _______  _______  _______  _______ ',13,10                                   
db '  (  ____ \\__   __/(  ___  )(  ____ )\__   __/  (  ____ \(  ___  )(       )(  ____ \       ',13,10                            
db '  | (    \/   ) (   | (   ) || (    )|   ) (     | (    \/| (   ) || () () || (    \/      ',13,10                             
db '  | (_____    | |   | (___) || (____)|   | |     | |      | (___) || || || || (__             ',13,10                          
db '  (_____  )   | |   |  ___  ||     __)   | |     | | ____ |  ___  || |(_)| ||  __)          ',13,10                            
db '        ) |   | |   | (   ) || (\ (      | |     | | \_  )| (   ) || |   | || (              ',13,10                           
db '  /\____) |   | |   | )   ( || ) \ \__   | |     | (___) || )   ( || )   ( || (____/\         ',13,10                          
db '  \_______)   )_(   |/     \||/   \__/   )_(     (_______)|/     \||/     \|(_______/         ',13,10                          
db '                                                                                                       ',13,10               
db '          _________ _        _______ _________ _______           _______ __________________ _______  _        _______ ',13,10
db '          \__   __/( (    /|(  ____ \\__   __/(  ____ )|\     /|(  ____ \\__   __/\__   __/(  ___  )( (    /|(  ____ \',13,10
db '             ) (   |  \  ( || (    \/   ) (   | (    )|| )   ( || (    \/   ) (      ) (   | (   ) ||  \  ( || (    \/',13,10
db '             | |   |   \ | || (_____    | |   | (____)|| |   | || |         | |      | |   | |   | ||   \ | || (_____ ',13,10
db '             | |   | (\ \) |(_____  )   | |   |     __)| |   | || |         | |      | |   | |   | || (\ \) |(_____  )',13,10
db '             | |   | | \   |      ) |   | |   | (\ (   | |   | || |         | |      | |   | |   | || | \   |      ) |',13,10
db '          ___) (___| )  \  |/\____) |   | |   | ) \ \__| (___) || (____/\   | |   ___) (___| (___) || )  \  |/\____) |',13,10
db '          \_______/|/    )_)\_______)   )_(   |/   \__/(_______)(_______/   )_(   \_______/(_______)|/    )_)\_______)',13,10
db '                                                                                                                      ',13,10
db '                               _______          __________________   _______  _______  _______  _______               ',13,10
db '                              (  ____ \|\     /|\__   __/\__   __/  (  ____ \(  ___  )(       )(  ____ \              ',13,10
db '                              | (    \/( \   / )   ) (      ) (     | (    \/| (   ) || () () || (    \/              ',13,10
db '                              | (__     \ (_) /    | |      | |     | |      | (___) || || || || (__                  ',13,10
db '                              |  __)     ) _ (     | |      | |     | | ____ |  ___  || |(_)| ||  __)                 ',13,10
db '                              | (       / ( ) \    | |      | |     | | \_  )| (   ) || |   | || (                    ',13,10
db '                              | (____/\( /   \ )___) (___   | |     | (___) || )   ( || )   ( || (____/\              ',13,10
db '                              (_______/|/     \|\_______/   )_(     (_______)|/     \||/     \|(_______/             ',13,10
db 0


pauseScreen db '             .______       _______     _______. __    __  .___  ___.  _______ ',13,10
db '                       |   _  \     |   ____|   /       ||  |  |  | |   \/   | |   ____| ',13,10
db '                       |  |_)  |    |  |__     |   (----`|  |  |  | |  \  /  | |  |__    ',13,10
db '                       |      /     |   __|     \   \    |  |  |  | |  |\/|  | |   __|   ',13,10
db '                       |  |\  \----.|  |____.----)   |   |  `--   | |  |  |  | |  |____  ',13,10
db '                       | _| `._____||_______|_______/     \______/  |__|  |__| |_______| ',13,10
                                                                                                                            
db '                                        __________   ___  __  .___________. ',13,10
db '                                       |   ____\  \ /  / |  | |           | ',13,10
db '                                       |  |__   \  V  /  |  | `---|  |----` ',13,10
db '                                       |   __|   >   <   |  |     |  |      ',13,10
db '                                       |  |____ /  .  \  |  |     |  |      ',13,10
db '                                       |_______/__/ \__\ |__|     |__|      ',13,10
db 0


game_Instructions db ' ____  _  _  ___  ____  ____  __  __  ___  ____  ____  _____  _  _  ___ ',13,10
db'     (_  _)( \( )/ __)(_  _)(  _ \(  )(  )/ __)(_  _)(_  _)(  _  )( \( )/ __)',13,10
db'      _)(_  )  ( \__ \  )(   )   / )(__)(( (__   )(   _)(_  )(_)(  )  ( \__ \',13,10
db'     (____)(_)\_)(___/ (__) (_)\_)(______)\___) (__) (____)(_____)(_)\_)(___/',13,10
                                                                        

                               db'                                                                                                ',13,10
                               db'      1- Use the QWEADZXC keys to move your player direction.                                   ',13,10
                               db'      2- The current color of the ball is displayed at the top.                                 ',13,10
                               db'                                                                                                ',13,10
                               db'      Gameplay:                                                                                 ',13,10
                               db'                                                                                                ',13,10
                               db'      1- A chain of balls will move along a certain path.                                       ',13,10
                               db'      2- Shoot at the chain to form groups of two or three balls of the same color              ',13,10
                               db'      3- DONT let the chain reach the "(_)", or else the game will END!                         ',13,10
                               db'                                                                                                ',13,10
                               db'      Scoring:                                                                                  ',13,10
                               db'                                                                                                ',13,10
                               db'      1- Groups of 2 reward 100 points, groups of 3 reward 200 points                           ',13,10
                               db'      2- Bonus points will be given for completing a level.                                     ',13,10
                               db'                                                                                                ',13,10
                               db'      Game Over:                                                                                ',13,10
                               db'                                                                                                ',13,10
                               db'      1- If a fired ball does not form a group you lose a life.                                 ',13,10
                               db'      2- Losing all lives will end the game. You have three lives to start.                     ',13,10
                               db 0


                 endScreen db'               ______        ______  _______     _____  _    _ _______ ______   ',13,10
                  db'                        / _____)  /\  |  ___ \(_______)   / ___ \| |  | (_______(_____ \  ',13,10
                  db'                       | /  ___  /  \ | | _ | |_____     | |   | | |  | |_____   _____) ) ',13,10
                  db'                       | | (___)/ /\ \| || || |  ___)    | |   | |\ \/ /|  ___) (_____ (  ',13,10
                  db'                       | \____/| |__| | || || | |_____   | |___| | \  / | |_____      | | ',13,10
                  db'                        \_____/|______|_||_||_|_______)   \_____/   \/  |_______)     |_| ',13,10
                  db'                                                                                          ',13,10
                  db'                                              Better Luck Next Time!                      ',13,10  
                  db'                                              Your score was :                            ',13,10            
                  
                  db 0          




    walls BYTE " _____________________________________________________________________________ ", 0
          BYTE "|                                                                             |", 0
          BYTE "|                   (_)                                                       |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                    ---                                      |", 0
          BYTE "|                                   |   |                                     |", 0
          BYTE "|                                   |   |                                     |", 0
          BYTE "|                                   |   |                                     |", 0
          BYTE "|                                    ---                                      |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                                                             |", 0
          BYTE "|_____________________________________________________________________________|", 0

   walls2 BYTE " _____________________________________________________________________________ ", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                    ---                                      |", 0
          BYTE "|                                   |   |      /                              |", 0
          BYTE "|                                   |   |     |                               |", 0
          BYTE "|                                   |   |      \                              |", 0
          BYTE "|                                    ---                                      |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                                                             |", 0
          BYTE "|                                                                             |", 0
          BYTE "|_____________________________________________________________________________|", 0

COMMENT !
    ; Player sprite
    player_right BYTE "   ", 0
                 BYTE " O-", 0
                 BYTE "   ", 0

    player_left BYTE "   ", 0
                BYTE "-O ", 0
                BYTE "   ", 0

    player_up BYTE " | ", 0
              BYTE " O ", 0
              BYTE "   ", 0

    player_down BYTE "   ", 0
                BYTE " O ", 0
                BYTE " | ", 0

    player_upright BYTE "  /", 0
                   BYTE " O ", 0
                   BYTE "   ", 0

    player_upleft BYTE "\  ", 0
                  BYTE " O ", 0
                  BYTE "   ", 0

    player_downright BYTE "   ", 0
                     BYTE " O ", 0
                     BYTE "  \", 0

    player_downleft BYTE "   ", 0
                    BYTE " O ", 0
                    BYTE "/  ", 0
!
;////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ; Player sprite

        player_right BYTE " ^ ", 0
                 BYTE " 0-", 0
                 BYTE " v ", 0

    player_left BYTE " ^ ", 0
                BYTE "-0 ", 0
                BYTE " v ", 0

    player_up BYTE " | ", 0
              BYTE "<0>", 0
              BYTE "   ", 0

    player_down BYTE "   ", 0
                BYTE "<0>", 0
                BYTE " | ", 0

    player_upright BYTE "  /", 0
                   BYTE "<0>", 0
                   BYTE "   ", 0

    player_upleft BYTE "\  ", 0
                  BYTE "<0>", 0
                  BYTE "   ", 0

    player_downright BYTE "   ", 0
                     BYTE "<0>", 0
                     BYTE "  \", 0

    player_downleft BYTE "   ", 0
                    BYTE "<0>", 0
                    BYTE "/  ", 0


;////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    ; Player's starting position (center)
    xPos db 56      ; Column (X)
    yPos db 15      ; Row (Y)

    xDir db 0
    yDir db 0

    ; Default character (initial direction)
    inputChar db 0
    direction db "d"

    ; Colors for the emitter and player
    color_red db 4       ; Red
    color_green db 2     ; Green
    color_yellow db 14   ; Yellow (for fire symbol)

    current_color db 4   ; Default player color (red)

    emitter_color1 db 2H  ; Green
    emitter_color2 db 4H  ; Red

    fire_color db 14     ; Fire symbol color (Yellow)

    ; Emitter properties
    emitter_symbol db "#"
    emitter_row db 0    ; Two rows above player (fixed row for emitter)
    emitter_col db 1    ; Starting column of the emitter

    ; Fire symbol properties (fired from player)
    fire_symbol db "*", 0
    fire_row db 0        ; Fire will be fired from the player's position
    fire_col db 0        ; Initial fire column will be set in the update logic

    ; Balls
    
    maxY            BYTE    24      ; Maximum Y position (bottom of the screen, assuming 25 rows)
    initialStartX   BYTE    40      ; Initial X position for the chain (middle of the screen, adjust as needed)
    delayCount      DWORD   20000000 

    ; Chain
    chain db 4, 2, 4, 2, 2, 4, 4, 2, 0  ; Sequence of colors: 1 = Red, 2 = Green (0=End of Chain)
    chainLength equ $ - chain           ; Length of the chain
    asterisk db '*'                     
    screenWidth dw 80                   
    blankChar db ' '                    
    startX db 40                        ; Starting X position 
    startY db 27                        ; Starting Y position 

    movingUp2 db 0
    movingRight2 db 0
    movingDown2 db 0
    movingLeft2 db 0

    collisionBool db 0

    ; Interface variables
    score DWORD 0          ; Player's score
    levelInfo db 1

    userName db 15 DUP(?)
    newLine      db 0Dh, 0Ah     

    namePrmpt db "Player, Enter your name = ",0
    colorPrmpt db "BALL COLOR",0

    strScore db "Score: ",0

    livesLine db "Lives:",0
    lives3 db "III",0
    lives2 db "II",0
    lives1 db "I",0
    lives db 3


    ; Counter variables for loops
    counter1 db 0
    counter2 db 0

.code

Delay1Second PROC
    mov ecx, delayCount                
delayLoop:
    nop                                
    dec cx                            
    jnz delayLoop                 
ret
Delay1Second ENDP

gameOver PROC

    call clrscr
    mov dl, 10
    mov dh, 10
    mov eax, white
    call SetTextColor
    call Gotoxy
    mov edx, offset endScreen
    call WriteString
    mov eax, score
    call WriteDec
    mov eax, 4000
    call Delay
    call WaitMsg
    call clrscr

   ; Writing scores to file
    mov eax, fileHandle
    mov edx, offset scoresFile
    call CreateOutPutFile
    mov fileHandle, eax
    mov edx, offset score
    mov ecx, 3
    call WriteString
    mov eax, fileHandle
    call CloseFIle

  ; Writing level to file
    mov eax, fileHandle
    mov edx, offset levelNumFile
    call CreateOutPutFile
    mov fileHandle, eax
    mov edx, offset levelInfo
    mov ecx, 1
    call WriteString
    mov eax, fileHandle
    call CloseFIle


    INVOKE ExitProcess, 0 
gameOver ENDP


updateScore PROC
    mov dl,19
	mov dh,2
	call Gotoxy
	mWrite <"Score: ">
	mov eax, Blue + (black * 16)
	call SetTextColor
	mov eax, score
	call WriteDec
ret
updateScore ENDP


updateChain PROC
    ; Erase the current chain
    mov esi, 0                          
    mov dl, startX                      
    mov dh, startY                      

eraseChain:
    mov al, chain[esi]                  ; Load current chain element
    cmp al, 0                           
    je moveChain                       

    mov al, blankChar                   ; Load blank character
    call Gotoxy                         
    call WriteChar                      ; Write blank to erase ball
    
    ; Move to the next position
    inc esi                             
    dec dh                              ; Move upward
    jmp eraseChain                     

moveChain:
    ; Decrement the starting Y position to move chain upward
    mov al, startY
    dec al                              
    mov startY, al                      

    ; Redraw the chain
    mov esi, 0                        
    mov dl, startX                      
    mov dh, startY                     

redrawChain:
    mov al, chain[esi]                  
    cmp al, 0                          
    je done                            

    cmp al, 5H
    je poppedSpace

    ; Set text color based on chain color
    cmp al, 4
    je setRed
    cmp al, 2
    je setGreen

setRed:
    mov al, 4                           ; Red color code
    call SetTextColor
    jmp printBall

setGreen:
    mov al, 2                           ; Green color code
    call SetTextColor

printBall:
    mov al, asterisk                   
    call Gotoxy                        
    call WriteChar                      
    jmp point

poppedSpace:
    mov al, blankChar
    call Gotoxy
    call WriteChar

    point:
    ; Move to the next position
    inc esi                          
    dec dh                             
    jmp redrawChain                    

done:
    ret
updateChain ENDP


printChain PROC
    mov esi, 0                     
    mov dl, startX                 
    mov dh, startY                 

nextBall:
    mov al, chain[esi]             
    cmp al, 0                      
    je done                      

    cmp al, 5H
    je point

    ; Set text color based on the ball color
    cmp al, 4
    je setRed
    cmp al, 2
    je setGreen

setRed:
    mov eax, 4                      ; Color code for red
    call SetTextColor
    jmp printBall

setGreen:
    mov eax, 2                      ; Color code for green
    call SetTextColor

printBall:
    mov al, asterisk               
    call Gotoxy                    
    call WriteChar             

    ; Move to the next position in the chain
    
    point:
    inc esi                      
    dec dh                        
    cmp dh, 0                      
    jge nextBall                  


done:
    ret
printChain ENDP

ballChainCollision PROC

    ; EDX contains the fireball coordinates (passed directly)
    mov fire_col, dl            ; Fireball X-coordinate (lower byte of EDX)
    mov fire_row, dh            ; Fireball Y-coordinate (next byte of EDX)

    mov esi, 0                  ; Index for the chain array
    mov dl, startX              ; X position where the chain starts
    mov dh, startY              ; Y position where the chain starts

checkCollision:
    mov cl, chain[esi]          ; Get the current ball in the chain
    cmp cl, 0                   ; End of chain?
    je noCollision              ; Exit if the chain ends

    cmp cl, 5H                  ; Check if the ball is already "empty" (black)
    je noCollision              ; If the ball is "empty", skip it

    ; Compare fireball position with the current ball's position
    cmp fire_col, dl            ; Check if X matches
    jne nextBall                ; If not, move to the next ball
    cmp fire_row, dh            ; Check if Y matches
    jne nextBall                ; If not, move to the next ball

    ; Collision detected
collisionDetected:
    ; Display collision message (optional debug info)
    mov collisionBool, 1    
    mov eax, white
    call SetTextColor
    mov dl, 10
    mov dh, 2
    call Gotoxy
    ;mWrite <"collided">


    ; Compare fireball color with chain ball color
    movzx eax, fire_color       ; Move fireball color into EAX (ensure zero-extended)
    movzx ebx, cl               ; Move chain ball color into EBX (ensure zero-extended)

    ; If fireball color matches chain ball color (red or green)
    cmp eax, ebx                ; Compare colors
    jne noPop                   ; If colors don't match, skip the "pop"

    mov collisionBool, 1    ; 1 means colors are equal
    ; Change ball color to 5H (black) to make it "disappear"
    mov chain[esi], 5H          ; Update the ball's color to black (invisible)
    mov eax, score
    add eax, 100
    mov score, eax
    call updateScore

    ; OPTIONAL: Display a message for successful pop
    mov eax, green              ; Set text color to green
    call SetTextColor
    mov dl, 10
    mov dh, 4
    call Gotoxy
    ;mWrite <"Ball Turned Black!">
    jmp noCollision

noPop:
    mov collisionBool, -1       ; -1 means wrong color     
    jmp noCollision             ; Exit after handling collision

nextBall:
    ; Move to the next ball's position in the chain
    inc esi                     ; Move to the next ball in the chain
    dec dh                      ; Move upward (Y decreases for the next ball)
    cmp dh, 0                   ; Check if we reached the top of the screen
    jge checkCollision          ; Continue checking if within bounds

    ; Handle when the chain wraps left after reaching the top
    mov dh, 27                  ; Reset to bottom Y
    dec dl                      ; Move one column left
    cmp dl, 0                   ; Check if we are out of bounds
    jge checkCollision          ; Continue if X is valid

noCollision:
    ret
ballChainCollision ENDP



FireBall PROC
    
    ;INVOKE PlaySound, OFFSET fired, NULL, 1

    mov fire_color, al      ; Set the random color
    mov dl, xPos      ; Fire column starts at the player's X position
    mov dh, yPos      ; Fire row starts at the player's Y position

    mov fire_col, dl  ; Save the fire column position
    mov fire_row, dh  ; Save the fire row position

    mov al, direction
    cmp al, "w"
    je fire_up

    cmp al, "x"
    je fire_down

    cmp al, "a"
    je fire_left

    cmp al, "d"
    je fire_right

    cmp al, "q"
    je fire_upleft

    cmp al, "e"
    je fire_upright

    cmp al, "z"
    je fire_downleft

    cmp al, "c"
    je fire_downright

    jmp end_fire

fire_up:
    mov fire_row, 14         ; Move fire position upwards
    mov fire_col, 57         ; Center fire position
    mov xDir, 0
    mov yDir, -1
    jmp fire_loop

fire_down:
    mov fire_row, 18         ; Move fire position downwards
    mov fire_col, 57         ; Center fire position
    mov xDir, 0
    mov yDir, 1
    jmp fire_loop

fire_left:
    mov fire_col, 55         ; Move fire position leftwards
    mov fire_row, 16         ; Center fire position
    mov xDir, -1
    mov yDir, 0
    jmp fire_loop

fire_right:
    mov fire_col, 59         ; Move fire position rightwards
    mov fire_row, 16         ; Center fire position
    mov xDir, 1
    mov yDir, 0
    jmp fire_loop

fire_upleft:
    mov fire_row, 14         ; Move fire position upwards
    mov fire_col, 55         ; Move fire position leftwards
    mov xDir, -1
    mov yDir, -1
    jmp fire_loop

fire_upright:
    mov fire_row, 14         ; Move fire position upwards
    mov fire_col, 59         ; Move fire position rightwards
    mov xDir, 1
    mov yDir, -1
    jmp fire_loop

fire_downleft:
    mov fire_row, 18         ; Move fire position downwards
    mov fire_col, 55         ; Move fire position leftwards
    mov xDir, -1
    mov yDir, 1
    jmp fire_loop

fire_downright:
    mov fire_row, 18         ; Move fire position downwards
    mov fire_col, 59         ; Move fire position rightwards
    mov xDir, 1
    mov yDir, 1
    jmp fire_loop

fire_loop:
    ; Initialise fire position
    mov dl, fire_col
    mov dh, fire_row
    call GoToXY
    
    ; Loop to move the fireball in the current direction
    L1:

        ; Ensure fire stays within the bounds of the emitter wall
        cmp dl, 20            ; Left wall boundary
        jle end_fire

        cmp dl, 96            ; Right wall boundary
        jge end_fire

        cmp dh, 5             ; Upper wall boundary
        jle end_fire

        cmp dh, 27            ; Lower wall boundary
        jge end_fire

        cmp dh, 40
        jge end_fire

        ; Print the fire symbol at the current position
        movzx eax, fire_color    ; Set fire color
        call SetTextColor
        add dl, xDir
        add dh, yDir
        call Gotoxy

        mWrite "*"
        push edx
        call ballChainCollision
        pop edx

        cmp collisionBool, -1
        je livesDec

        cmp collisionBool, 1
        je end_fire

        ; Continue moving fire in the current direction (recursive)
        mov eax, 50
        call Delay

        ; erase the fire before redrawing it
        call GoToXY
        mWrite " "

        jmp L1


    livesDec:
        mov al, lives
        dec al
        mov lives, al
        mov collisionBool, 0

            cmp lives, 2
            je twoLives
            cmp lives, 1
            je oneLife
            call gameOver

    twoLives:
        mov dl, 90
        mov dh, 2
        call Gotoxy
        mWrite <"              ">
        call Gotoxy
        mov eax, white
        call SetTextColor
        mWrite <"Lives: ">
        mov eax, Red + (black * 16)
        call SetTextColor
        mov edx, offset lives2
        call WriteString
        mov dx, 0
        call GoToXY
        jmp fireBallFuncEnd

    oneLife:
        mov dl, 90
        mov dh, 2
        call Gotoxy
        mWrite <"              ">
        call Gotoxy
        mov eax, white
        call SetTextColor
        mWrite <"Lives: ">
        mov eax, Red + (black * 16)
        call SetTextColor
        mov edx, offset lives1
        call WriteString
        mov dx, 0
        call GoToXY
        jmp fireBallFuncEnd

    end_fire:
    mov collisionBool, 0
    ; Decrement lives
    ;jmp fireBallFuncEnd

fireBallFuncEnd:
ret
FireBall ENDP

DrawWall PROC
	call clrscr

    mov dl,19
	mov dh,2
	call Gotoxy
	mWrite <"Score: ">
	mov eax, Blue + (black * 16)
	call SetTextColor
	mov eax, score
	call WriteDec

    mov eax, White + (black * 16)
	call SetTextColor

    comment %
	mov dl,90
	mov dh,2
	call Gotoxy
	mWrite <"Lives: ">
	mov eax, Red + (black * 16)
	call SetTextColor
	mov edx, offset lives3
    call writestring
    ;mov al, lives
	;call WriteDec
    %

	mov dl,90
	mov dh,2
	call Gotoxy
	mWrite <"Lives: ">
	mov eax, Red + (black * 16)
	call SetTextColor
	
    cmp lives, 3
    je ThreeLives
    cmp lives, 2
    je TwoLives
    cmp lives, 1
    je OneLife

    ThreeLives:
    mov edx, offset lives3
    call writestring    
    jmp goOn
    
    TwoLives:
    mov edx, offset lives2
    call writestring
    jmp goOn

    OneLife:
    mov edx, offset lives1
    call writestring

    goOn:
	mov eax, white + (black * 16)
	call SetTextColor

	mov dl,55
	mov dh,2
	call Gotoxy

	mWrite "LEVEL " 
	mov al, levelInfo
	call WriteDec

	mov eax, gray + (black*16)
	call SetTextColor

	mov dl, 19
	mov dh, 4
	call Gotoxy

	mov esi, offset walls

	mov counter1, 50
	mov counter2, 80
	movzx ecx, counter1
	printcolumn:
		mov counter1, cl
		movzx ecx, counter2
		printrow:
			mov eax, [esi]
			call WriteChar
            
			inc esi
		loop printrow
		
        dec counter1
		movzx ecx, counter1

		mov dl, 19
		inc dh
		call Gotoxy
	loop printcolumn

	ret
DrawWall ENDP

PrintPlayer PROC
    mov eax, brown + (black * 16)
    call SetTextColor

    mov al, direction
    cmp al, "w"
    je print_up

    cmp al, "x"
    je print_down

    cmp al, "a"
    je print_left

    cmp al, "d"
    je print_right

    cmp al, "q"
    je print_upleft

    cmp al, "e"
    je print_upright

    cmp al, "z"
    je print_downleft

    cmp al, "c"
    je print_downright

    ret

    print_up:
        mov esi, offset player_up
        jmp print

    print_down:
        mov esi, offset player_down
        jmp print

    print_left:
        mov esi, offset player_left
        jmp print

    print_right:
        mov esi, offset player_right
        jmp print

    print_upleft:
        mov esi, offset player_upleft
        jmp print

    print_upright:
        mov esi, offset player_upright
        jmp print

    print_downleft:
        mov esi, offset player_downleft
        jmp print

    print_downright:
        mov esi, offset player_downright
        jmp print

    print:
    mov dl, xPos
    mov dh, yPos
    call GoToXY

    mov counter1, 3
	mov counter2, 4
	movzx ecx, counter1
	printcolumn:
		mov counter1, cl
		movzx ecx, counter2
		printrow:
			mov eax, [esi]
			call WriteChar
            
			inc esi
		loop printrow

		movzx ecx, counter1

		mov dl, xPos
		inc dh
		call Gotoxy
	loop printcolumn
    
ret
PrintPlayer ENDP

comment $
MovePlayer PROC
     
    ; Display the ball color text
    mov dl, 19
    mov dh, 3
    call Gotoxy             ; Move cursor to position (19, 3)

ColorChange:                ;  Changing the color of the ball. Alternates between red/green.    
    mov al, fire_color
    cmp al, emitter_color1  ; Check if the current color is green
    je setToRed
    jne setToGreen

setToRed:
    movsx eax, emitter_color2  ; Set to red
    jmp updateColorPrompt

setToGreen:
    movsx eax, emitter_color1  ; Set to green


; Updates "BALL COLOR" above game map so player can know what the color of the ball is before it is shot
updateColorPrompt:
    mov dl, 19
    mov dh, 3
    call Gotoxy
    mWrite<"           ">
    mov dl, 19
    mov dh, 3
    call Gotoxy
    mov fire_color, al      
    call SetTextColor        
    mov edx, offset colorPrmpt 
    call setTextColor
    call WriteString         
    

    ; Reset cursor
    mov dl, 0
    mov dh, 0
    call Gotoxy

checkInput:
    mov eax, 5
    call Delay

    call printChain
    mov eax, 1000      
    call Delay    
    call updateChain 

    ; Check for key press
    mov eax, 0
    call ReadKey
    mov inputChar, al

    cmp inputChar, VK_SPACE
    je shoot

    cmp inputChar, VK_ESCAPE
    je paused

    cmp inputChar, "w"
    je move

    cmp inputChar, "a"
    je move

    cmp inputChar, "x"
    je move

    cmp inputChar, "d"
    je move

    cmp inputChar, "q"
    je move

    cmp inputChar, "e"
    je move

    cmp inputChar, "z"
    je move

    cmp inputChar, "c"
    je move

    ; If character is invalid, check for a new keypress
    jmp checkInput

move:
    mov direction, al
    call PrintPlayer
    jmp checkInput

paused:
    call clrscr
    mov dl,10
    mov dh,5
    mov eax,white
    call settextcolor
    call gotoxy
    mov edx,offset offset pauseScreen
    call writestring
    mov eax,4000
    call delay
    call readint
    call clrscr
    ret
        
shoot:
    movzx eax, fire_color   ; Move the fire_color to EAX (zero-extended)
    push eax                ; Push the color as the attribute
    call FireBall
    ;jmp checkInput          ; Return to input checking after firing
    jmp ColorChange

ret
MovePlayer ENDP
$

MovePlayer PROC

    ; Display the ball color text
    mov dl, 19
    mov dh, 3
    call Gotoxy             ; Move cursor to position (19, 3)

mainLoop:

    ; Exit Condition: If score >= 300, leave function
    mov eax, score      ; Move the score into EAX
    cmp eax, 300        ; Compare score with 300
    jl Level1  
    
    cmp eax, 300
    jge Level2

Level1:

ColorChange:                ; Changing the color of the ball. Alternates between red/green.
    mov al, fire_color
    cmp al, emitter_color1  ; Check if current color is green
    je setToRed
    jne setToGreen

setToRed:
    mov al, emitter_color2  ; Set to red
    jmp updateColorPrompt

setToGreen:
    mov al, emitter_color1  ; Set to green

updateColorPrompt:
    ; Update "BALL COLOR" display
    mov dl, 19
    mov dh, 3
    call Gotoxy
    mWrite <"           ">   ; Clear previous text
    mov dl, 19
    mov dh, 3
    call Gotoxy
    mov fire_color, al
    call SetTextColor
    mov edx, offset colorPrmpt
    call WriteString         

    ; Reset cursor position
    mov dl, 0
    mov dh, 0
    call Gotoxy

checkInput:
    mov eax, 5
    call Delay

    call printChain
    mov eax, 1000
    call Delay
    call updateChain

    ; Check for key press
    mov eax, 0
    call ReadKey
    mov inputChar, al

    cmp inputChar, VK_SPACE
    je shoot

    cmp inputChar, VK_ESCAPE
    je paused

    cmp inputChar, "w"
    je move
    cmp inputChar, "a"
    je move
    cmp inputChar, "x"
    je move
    cmp inputChar, "d"
    je move
    cmp inputChar, "q"
    je move
    cmp inputChar, "e"
    je move
    cmp inputChar, "z"
    je move
    cmp inputChar, "c"
    je move

    ; Invalid key, loop back
    jmp checkInput

move:
    mov direction, al
    call PrintPlayer
    jmp checkInput

paused:
    call clrscr
    mov dl, 10
    mov dh, 5
    mov eax, white
    call SetTextColor
    call Gotoxy
    mov edx, offset pauseScreen
    call WriteString
    mov eax, 4000
    call Delay
    call ReadInt
    call clrscr

shoot:
    movzx eax, fire_color   ; Move the fire_color to EAX (zero-extended)
    push eax                ; Push the color as the attribute
    call FireBall
    jmp mainLoop            ; Return to the main loop after shooting



Level2:
    mov al, levelInfo
    inc al
    mov levelInfo, al
    call clrscr
    call InitialiseScreen

    Level2Loop:
           call MovePlayer2
    jmp Level2Loop


exitMovePlayer:
    ret
MovePlayer ENDP

MovePlayer2 PROC

    ; Display the ball color text
    mov dl, 19
    mov dh, 3
    call Gotoxy             ; Move cursor to position (19, 3)

mainLoop:

    ; Exit Condition: If score >= 300, leave function
    mov eax, score      ; Move the score into EAX
    cmp eax, 300        ; Compare score with 300
    jl Level1  
    
    cmp eax, 300
    ;jge Level3

Level1:

ColorChange:                ; Changing the color of the ball. Alternates between red/green.
    mov al, fire_color
    cmp al, emitter_color1  ; Check if current color is green
    je setToRed
    jne setToGreen

setToRed:
    mov al, emitter_color2  ; Set to red
    jmp updateColorPrompt

setToGreen:
    mov al, emitter_color1  ; Set to green

updateColorPrompt:
    ; Update "BALL COLOR" display
    mov dl, 19
    mov dh, 3
    call Gotoxy
    mWrite <"           ">   ; Clear previous text
    mov dl, 19
    mov dh, 3
    call Gotoxy
    mov fire_color, al
    call SetTextColor
    mov edx, offset colorPrmpt
    call WriteString         

    ; Reset cursor position
    mov dl, 0
    mov dh, 0
    call Gotoxy

checkInput:
    mov eax, 5
    call Delay

    call printChain
    mov eax, 1000
    call Delay
    call updateChain

    ; Check for key press
    mov eax, 0
    call ReadKey
    mov inputChar, al

    cmp inputChar, VK_SPACE
    je shoot

    cmp inputChar, VK_ESCAPE
    je paused

    cmp inputChar, "w"
    je move
    cmp inputChar, "a"
    je move
    cmp inputChar, "x"
    je move
    cmp inputChar, "d"
    je move
    cmp inputChar, "q"
    je move
    cmp inputChar, "e"
    je move
    cmp inputChar, "z"
    je move
    cmp inputChar, "c"
    je move

    ; Invalid key, loop back
    jmp checkInput

move:
    mov direction, al
    call PrintPlayer
    jmp checkInput

paused:
    call clrscr
    mov dl, 10
    mov dh, 5
    mov eax, white
    call SetTextColor
    call Gotoxy
    mov edx, offset pauseScreen
    call WriteString
    mov eax, 4000
    call Delay
    call ReadInt
    call clrscr

shoot:
    movzx eax, fire_color   ; Move the fire_color to EAX (zero-extended)
    push eax                ; Push the color as the attribute
    call FireBall
    jmp mainLoop            ; Return to the main loop after shooting


comment ^
Level3:
    mov al, levelInfo
    inc al
    mov levelInfo, al
    call clrscr
    call InitialiseScreen

    Level3Loop:
           call MovePlayer3
    jmp Level3Loop
^

exitMovePlayer2:
    ret
MovePlayer2 ENDP

InitialiseScreen PROC
    call DrawWall    ; prints frame for gameplay, stays the same for all levels
    call PrintPlayer 
ret
InitialiseScreen ENDP

InitScreen PROC
    call clrscr
    mov dl,13
    mov dh,8
    mov eax,white
    call settextcolor
    call gotoxy
    mov edx,offset initialScreen
    call writestring
    mov eax,4000
    call delay
    ;call waitmsg
    call clrscr
ret 
InitScreen ENDP


PrintGameMenu PROC
    call clrscr
    mov dl,2 
    mov dh,2
    mov eax,white
    call settextcolor
    call gotoxy
    mov edx,offset gameMenu
    call writestring
    mov eax,4000
    call delay
    call waitmsg
ret 
PrintGameMenu ENDP

update_emitter PROC
    ; Update the emitter symbols to animate the line
    push ax
    push cx
    push dx

    mov cx, 80           ; Number of columns (console width)
    mov dl, emitter_col
    mov dh, emitter_row

    ; Redraw emitter with updated colors
emitter_update_loop:
    ; Alternate emitter colors between green and red
    cmp al, emitter_color1
    jne set_green_color
    mov al, emitter_color2
    jmp draw_symbol

set_green_color:
    mov al, emitter_color1

draw_symbol:
    call SetTextcolor
    mov al, emitter_symbol
    call Gotoxy
    call WriteChar

    inc dl               ; Move to the next column
    cmp dl, 80           ; Wrap around at the end of the row
    jne emitter_update_loop
    mov dl, emitter_col  ; Reset column

    pop dx
    pop cx
    pop ax
    ret
update_emitter ENDP

; i have not called this function
draw_emitter PROC
    ; Draw the emitter with alternating colors
    push ax
    push cx
    push dx

    mov cx, 119          ; Number of columns (console width)
    mov dl, emitter_col
    mov dh, emitter_row

emitter_loop:
    ; Alternate emitter colors between green and red
    mov al, emitter_color1
    call SetTextColor

    mov al, emitter_symbol
    call Gotoxy
    call WriteChar

    ; Toggle color for the next symbol
    cmp al, emitter_color1
    jne set_green
    mov al, emitter_color2
    jmp next_symbol

set_green:
    mov al, emitter_color1

next_symbol:
    inc dl               ; Move to the next column
    cmp dl, 119          ; Wrap around at the end of the row
    jne emitter_loop
    mov dl, emitter_col  ; Reset column

    pop dx
    pop cx
    pop ax
    ret
draw_emitter ENDP


CreateFiles PROC

    ; Scores File
    mov edx, OFFSET scoresFile
    call CreateOutputFile      
    call CloseFile

    ; Names file
    mov edx, OFFSET namesFile
    call CreateOutputFile       
    call CloseFile

    ; Levels file
    mov edx, OFFSET levelnumFile
    call CreateOutputFile     
    call CloseFile

    ret
CreateFiles ENDP


main PROC
   
;COMMENT @
    ;Starting screen
    call InitScreen
   
    INVOKE PlaySound, OFFSET gameMusic, NULL, 1
    call CreateFiles

    ; Name input
    mov dh,0
    mov dl,0
    call gotoxy
    mov edx,offset namePrmpt
    mov ecx,lengthof namePrmpt
    call writestring
    mov edx,offset userName
    mov ecx,15
    call readstring
    call clrscr


    ; Writing username to file
    mov eax, fileHandle
    mov edx, offset namesFile
    call CreateOutPutFile
    mov fileHandle, eax
    mov edx, offset userName
    mov ecx, 15
    call WriteToFile
    mov eax, fileHandle
    call CloseFIle
   
   

 P1: 
    call PrintGameMenu
    call readint
   
    cmp al, 1
    je p2  ; User chose Start - so game starts from Level 1
   
    cmp al, 2  
    je Instructions ; User chose to see Instructions
    cmp al, 3
    je ExitGame
    jmp P2

 Instructions:
    call clrscr
    mov dl,5
    mov dh,0
    mov eax,white
    call settextcolor
    call gotoxy
    mov edx,offset game_Instructions
    call writestring
    mov eax,4000
    call delay
    call waitmsg
    jmp P1
 ;@

   ; Game map initialization for Level 1
   P2:
   call InitialiseScreen
  
   GameLoop:
       call MovePlayer            
   jmp GameLoop                     
  
    ExitGame:
main ENDP
END main

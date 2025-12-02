include "emu8086.inc"

.MODEL SMALL
.STACK 100H

LINE_BREAK MACRO
    MOV DL, 10
    MOV AH, 02h       ; Use for line break 
    INT 21h
    MOV DL, 13
    MOV AH, 02h
    INT 21h
ENDM

DISPLAY_MESSAGE MACRO msg
    LEA DX, msg
    MOV AH, 9               ; Use for display 
    INT 21H
ENDM

PRINT_REG9 MACRO reg
    MOV DX, reg
    MOV AH, 9
    INT 21H
ENDM

PRINT_REG2 MACRO reg
    MOV DL, reg
    MOV AH, 2
    INT 21H
ENDM

WAIT_FOR_KEY MACRO msg
    DISPLAY_MESSAGE msg    ; used to display a message and then pause the program's execution until the user presses any key
    MOV AH, 1
    INT 21H
ENDM

.DATA
    GREETING_MSG        DB 'Welcome to Quizzarie!$'
    AUTH_TITLE          DB 0AH,0DH,'Player Login',0AH,0DH,'------------',0AH,0DH,'$'
    PLAYER_ONE_LABEL    DB 'PLAYER 1$'
    PLAYER_TWO_LABEL    DB 'PLAYER 2$'
    USER_PROMPT         DB 0AH,0DH,'Enter your username: $'
    PW_PROMPT           DB 0AH,0DH,'Enter your password: $'
    AUTH_SUCCESS        DB 0AH,0DH,'Access granted!$'
    AUTH_FAIL           DB 0AH,0DH,'Invalid login. Please try again.$'
    CONTINUE_PROMPT     DB 0AH,0DH,'Press any key to continue...$'
    GOODBYE_MSG         DB 0AH,0DH,'Game Over! Thank you for playing!$'
    SCORE_MSG           DB 0AH,0DH,'Current score: $'
    LIFELINE_COUNT      DB 0AH,0DH,'Lifelines remaining: $'
    ANSWER_PROMPT       DB 0AH,0DH,'Your answer (A/B/C/D): $'
    CORRECT_ANSWER_MSG  DB 0AH,0DH,'Correct! You got it.$'
    INCORRECT_ANSWER_MSG DB 0AH,0DH,'Incorrect answer!$'
    LIFELINE_PROMPT     DB 0AH,0DH,'Would you like to use a 50:50 lifeline? (0=No, 1=Yes): $'
    LIFELINE_USED_MSG   DB 0AH,0DH,'Lifeline used! Two wrong options have been removed.$'
    P_MSG               DB 'Player: $'
    L_MSG               DB 'Level $'
    NEXT_TURN_MSG       DB 0AH,0DH,'Next players turn!$'
    WINNER_MESSAGE      DB 0AH,0DH,'And the winner is: $'
    INVALID_CHOICE      DB 0AH,0DH,'Invalid selection!$'
    NEXTLEVEL_MSG       DB 0AH,0DH,'Advancing to the next level...$'
    
    PLAYER1_USER        DB 20 DUP(0)
    PLAYER1_PASS        DB 20 DUP(0)
    
    PLAYER2_USER        DB 20 DUP(0)
    PLAYER2_PASS        DB 20 DUP(0)
    
    USER_INPUT_BUF      DB 20 DUP(0)
    PASS_INPUT_BUF      DB 20 DUP(0)
    
    PLAYER1_REGISTERED  DB 0
    PLAYER2_REGISTERED  DB 0
    
    LOGIN_MENU_PROMPT   DB 0AH,0DH,'1. Login',0AH,0DH,'2. Register',0AH,0DH,'Choose an option: $'
    REGISTER_FIRST_MSG  DB 0AH,0DH,'Please register first!$'
    
    USERNAME_EMPTY_MSG  DB 0AH,0DH,'Username cannot be empty! Please try again.$'
    USERNAME_SHORT_MSG  DB 0AH,0DH,'Username must be at least 3 characters! Please try again.$'
    PASSWORD_EMPTY_MSG  DB 0AH,0DH,'Password cannot be empty! Please try again.$'
    PASSWORD_SHORT_MSG  DB 0AH,0DH,'Password must be at least 4 characters! Please try again.$'
    REG_SUCCESS_MSG     DB 0AH,0DH,'Registration successful! You can now login.$'
    
    MENU_HEADING        DB 0AH,0DH,'QUIZZARIE - MAIN MENU',0AH,0DH,'---------------------------',0AH,0DH,'$'
    MENU_OPTION1        DB '1. Begin Game',0AH,0DH,'$'
    MENU_OPTION2        DB '2. How to Play',0AH,0DH,'$'
    MENU_OPTION3        DB '3. Exit',0AH,0DH,'$'
    MENU_CHOICE_PROMPT  DB 0AH,0DH,'Choose an option (1-3): $'
    
    GAME_RULES          DB 0AH,0DH,'HOW TO PLAY:',0AH,0DH
                        DB '- Quizzarie is a 2-player quiz game.',0AH,0DH
                        DB '- Players take turns answering questions.',0AH,0DH
                        DB '- Each player starts with 3 lifelines.',0AH,0DH
                        DB '- A lifeline eliminates 2 incorrect options.',0AH,0DH
                        DB '- There are 10 questions in total.',0AH,0DH
                        DB '- The player with the highest score is the champion!$'
    
    CURRENT_PLAYER_ID   DB 1
    SCORE_P1            DB 0
    SCORE_P2            DB 0
    LIFELINE_P1         DB 3
    LIFELINE_P2         DB 3
    GAME_LEVEL          DB 1
    CURRENT_Q_INDEX     DB 1
    
    LIFELINE_ACTIVE     DB 0
    
    Q1_TEXT             DB 'Which planet is known as the Red Planet?$'
    Q1_OPT_A            DB 'A. Earth$'
    Q1_OPT_B            DB 'B. Venus$'
    Q1_OPT_C            DB 'C. Jupiter$'
    Q1_OPT_D            DB 'D. Mars$'
    Q1_ANSWER           DB 4
    
    Q2_TEXT             DB 'Who wrote the play "Romeo and Juliet"?$'
    Q2_OPT_A            DB 'A. Charles Dickens$'
    Q2_OPT_B            DB 'B. William Shakespeare$'
    Q2_OPT_C            DB 'C. Mark Twain$'
    Q2_OPT_D            DB 'D. Jane Austen$'
    Q2_ANSWER           DB 2
    
    Q3_TEXT             DB 'Which number system does a computer use to represent data?$'
    Q3_OPT_A            DB 'A. Decimal$'
    Q3_OPT_B            DB 'B. Binary$'
    Q3_OPT_C            DB 'C. Octal$'
    Q3_OPT_D            DB 'D. Hexadecimal$'
    Q3_ANSWER           DB 2
    
    Q4_TEXT             DB 'What is the speed of light in vacuum (approximate)?$'
    Q4_OPT_A            DB 'A. 3 x 10^8 m/s$'
    Q4_OPT_B            DB 'B. 3 x 10^6 m/s$'
    Q4_OPT_C            DB 'C. 3 x 10^5 m/s$'
    Q4_OPT_D            DB 'D. 3 x 10^7 m/s$'
    Q4_ANSWER           DB 1
    
    Q5_TEXT             DB 'What is the chemical symbol for Gold?$'
    Q5_OPT_A            DB 'A. Ag$'
    Q5_OPT_B            DB 'B. Ga$'
    Q5_OPT_C            DB 'C. Gd$'
    Q5_OPT_D            DB 'D. Au$'
    Q5_ANSWER           DB 4
    
    Q6_TEXT             DB 'Which organelle is known as the powerhouse of the cell?$'
    Q6_OPT_A            DB 'A. Nucleus$'
    Q6_OPT_B            DB 'B. Ribosome$'
    Q6_OPT_C            DB 'C. Mitochondria$'
    Q6_OPT_D            DB 'D. Chloroplast$'
    Q6_ANSWER           DB 3
    
    Q7_TEXT             DB 'What does CPU stand for in computer science?$'
    Q7_OPT_A            DB 'A. Central Processing Unit$'
    Q7_OPT_B            DB 'B. Computer Personal Unit$'
    Q7_OPT_C            DB 'C. Control Processing Unit$'
    Q7_OPT_D            DB 'D. Central Performance Unit$'
    Q7_ANSWER           DB 1
    
    Q8_TEXT             DB 'Which continent is known as the "Dark Continent"?$'
    Q8_OPT_A            DB 'A. Asia$'
    Q8_OPT_B            DB 'B. Africa$'
    Q8_OPT_C            DB 'C. Australia$'
    Q8_OPT_D            DB 'D. Europe$'
    Q8_ANSWER           DB 2
    
    Q9_TEXT             DB 'What is the binary equivalent of decimal 10?$'
    Q9_OPT_A            DB 'A. 1110$'
    Q9_OPT_B            DB 'B. 1001$'
    Q9_OPT_C            DB 'C. 1010$'
    Q9_OPT_D            DB 'D. 1100$'
    Q9_ANSWER           DB 3
    
    Q10_TEXT            DB 'Which country hosted the 2024 Summer Olympics?$'
    Q10_OPT_A           DB 'A. Japan$'
    Q10_OPT_B           DB 'B. France$'
    Q10_OPT_C           DB 'C. USA$'
    Q10_OPT_D           DB 'D. Australia$'
    Q10_ANSWER          DB 2
    
    QUESTION_TABLE      DW OFFSET Q1_TEXT, OFFSET Q1_OPT_A, OFFSET Q1_OPT_B, OFFSET Q1_OPT_C, OFFSET Q1_OPT_D, OFFSET Q1_ANSWER
                        DW OFFSET Q2_TEXT, OFFSET Q2_OPT_A, OFFSET Q2_OPT_B, OFFSET Q2_OPT_C, OFFSET Q2_OPT_D, OFFSET Q2_ANSWER
                        DW OFFSET Q3_TEXT, OFFSET Q3_OPT_A, OFFSET Q3_OPT_B, OFFSET Q3_OPT_C, OFFSET Q3_OPT_D, OFFSET Q3_ANSWER
                        DW OFFSET Q4_TEXT, OFFSET Q4_OPT_A, OFFSET Q4_OPT_B, OFFSET Q4_OPT_C, OFFSET Q4_OPT_D, OFFSET Q4_ANSWER
                        DW OFFSET Q5_TEXT, OFFSET Q5_OPT_A, OFFSET Q5_OPT_B, OFFSET Q5_OPT_C, OFFSET Q5_OPT_D, OFFSET Q5_ANSWER
                        DW OFFSET Q6_TEXT, OFFSET Q6_OPT_A, OFFSET Q6_OPT_B, OFFSET Q6_OPT_C, OFFSET Q6_OPT_D, OFFSET Q6_ANSWER
                        DW OFFSET Q7_TEXT, OFFSET Q7_OPT_A, OFFSET Q7_OPT_B, OFFSET Q7_OPT_C, OFFSET Q7_OPT_D, OFFSET Q7_ANSWER
                        DW OFFSET Q8_TEXT, OFFSET Q8_OPT_A, OFFSET Q8_OPT_B, OFFSET Q8_OPT_C, OFFSET Q8_OPT_D, OFFSET Q8_ANSWER
                        DW OFFSET Q9_TEXT, OFFSET Q9_OPT_A, OFFSET Q9_OPT_B, OFFSET Q9_OPT_C, OFFSET Q9_OPT_D, OFFSET Q9_ANSWER
                        DW OFFSET Q10_TEXT, OFFSET Q10_OPT_A, OFFSET Q10_OPT_B, OFFSET Q10_OPT_C, OFFSET Q10_OPT_D, OFFSET Q10_ANSWER
    
    TEMP_VAR            DB ?
    OPTION_HIDE_ARR     DB 4 DUP(0)
    USER_ANSWER         DB ?

.CODE  
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    DISPLAY_MESSAGE GREETING_MSG     ; Welcome mssg
    
    CALL USER_LOGIN   ; Jump to 234
    
    MAIN_MENU_LOOP:
        CALL CLEAR_SCREEN
        CALL DISPLAY_MENU
        
        MOV AH, 1
        INT 21H
        SUB AL, '0'
        
        CMP AL, 1
        JE BEGIN_GAME
        CMP AL, 2
        JE VIEW_INSTRUCTIONS
        CMP AL, 3
        JE QUIT_GAME
        
        JMP MAIN_MENU_LOOP
        
    BEGIN_GAME:
        CALL GAME_SESSION  ; Jump to 732
        JMP MAIN_MENU_LOOP
        
    VIEW_INSTRUCTIONS:
        CALL DISPLAY_INSTRUCTIONS    ; Jump to 692
        JMP MAIN_MENU_LOOP
        
    QUIT_GAME:
        DISPLAY_MESSAGE GOODBYE_MSG   ; EXIT 
        MOV AX, 4C00H
        INT 21H
MAIN ENDP

USER_LOGIN PROC
    CALL CLEAR_SCREEN
    
    DISPLAY_MESSAGE AUTH_TITLE
    DISPLAY_MESSAGE PLAYER_ONE_LABEL
    LINE_BREAK
    MOV CURRENT_PLAYER_ID, 1
    CALL LOGIN_REGISTER_PROCESS
    
    WAIT_FOR_KEY CONTINUE_PROMPT
    
    CALL CLEAR_SCREEN
    
    DISPLAY_MESSAGE AUTH_TITLE
    DISPLAY_MESSAGE PLAYER_TWO_LABEL
    LINE_BREAK
    MOV CURRENT_PLAYER_ID, 2
    CALL LOGIN_REGISTER_PROCESS
    
    DISPLAY_MESSAGE AUTH_SUCCESS
    WAIT_FOR_KEY CONTINUE_PROMPT
    
    RET
USER_LOGIN ENDP

LOGIN_REGISTER_PROCESS PROC
    PUSH CX
    PUSH AX
    
    LOGIN_REGISTER_MENU_LOOP:
        DISPLAY_MESSAGE LOGIN_MENU_PROMPT
        MOV AH, 1
        INT 21H
        SUB AL, '0'
        
        CMP AL, 1
        JE HANDLE_LOGIN
        CMP AL, 2
        JE HANDLE_REGISTER
        
        LINE_BREAK
        DISPLAY_MESSAGE INVALID_CHOICE
        JMP LOGIN_REGISTER_MENU_LOOP
        
    HANDLE_LOGIN:
        CMP CURRENT_PLAYER_ID, 1
        JE CHECK_P1_REGISTERED
        JNE CHECK_P2_REGISTERED
        
    CHECK_P1_REGISTERED:
        CMP PLAYER1_REGISTERED, 0
        JE NOT_REGISTERED_MSG
        JMP PERFORM_LOGIN
        
    CHECK_P2_REGISTERED:
        CMP PLAYER2_REGISTERED, 0
        JE NOT_REGISTERED_MSG
        JMP PERFORM_LOGIN
        
    NOT_REGISTERED_MSG:
        DISPLAY_MESSAGE REGISTER_FIRST_MSG
        WAIT_FOR_KEY CONTINUE_PROMPT
        JMP LOGIN_REGISTER_MENU_LOOP
        
    PERFORM_LOGIN:
        CALL CLEAR_SCREEN
        print 'LOGIN'
        LINE_BREAK
        print '----------'
        LINE_BREAK
        CMP CURRENT_PLAYER_ID, 1
        JE DISPLAY_P1_LABEL
        DISPLAY_MESSAGE PLAYER_TWO_LABEL
        JMP CONTINUE_LOGIN_DISPLAY
    DISPLAY_P1_LABEL:
        DISPLAY_MESSAGE PLAYER_ONE_LABEL
    CONTINUE_LOGIN_DISPLAY:
        LINE_BREAK
        
        LOGIN_ATTEMPT_LOOP:
            DISPLAY_MESSAGE USER_PROMPT
            LEA SI, USER_INPUT_BUF
            CALL GET_INPUT_STRING
            
            DISPLAY_MESSAGE PW_PROMPT
            LEA SI, PASS_INPUT_BUF
            CALL GET_INPUT_STRING
            
            LEA SI, USER_INPUT_BUF
            CMP CURRENT_PLAYER_ID, 1
            JE P1_CRED_CHECK
            LEA DI, PLAYER2_USER
            JMP COMPARE_USERNAME
        P1_CRED_CHECK:
            LEA DI, PLAYER1_USER
        COMPARE_USERNAME:
            CALL COMPARE_STRINGS
            CMP AL, 1
            JNE AUTH_FAILURE
            
            LEA SI, PASS_INPUT_BUF
            CMP CURRENT_PLAYER_ID, 1
            JE P1_PASS_CHECK
            LEA DI, PLAYER2_PASS
            JMP COMPARE_PASSWORD
        P1_PASS_CHECK:
            LEA DI, PLAYER1_PASS
        COMPARE_PASSWORD:
            CALL COMPARE_STRINGS
            CMP AL, 1
            JNE AUTH_FAILURE
            
            DISPLAY_MESSAGE AUTH_SUCCESS
            JMP LOGIN_DONE
            
        AUTH_FAILURE:
            DISPLAY_MESSAGE AUTH_FAIL
            WAIT_FOR_KEY CONTINUE_PROMPT
            JMP LOGIN_REGISTER_MENU_LOOP
            
    HANDLE_REGISTER:
        CALL REGISTER_PLAYER
        JMP LOGIN_REGISTER_MENU_LOOP
        
    LOGIN_DONE:
        POP AX
        POP CX
        RET
LOGIN_REGISTER_PROCESS ENDP

GET_INPUT_STRING PROC  
    PUSH SI
    MOV DI, SI
    MOV CX, 0
    
    MOV BX, 20
    CLEAR_BUFFER_LOOP:
        MOV BYTE PTR [SI], 0
        INC SI
        DEC BX
        JNZ CLEAR_BUFFER_LOOP
    
    MOV SI, DI
    
    INPUT_LOOP:
        MOV AH, 1
        INT 21H
        
        CMP AL, 0DH
        JE END_INPUT
        
        CMP AL, 08H
        JE HANDLE_BACKSPACE
        
        CMP CX, 19
        JGE INPUT_LOOP
        
        MOV [SI], AL
        INC SI
        INC CX
        JMP INPUT_LOOP
        
    HANDLE_BACKSPACE:
        CMP CX, 0
        JE INPUT_LOOP
        DEC SI
        MOV BYTE PTR [SI], 0
        DEC CX
        
        MOV AH, 2
        MOV DL, 08H
        INT 21H
        MOV DL, 20H
        INT 21H
        MOV DL, 08H
        INT 21H
        JMP INPUT_LOOP
        
    END_INPUT:
        MOV BYTE PTR [SI], 0
        POP SI
        RET
GET_INPUT_STRING ENDP

COMPARE_STRINGS PROC
    PUSH CX
    PUSH SI
    PUSH DI
    PUSH BX
    
    COMPARE_LOOP:
        MOV AL, [SI]
        MOV BL, [DI]
        
        CMP AL, 'a'
        JL SKIP_UPPER1
        CMP AL, 'z'
        JG SKIP_UPPER1
        SUB AL, 32
    SKIP_UPPER1:
        
        CMP BL, 'a'
        JL SKIP_UPPER2
        CMP BL, 'z'
        JG SKIP_UPPER2
        SUB BL, 32
    SKIP_UPPER2:
        
        CMP AL, 0
        JE STR1_END
        
        CMP AL, BL
        JNE STRINGS_DIFFERENT
        
        INC SI
        INC DI
        JMP COMPARE_LOOP
        
    STR1_END:
        CMP BL, 0
        JNE STRINGS_DIFFERENT
        
        MOV AL, 1
        JMP COMPARE_DONE
        
    STRINGS_DIFFERENT:
        MOV AL, 0
        
    COMPARE_DONE:
        POP BX
        POP DI
        POP SI
        POP CX
        RET
COMPARE_STRINGS ENDP

COPY_STRING PROC
    PUSH AX
    PUSH CX
    PUSH SI
    PUSH DI
    PUSH BX
    
    MOV BX, DI
    MOV CX, 20
    CLEAR_DEST:
        MOV BYTE PTR [BX], 0
        INC BX
        LOOP CLEAR_DEST
    
    COPY_LOOP:
        MOV AL, [SI]
        MOV [DI], AL
        
        CMP AL, 0
        JE COPY_DONE
        
        INC SI
        INC DI
        JMP COPY_LOOP
        
    COPY_DONE:
        POP BX
        POP DI
        POP SI
        POP CX
        POP AX
        RET
COPY_STRING ENDP

REGISTER_PLAYER PROC
    CALL CLEAR_SCREEN
    
    print 'REGISTRATION'
    LINE_BREAK
    print '------------'
    LINE_BREAK
    
    CMP CURRENT_PLAYER_ID, 1
    JE SHOW_P1_REG
    DISPLAY_MESSAGE PLAYER_TWO_LABEL
    JMP CONTINUE_REG
SHOW_P1_REG:
    DISPLAY_MESSAGE PLAYER_ONE_LABEL
    
CONTINUE_REG:
    LINE_BREAK
    
GET_USERNAME_REG:
    DISPLAY_MESSAGE USER_PROMPT
    LEA SI, USER_INPUT_BUF
    CALL GET_INPUT_STRING
    
    CMP BYTE PTR [USER_INPUT_BUF], 0
    JE USERNAME_EMPTY
    
    LEA SI, USER_INPUT_BUF
    MOV CX, 0
    COUNT_USERNAME:
        CMP BYTE PTR [SI], 0
        JE CHECK_USERNAME_LENGTH
        INC SI
        INC CX
        JMP COUNT_USERNAME
    
    CHECK_USERNAME_LENGTH:
        CMP CX, 3
        JL USERNAME_TOO_SHORT
        JMP USERNAME_OK
    
    USERNAME_EMPTY:
        DISPLAY_MESSAGE USERNAME_EMPTY_MSG
        JMP GET_USERNAME_REG
    
    USERNAME_TOO_SHORT:
        DISPLAY_MESSAGE USERNAME_SHORT_MSG
        JMP GET_USERNAME_REG
    
USERNAME_OK:
GET_PASSWORD_REG:
    DISPLAY_MESSAGE PW_PROMPT
    LEA SI, PASS_INPUT_BUF
    CALL GET_INPUT_STRING
    
    CMP BYTE PTR [PASS_INPUT_BUF], 0
    JE PASSWORD_EMPTY
    
    LEA SI, PASS_INPUT_BUF
    MOV CX, 0
    COUNT_PASSWORD:
        CMP BYTE PTR [SI], 0
        JE CHECK_PASSWORD_LENGTH
        INC SI
        INC CX
        JMP COUNT_PASSWORD
    
    CHECK_PASSWORD_LENGTH:
        CMP CX, 4
        JL PASSWORD_TOO_SHORT
        JMP PASSWORD_OK
    
    PASSWORD_EMPTY:
        DISPLAY_MESSAGE PASSWORD_EMPTY_MSG
        JMP GET_PASSWORD_REG
    
    PASSWORD_TOO_SHORT:
        DISPLAY_MESSAGE PASSWORD_SHORT_MSG
        JMP GET_PASSWORD_REG
        
PASSWORD_OK:
    CMP CURRENT_PLAYER_ID, 1
    JNE SAVE_P2_CREDENTIALS
    
    LEA SI, USER_INPUT_BUF
    LEA DI, PLAYER1_USER
    CALL COPY_STRING
    
    LEA SI, PASS_INPUT_BUF
    LEA DI, PLAYER1_PASS
    CALL COPY_STRING
    
    MOV PLAYER1_REGISTERED, 1
    JMP REG_SUCCESS
    
SAVE_P2_CREDENTIALS:
    LEA SI, USER_INPUT_BUF
    LEA DI, PLAYER2_USER
    CALL COPY_STRING
    
    LEA SI, PASS_INPUT_BUF
    LEA DI, PLAYER2_PASS
    CALL COPY_STRING
    
    MOV PLAYER2_REGISTERED, 1
    
REG_SUCCESS:
    DISPLAY_MESSAGE REG_SUCCESS_MSG
    WAIT_FOR_KEY CONTINUE_PROMPT
    
    RET
REGISTER_PLAYER ENDP

DISPLAY_P1_USERNAME PROC
    PUSH AX
    PUSH DX
    PUSH SI
    
    LEA SI, PLAYER1_USER
    DISPLAY_USERNAME_LOOP1:
        MOV AL, [SI]
        CMP AL, 0
        JE END_USERNAME_DISPLAY1
        
        MOV AH, 2
        MOV DL, AL
        INT 21H
        INC SI
        JMP DISPLAY_USERNAME_LOOP1
    
    END_USERNAME_DISPLAY1:
        POP SI
        POP DX
        POP AX
        RET
DISPLAY_P1_USERNAME ENDP

DISPLAY_P2_USERNAME PROC
    PUSH AX
    PUSH DX
    PUSH SI
    
    LEA SI, PLAYER2_USER
    DISPLAY_USERNAME_LOOP2:
        MOV AL, [SI]
        CMP AL, 0
        JE END_USERNAME_DISPLAY2
        
        MOV AH, 2
        MOV DL, AL
        INT 21H
        INC SI
        JMP DISPLAY_USERNAME_LOOP2
    
    END_USERNAME_DISPLAY2:
        POP SI
        POP DX
        POP AX
        RET
DISPLAY_P2_USERNAME ENDP

DISPLAY_CURRENT_PLAYER_USERNAME PROC
    CMP CURRENT_PLAYER_ID, 1
    JE DISPLAY_P1_NAME       ; Jump to 669
    CALL DISPLAY_P2_USERNAME  ; Jump to 66
    JMP END_CURRENT_DISPLAY  ; Jump to 671
DISPLAY_P1_NAME:
    CALL DISPLAY_P1_USERNAME  ;Jump to 616
END_CURRENT_DISPLAY:
    RET
DISPLAY_CURRENT_PLAYER_USERNAME ENDP

CLEAR_SCREEN PROC
    MOV AH, 0
    MOV AL, 3         ; CLEAR SCREEN 
    INT 10H   ; BIOS reinitializes the screen to the 80x25 text mode. This re-initialization process effectively erases all characters from the display and places the cursor at the top-left corner (position 0,0).
    RET
CLEAR_SCREEN ENDP  

DISPLAY_MENU PROC
    DISPLAY_MESSAGE MENU_HEADING
    DISPLAY_MESSAGE MENU_OPTION1
    DISPLAY_MESSAGE MENU_OPTION2
    DISPLAY_MESSAGE MENU_OPTION3
    DISPLAY_MESSAGE MENU_CHOICE_PROMPT
    
    RET
DISPLAY_MENU ENDP

DISPLAY_INSTRUCTIONS PROC
    CALL CLEAR_SCREEN
    
    DISPLAY_MESSAGE GAME_RULES
    
    WAIT_FOR_KEY CONTINUE_PROMPT
    
    RET
DISPLAY_INSTRUCTIONS ENDP

GAME_SESSION PROC                ;---------------------- GAME SESSION ----------------------
    MOV SCORE_P1, 0              ; Scores are initialized to 0 for PLAYER 1.
    MOV SCORE_P2, 0              ; Scores are initialized to 0 for PLAYER 2.
    MOV LIFELINE_P1, 3
    MOV LIFELINE_P2, 3
    MOV CURRENT_PLAYER_ID, 1   ; To keep track who's turn it is
    MOV GAME_LEVEL, 1
    MOV CURRENT_Q_INDEX, 1
    MOV LIFELINE_ACTIVE, 0
    
    GAME_LOOP:
        CMP CURRENT_Q_INDEX, 11    ; Highest count of question is 10. 
        JAE END_SESSION          ; If it is equal or greater than 11, Jump to 864
        
        CALL CLEAR_SCREEN
        
        DISPLAY_MESSAGE P_MSG
        CALL DISPLAY_CURRENT_PLAYER_USERNAME   ; Jump to 664, print current player username
        
        LINE_BREAK
        
        DISPLAY_MESSAGE L_MSG       ; Print Level number
        MOV AH, 2
        MOV DL, GAME_LEVEL
        ADD DL, '0'
        INT 21H
        
        LINE_BREAK
        DISPLAY_MESSAGE LIFELINE_COUNT    ; Print remaining lifeline count
        
        CMP CURRENT_PLAYER_ID, 1   ; CURRENT_PLAYER_ID is set 1 for Player 1
        JNE SHOW_P2_STATS        ; If it is not equal to 1, Jump to 747
                                    
        MOV AH, 2
        MOV DL, LIFELINE_P1
        ADD DL, '0'
        INT 21H                              ; SHOW PLAYER 1 STATS
        
        DISPLAY_MESSAGE SCORE_MSG
        MOV AH, 02                               ; Score display for PLAYER 1 above the quiz question
        MOV DL, SCORE_P1
        ADD DL, '0'
        INT 21H
        JMP QUESTION_SECTION_START     ; Jump to 759
        
    SHOW_P2_STATS:
        MOV AH, 2
        MOV DL, LIFELINE_P2
        ADD DL, '0'                              ; SHOW PLAYER 3 STATS
        INT 21H
        
        DISPLAY_MESSAGE SCORE_MSG
        MOV AH, 2                          ; Score display for PLAYER 2 above the quiz question
        MOV DL, SCORE_P2
        ADD DL, '0'
        INT 21H
        
    QUESTION_SECTION_START:
        LINE_BREAK
        
        CALL DISPLAY_QUESTION     ;jump to 934
        
        CMP CURRENT_PLAYER_ID, 1
        JNE CHECK_P2_LIFELINE     ; Jump to 794, means it is PLAYER 2, check PLAYER 2' lifeline. 
        
        CMP LIFELINE_P1, 0    ; means no lifeline is left for use, the game will proceed without asking for lifeline. 
        JE NO_LIFELINE     ; Jump to 822, otherwise skip this line. 
        
    P1_LIFELINE_PROMPT_LOOP:
        DISPLAY_MESSAGE LIFELINE_PROMPT        ; use LIFELINE_PROMPT [Player 1]
        MOV AH, 1
        INT 21H                   ; user input [Player 1]
        SUB AL, '0'
        
        CMP AL, 0         ; if 50:50 lifeline set to 0, no option will be erased
        JE NO_LIFELINE    ; Jump to 822 [Player 1]
        CMP AL, 1          ; if 50:50 lifeline set to 0, it will remove two incorrect options
        JE USE_P1_LIFELINE      ;jump to 785 [Player 1]
        
        LINE_BREAK
        DISPLAY_MESSAGE INVALID_CHOICE
        JMP P1_LIFELINE_PROMPT_LOOP      ;If the choice other than 0 and 1, it will jump to the loop again
    
    USE_P1_LIFELINE:
        DEC LIFELINE_P1      ; Lifeline decresed by one [Player 1]
        MOV LIFELINE_ACTIVE, 1    ;LIFELINE_ACTIVE is set to 1, means LIFELINE_ACTIVE is in use.
        DISPLAY_MESSAGE LIFELINE_USED_MSG
        CALL CLEAR_SCREEN     ; clear the screen
        CALL DISPLAY_QUESTION        ; Jump to 934
        
        JMP GET_ANSWER_SECTION  ;jump to 826, option will be removed here. 
        
    CHECK_P2_LIFELINE:
        CMP LIFELINE_P2, 0  ;means no lifeline is left for use, the game will proceed without asking for lifeline.
        JE NO_LIFELINE     ; Jump to 822, otherwise skip this line. 
        
    P2_LIFELINE_PROMPT_LOOP:
        DISPLAY_MESSAGE LIFELINE_PROMPT    ; use LIFELINE_PROMPT [Player 2]
        MOV AH, 1
        INT 21H                      ; user input [Player 1]
        SUB AL, '0'
        
        CMP AL, 0          ; if 50:50 lifeline set to 0, no option will be erased
        JE NO_LIFELINE    ;jump to 822 [Player 2]
        CMP AL, 1               ; if 50:50 lifeline set to 0, it will remove two incorrect options
        JE USE_P2_LIFELINE        ;jump to 785 [Player 2]
        
        LINE_BREAK
        DISPLAY_MESSAGE INVALID_CHOICE     ; Invalid message
        JMP P2_LIFELINE_PROMPT_LOOP         ;If the choice is invalid, it will jump to the loop again
        
    USE_P2_LIFELINE:
        DEC LIFELINE_P2    ; Lifeline decresed by one [Player 2]
        MOV LIFELINE_ACTIVE, 1         ;LIFELINE_ACTIVE is set to 1, means LIFELINE_ACTIVE is in use.
        DISPLAY_MESSAGE LIFELINE_USED_MSG  ;will show "Lifeline used! Two wrong options have been removed."
        CALL CLEAR_SCREEN               ; clear the screen
        CALL DISPLAY_QUESTION        ;jump to 934
        
        JMP GET_ANSWER_SECTION   ;jump to 826
        
    NO_LIFELINE:
        MOV LIFELINE_ACTIVE, 0   ;Lifeline not in use, proceed to the answer part
        
    GET_ANSWER_SECTION:
        CALL GET_PLAYER_ANSWER   ;jump to 1059
        
        CALL VERIFY_ANSWER   ;jump to 1099
        
        MOV LIFELINE_ACTIVE, 0
        CALL CLEAR_HIDDEN_OPTIONS_PROC   ;jump to 1139
        
        INC CURRENT_Q_INDEX   ;Move to the next question index
        
        CMP CURRENT_PLAYER_ID, 1
        JNE SWITCH_TO_PLAYER1     ;jump to 841
        
        MOV CURRENT_PLAYER_ID, 2
        JMP PLAYER_CHANGED       ;jump to 858
    
    SWITCH_TO_PLAYER1:
        MOV CURRENT_PLAYER_ID, 1
        
        MOV AL, GAME_LEVEL
        INC AL
        MOV GAME_LEVEL, AL
        
        PUSH AX
        LINE_BREAK
        DISPLAY_MESSAGE NEXTLEVEL_MSG
        
        MOV AH, 2
        MOV DL, GAME_LEVEL
        ADD DL, '0'
        INT 21H
        POP AX
    
    PLAYER_CHANGED:
        DISPLAY_MESSAGE NEXT_TURN_MSG
        WAIT_FOR_KEY CONTINUE_PROMPT
        
        JMP GAME_LOOP  ;jump to 712
    
    END_SESSION:
        CALL CLEAR_SCREEN         ; clear the screen 
        
        DISPLAY_MESSAGE GOODBYE_MSG
        
        LINE_BREAK
        print '--- Final Scores ---'
        
        SHOW_SCORES:
            LINE_BREAK
            CALL DISPLAY_P1_USERNAME
            print ' score: '
            
            MOV AH, 2
            MOV DL, SCORE_P1
            ADD DL, '0'
            INT 21H
            
            LINE_BREAK
            
            CALL DISPLAY_P2_USERNAME
            print ' score: '
            
            MOV AH, 2
            MOV DL, SCORE_P2
            ADD DL, '0'
            INT 21H
                                    
        MOV AL, SCORE_P1
        CMP AL, SCORE_P2
        JG P1_WINS    ; Jump to 901 ; if greater, p1 wins 
        JL P2_WINS     ; Jump to 907 ; if less, p2 wins 
        
        LINE_BREAK
        print 'It is a draw!'   ; Otherwise, draw
        JMP END_GAME_FINAL    ; Jump to 912
        
    P1_WINS:
        LINE_BREAK
        DISPLAY_MESSAGE WINNER_MESSAGE
        CALL DISPLAY_P1_USERNAME
        JMP END_GAME_FINAL
    
    P2_WINS:
        LINE_BREAK
        DISPLAY_MESSAGE WINNER_MESSAGE
        CALL DISPLAY_P2_USERNAME
    
    END_GAME_FINAL:
        LINE_BREAK
        print 'Play again? (0=No, 1=Yes) : '
        MOV AH, 1
        INT 21H
        SUB AL, '0'
        
        CMP AL, 1          ; if 1 selected, restart the game 
        JE RESTART_GAME_SESSION  ; Jump to 924
        
        JMP EXIT_GAME     ; If 0 selected, exit the game (Jump to 927)
        
    RESTART_GAME_SESSION:  
        RET                ; Return to Game session --> 702 
    
    EXIT_GAME:
        MOV AX, 4C00H
        INT 21H
        
        RET
GAME_SESSION ENDP

DISPLAY_QUESTION PROC
    
    MOV AL, CURRENT_Q_INDEX      ; Current question 
    DEC AL          ; Decrease one to get the current question index (0-indexed)
    
    CMP AL, 9    ; Compare with the highest question index(9) 
    JLE Q_INDEX_OK ; If the question index is valid, jump to 943
    MOV AL, 9   ; If invalid, then set the question index to 9. 
    
    Q_INDEX_OK:
    
        MOV BL, 12   ; Per question uses 6 WORD, total size 12Bytes (question, 4 option, answer)
        MUL BL         ; Multiply with AX to get the offest of the question table. Here, AX stores the current index of the question. 
        MOV SI, AX   ; Move the offset value in SI
        
        MOV CX, QUESTION_TABLE[SI]     ;fetch the question, as the question is in first index of that index of question table,  
        MOV DX, CX
        MOV AH, 9                 ; Print the question
        INT 21H
        
        LINE_BREAK
        
        CMP LIFELINE_ACTIVE, 1        ; Check if the LIFELINE_ACTIVE is in active or not. 
        JE USE_LIFELINE_ON_DISPLAY   ; If yes, then jump to 960, will remove  
        JMP DISPLAY_OPTIONS_NORMAL     ; Otherwise, jump to 963, no remove 
    
    USE_LIFELINE_ON_DISPLAY:
        CALL USE_LIFELINE        ; Jump to 1011, gets 2 option [one correct{0}, one incorrect{1)] 
        
    DISPLAY_OPTIONS_NORMAL:
        CMP OPTION_HIDE_ARR[0], 1
        JE SKIP_OPT_A
        
        MOV CX, QUESTION_TABLE[SI+2]
        MOV DX, CX
        MOV AH, 9
        INT 21H
        
        LINE_BREAK
        
    SKIP_OPT_A:
            CMP OPTION_HIDE_ARR[1], 1
            JE SKIP_OPT_B
            
            MOV CX, QUESTION_TABLE[SI+4]
            MOV DX, CX
            MOV AH, 9
            INT 21H
            
            LINE_BREAK
    
    SKIP_OPT_B:
            CMP OPTION_HIDE_ARR[2], 1
            JE SKIP_OPT_C
            
            MOV CX, QUESTION_TABLE[SI+6]
            MOV DX, CX
            MOV AH, 9
            INT 21H
            
            LINE_BREAK
    
    SKIP_OPT_C:
            CMP OPTION_HIDE_ARR[3], 1
            JE SKIP_OPT_D
            
            MOV CX, QUESTION_TABLE[SI+8]
            MOV DX, CX
            MOV AH, 9
            INT 21H
            
            LINE_BREAK
    
    SKIP_OPT_D:
    RET             ; Jump back to 790
DISPLAY_QUESTION ENDP

USE_LIFELINE PROC
    MOV AL, CURRENT_Q_INDEX   ; Current question index
    DEC AL                ; Decrease one to get the current question index
    
    CMP AL, 9         ; Compare with the highest question index(9)
    JLE L_INDEX_OK ; Jump to 1019 
    MOV AL, 9           ; If invalid, then set the question index to 9.
            
    L_INDEX_OK:  
    MOV BL, 12      ; Per question uses 6 WORD, total size 12Bytes (quesrion, 4 option, answer)
    MUL BL          ; Multiply with AX to get the offest of the question table. Here, AX stores the current index of the question.
    MOV SI, AX         ; Move the offset value in SI, how far to move from the base to reach the current question.
    
    MOV BX, OFFSET QUESTION_TABLE  ; BX=loads the base offset of the QUESTION_TABLE, (starting point of the first record)
    MOV BX, [BX + SI + 10]    ;BX=base address, SI= start of that question’s record[Question] , +10 = OFFSET correct answer 
                               ; [BX + SI + 10] points to the stored offset of the correct answer for the current question. Storing it for hide two incorrect.
    XOR AH, AH              ; Clears AH
    MOV AL, [BX]     ; Reads the correct answer value from memory into AL. BX use as a pointer. 
    DEC AL            ; To get the index of the correct answer (0-indexed).
    MOV BL, AL          ; Copies the 0-indexed correct answer into BL for later use
    
    MOV BH, 0
    MOV BX, BX
    MOV OPTION_HIDE_ARR[BX], 0  ; OPTION_HIDE_ARR is an ARRAY representing which options are hidden (0 = visible, 1 = hidden).
                                  ; Setting the correct answer's index(BX) as 0, means visible.
    MOV CX, 2     ; we want to hide 2 wrong options. Will be used in a loop to randomly hide two other options other than the correct one.
    MOV DI, 0       ; loop counter for hiding options.
    
HIDE_LOOP:
    CMP DI, 4       ; Loop will occur till it's reaching 4 or more
    JGE HIDE_DONE      ; Jump to 1055
    
    CMP DI, BX          ; Compares current index DI with correct answer index BX.
    JE NEXT_OPTION_LIFELINE     ; Jump to 1051, equal means the correct answer, skip hiding it and jump to NEXT_OPTION_LIFELINE.
    
    MOV OPTION_HIDE_ARR[DI], 1    ; Marks this option as hidden in OPTION_HIDE_ARR.
    DEC CX              ;implicit loop, will run 2 times as CX set to 2. 
    CMP CX, 0
    JE HIDE_DONE    ; Jump to 1055
    
NEXT_OPTION_LIFELINE:
    INC DI           ; Jump to next option without hiding the correct one. 
    JMP HIDE_LOOP   ; Jump to 1039
    
HIDE_DONE:       ;OPTION_HIDE_ARR = [1, 0, 1, 0]  ; hidden = 1, visible = 0
    RET                ; Jump back to 961
USE_LIFELINE ENDP

GET_PLAYER_ANSWER PROC
    GET_CHOICE_LOOP:
        DISPLAY_MESSAGE ANSWER_PROMPT      ; Will ask 'Your answer (A/B/C/D):
        
        MOV AH, 1
        INT 21H                  ; PLAYER input will store in AL.
        MOV USER_ANSWER, AL       ; Answer move to USER_ANSWER
        
        CMP USER_ANSWER, 'a'   ; Checks if the input is a lowercase letter 'a'..'d'.
        JL VALIDATE_UPPER       ; Jump to 1073 
        CMP USER_ANSWER, 'd'   ; If greater than 'd', invalid.
        JG INVALID_INPUT          ; Jump to 1090 [INVALID]
        SUB USER_ANSWER, 32      ; Convert to upper case 
                            
    VALIDATE_UPPER:                  
        CMP USER_ANSWER, 'A'       ; Ensures the input is now a valid uppercase letter 'A'-'D'.
        JL INVALID_INPUT              ; Jump to 1090
        CMP USER_ANSWER, 'D'       ; Anything outside 'A'-'D' is rejected
        JG INVALID_INPUT            ; Jump to 1090 [INVALID]
        
        MOV AL, USER_ANSWER
        SUB AL, 'A'                 ; To deal with Lifeline feature.
        MOV BL, AL
        MOV BH, 0
        CMP OPTION_HIDE_ARR[BX], 1   ; If 1, this option is hidden due to a 50:50 lifeline
        JE INVALID_INPUT           ; Jump to 1090 [INVALID]
        
        SUB USER_ANSWER, 'A'
        INC USER_ANSWER           ; Increment to verify the answer, avoid 0-indexing
        JMP CHOICE_MADE             ; Jump to 1095
        
    INVALID_INPUT:
        LINE_BREAK
        DISPLAY_MESSAGE INVALID_CHOICE
        JMP GET_CHOICE_LOOP         ; Jump to 1060, from the first 
        
    CHOICE_MADE:             ; Successfully Selected option will return , in USER_ANSWER
        RET               ; Jump back to 827
GET_PLAYER_ANSWER ENDP

VERIFY_ANSWER PROC
    PUSH BX            ; Saves BX and DX registers on the stack, since they will be modified inside this procedure.
    PUSH DX           ; BX = pointer to find the correct answer in the QUESTION_TABLE , DX = hold and display the correct answer.
    
    MOV AL, CURRENT_Q_INDEX    ; Current question number 
    DEC AL            ; Current question index (0-indexed)
    
    MOV BL, 12
    MUL BL           ; OFFSET
    MOV SI, AX
    
    MOV BX, OFFSET QUESTION_TABLE      ; BX=Base address
    MOV BX, [BX+SI+10]              ; BX = Correct answer
    
    MOV DL, [BX]                 ; DL = Retrieves the correct answer from BX
    
    CMP DL, USER_ANSWER              ; Compare with the choice
    JNE HANDLE_WRONG_ANSWER       ; Jump to 1130
    
    DISPLAY_MESSAGE CORRECT_ANSWER_MSG
    
    CMP CURRENT_PLAYER_ID, 1
    JNE INC_P2_SCORE         ; Jump to 1127       
    
    INC SCORE_P1              ; PLAYER 1 score increment
    JMP ANSWER_HANDLED    ; Jump to 1133
    
INC_P2_SCORE:
    INC SCORE_P2             ; PLAYER 2 score increment
    JMP ANSWER_HANDLED      ; Jump to 1133
    
HANDLE_WRONG_ANSWER:
    DISPLAY_MESSAGE INCORRECT_ANSWER_MSG
    
ANSWER_HANDLED:
    POP DX
    POP BX
    RET            ; Jump back to 828
VERIFY_ANSWER ENDP  

CLEAR_HIDDEN_OPTIONS_PROC PROC
    MOV OPTION_HIDE_ARR[0], 0
    MOV OPTION_HIDE_ARR[1], 0
    MOV OPTION_HIDE_ARR[2], 0
    MOV OPTION_HIDE_ARR[3], 0
    
    RET                       ; Jump Back to 830
CLEAR_HIDDEN_OPTIONS_PROC ENDP

END MAIN

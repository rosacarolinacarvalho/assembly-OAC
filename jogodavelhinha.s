format ELF64 executable 3

segment readable executable
entry $

main:
    jmp RULES

; ----------- FUNÇÕES AUXILIARES -----------
print_string:
    mov edi, 1
    mov eax, 1
    syscall
    ret

read_input:
    mov edx, 16
    lea rsi, [IN_BUFFER]
    mov edi, 0
    mov eax, 0
    syscall
    mov al, byte [IN_BUFFER]
    mov byte [IN_CHAR], al
    ret

clear_screen:
    mov edx, ANSI_cls_len
    lea rsi, [ANSI_cls]
    call print_string
    ret

; ----------- REGRAS --------------                                                 
RULES:
    call clear_screen
    mov edx, R_len
    lea rsi, [R]
    call print_string
    mov edx, R1_len
    lea rsi, [R1]
    call print_string 
    mov edx, R2_len
    lea rsi, [R2]
    call print_string 
    mov edx, R3_len
    lea rsi, [R3]
    call print_string 
    mov edx, R4_len
    lea rsi, [R4]
    call print_string 
    mov edx, R5_len
    lea rsi, [R5]
    call print_string 
    mov edx, R6_len
    lea rsi, [R6]
    call print_string 
    mov edx, R7_len
    lea rsi, [R7]
    call print_string 
    mov edx, PAK_len
    lea rsi, [PAK]
    call print_string 
    call read_input 
    jmp INIT
 
; ---------- INICIALIZAÇÃO ---------------------
INIT: 
    mov byte [PLAYER], 49
    mov byte [CUR], 88         ; 'X'
    mov byte [MOVES], 0  
    mov byte [DONE], 0
    mov byte [DR], 0 
    mov byte [C1], '1'
    mov byte [C2], '2'
    mov byte [C3], '3'
    mov byte [C4], '4'
    mov byte [C5], '5'
    mov byte [C6], '6'
    mov byte [C7], '7'
    mov byte [C8], '8'
    mov byte [C9], '9'
    jmp BOARD

; ------------ VITÓRIA / EMPATE ------------
VICTORY:
    mov edx, BR_len
    lea rsi, [BR]
    call print_string
    mov edx, W1_len
    lea rsi, [W1]
    call print_string
    mov edx, 1
    lea rsi, [PLAYER]
    call print_string
    mov edx, W2_len
    lea rsi, [W2]
    call print_string
    mov edx, PAK_len
    lea rsi, [PAK]
    call print_string
    call read_input    
    jmp TRYAGAIN 
            
DRAW:
    mov edx, BR_len
    lea rsi, [BR]
    call print_string
    mov edx, DRW_len
    lea rsi, [DRW]
    call print_string 
    mov edx, PAK_len
    lea rsi, [PAK]
    call print_string
    call read_input    
    jmp TRYAGAIN                      

; ------------ CHECK LOGIC (OTIMIZADO) -----------
CHECK:
    lea rsi, [WIN_LINES]
    mov rcx, 8
CHECK_LOOP:
    movzx r8, byte [rsi]
    movzx r9, byte [rsi+1]
    movzx r10, byte [rsi+2]
    lea rbx, [C1]
    mov al, byte [rbx + r8]
    mov dl, byte [rbx + r9]
    mov ah, byte [rbx + r10]
    cmp al, dl
    jnz NEXT_LINE
    cmp dl, ah
    jnz NEXT_LINE
    mov byte [DONE], 1
    jmp BOARD
NEXT_LINE:
    add rsi, 3
    dec rcx
    jnz CHECK_LOOP
    
    mov al, [MOVES]
    cmp al, 9
    jb PLRCHANGE
    mov byte [DR], 1
    jmp BOARD

PLRCHANGE:
    cmp byte [PLAYER], 49
    jz SET_P2
    mov byte [PLAYER], 49
    mov byte [CUR], 88
    jmp BOARD
SET_P2:
    mov byte [PLAYER], 50
    mov byte [CUR], 79
    jmp BOARD

; ------------- RENDERIZAÇÃO (OTIMIZADA) ----------   
BOARD:
    call clear_screen
    mov edx, BR_len
    lea rsi, [BR]
    call print_string
    lea rsi, [BOARD_MAP]
    mov rbp, 3
RENDER_LOOP:
    lea rbx, [C1]
    movzx rax, byte [rsi]
    mov al, [rbx + rax]
    mov [L_C1], al
    movzx rax, byte [rsi+1]
    mov al, [rbx + rax]
    mov [L_C2], al
    movzx rax, byte [rsi+2]
    mov al, [rbx + rax]
    mov [L_C3], al

    push rsi
    mov edx, L_V_len
    lea rsi, [L_V]
    call print_string
    mov edx, LINE_LEN
    lea rsi, [LINE_STR]
    call print_string
    mov edx, L_V_len
    lea rsi, [L_V]
    call print_string
    pop rsi

    dec rbp
    jz FINISH_BOARD
    push rsi
    mov edx, L_DIV_len
    lea rsi, [L_DIV]
    call print_string
    pop rsi
    add rsi, 3
    jmp RENDER_LOOP

FINISH_BOARD:
    cmp byte [DONE], 1
    jz VICTORY
    cmp byte [DR], 1
    jz DRAW
    jmp INPUT

; ------------ INPUT (OTIMIZADO) --------------
INPUT:
    mov edx, TURN_1_len
    lea rsi, [TURN_1]
    call print_string
    mov edx, 1
    lea rsi, [CUR]
    call print_string
    mov edx, TURN_2_len
    lea rsi, [TURN_2]
    call print_string
        
    call read_input
    mov al, byte [IN_CHAR]
    sub al, 49               ; '1' -> 0
    js INVALID_INPUT
    cmp al, 8
    ja INVALID_INPUT
    
    movzx rax, al
    lea rbx, [C1]
    cmp byte [rbx + rax], 88
    jz TAKEN
    cmp byte [rbx + rax], 79
    jz TAKEN 
    
    inc byte [MOVES]
    mov cl, byte [CUR] 
    mov byte [rbx + rax], cl
    jmp CHECK
    
INVALID_INPUT:
    mov edx, WI_len
    lea rsi, [WI]
    call print_string
    call read_input
    jmp BOARD
        
TAKEN:
    mov edx, TKN_len
    lea rsi, [TKN]
    call print_string  
    call read_input
    jmp BOARD

TRYAGAIN:
    call clear_screen
    mov edx, TRA_len
    lea rsi, [TRA]
    call print_string
    call read_input
    mov al, byte [IN_CHAR]
    cmp al, 'y'
    jz INIT 
    cmp al, 'Y'
    jz INIT
    cmp al, 's'
    jz INIT
    cmp al, 'S'
    jz INIT
    jmp EXIT

EXIT:
    mov edi, 0
    mov eax, 60
    syscall 

segment readable writeable

WIN_LINES db 0,1,2, 3,4,5, 6,7,8, 0,3,6, 1,4,7, 2,5,8, 0,4,8, 2,4,6
BOARD_MAP db 0,1,2, 3,4,5, 6,7,8

LINE_STR  db "  "
L_C1      db " "
          db "  |  "
L_C2      db " "
          db "  |  "
L_C3      db " "
          db "  ", 0x0A
LINE_LEN  = $ - LINE_STR

ANSI_cls     db 0x1B, "[2J", 0x1B, "[H"
ANSI_cls_len = $ - ANSI_cls
BR           db 0x0A
BR_len       = $ - BR
L_V          db "     |     |     ", 0x0A
L_V_len      = $ - L_V
L_DIV        db "-----+-----+-----", 0x0A
L_DIV_len    = $ - L_DIV

PAK db "Pressione ENTER para continuar...", 0x0A
PAK_len = $ - PAK
R   db "Regras do Jogo:", 0x0A
R_len = $ - R
R1  db "1. Os jogadores jogam alternadamente.", 0x0A
R1_len = $ - R1
R2  db "2. O Jogador 1 inicia a partida.", 0x0A
R2_len = $ - R2
R3  db "3. Jogador 1 usa 'X' e o Jogador 2 usa 'O'.", 0x0A
R3_len = $ - R3
R4  db "4. O tabuleiro esta marcado com os numeros das celulas.", 0x0A
R4_len = $ - R4
R5  db "5. Digite o NUMERO DA CELULA para fazer sua jogada.", 0x0A
R5_len = $ - R5
R6  db "6. Complete 3 marcas em linha, coluna ou diagonal para vencer.", 0x0A
R6_len = $ - R6
R7  db "Boa Sorte!", 0x0A
R7_len = $ - R7

C1 db '1'
C2 db '2'
C3 db '3'
C4 db '4'
C5 db '5'
C6 db '6'
C7 db '7'
C8 db '8'
C9 db '9'

PLAYER db 49
MOVES  db 0
DONE   db 0
DR     db 0 
CUR    db 88
TURN_1   db "Vez do "
TURN_1_len = $ - TURN_1
TURN_2   db ". Escolha uma celula: "
TURN_2_len = $ - TURN_2
TKN db "Esta celula ja foi ocupada! Pressione ENTER...", 0x0A
TKN_len = $ - TKN 
W1 db "Jogador "
W1_len = $ - W1
W2 db " venceu o jogo!", 0x0A
W2_len = $ - W2
DRW db "O jogo terminou em EMPATE!", 0x0A
DRW_len = $ - DRW
TRA db "Deseja jogar novamente? (s/n): "
TRA_len = $ - TRA
WI db "Entrada invalida! Pressione ENTER...", 0x0A
WI_len = $ - WI
IN_CHAR   db 0
IN_BUFFER rb 16

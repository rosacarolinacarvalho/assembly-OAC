format ELF64 executable 3

segment readable executable
entry $

main:
    jmp RULES    ; Pula diretamente para as Regras

; ----------- FUNÇÕES AUXILIARES DE SISTEMA -----------
print_string:
    mov edi, 1   ; stdout
    mov eax, 1   ; sys_write
    syscall
    ret

read_input:
    mov edx, 16
    lea rsi, [IN_BUFFER]
    mov edi, 0   ; stdin
    mov eax, 0   ; sys_read
    syscall
    mov al, byte [IN_BUFFER]
    mov byte [IN_CHAR], al
    ret

clear_screen:
    mov edx, ANSI_cls_len
    lea rsi, [ANSI_cls]
    call print_string
    ret

; ----------- EXIBIÇÃO DAS REGRAS DO JOGO --------------                                                 
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
 
; ---------- INICIALIZAÇÃO DO TABULEIRO ---------------------
INIT: 
    mov byte [PLAYER], 49      ; Define Jogador 1 ('1')
    mov byte [CUR], 88         ; Define símbolo inicial como 'X'
    mov byte [MOVES], 0  
    mov byte [DONE], 0
    mov byte [DR], 0 
            
    mov byte [C1], 49          ; Reinicia as células ('1'-'9')
    mov byte [C2], 50
    mov byte [C3], 51
    mov byte [C4], 52
    mov byte [C5], 53
    mov byte [C6], 54
    mov byte [C7], 55
    mov byte [C8], 56
    mov byte [C9], 57
                                     
    jmp BOARD

; ------------ TELA DE VITÓRIA ------------------------
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
            
; ------------ TELA DE EMPATE ------------  
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

; ------------ VERIFICAÇÃO DAS CONDIÇÕES DE VITÓRIA -----------

;aterado Rosa
CHECK:
    lea rsi, [WIN_LINES]  ; RSI agora aponta para o nosso "gabarito" de vitórias
    mov rcx, 8            ; RCX será nosso contador de loop (temos 8 chances de ganhar)

CHECK_LOOP:
    ; Passo A: Lemos os 3 índices da combinação atual
    movzx r8, byte [rsi]     ; Pega o 1º índice (ex: 0)
    movzx r9, byte [rsi+1]   ; Pega o 2º índice (ex: 1)
    movzx r10, byte [rsi+2]  ; Pega o 3º índice (ex: 2)

    ; Passo B: Usamos esses índices para ler o tabuleiro real
    lea rbx, [C1]            ; RBX aponta para o início do tabuleiro (C1)
    mov al, byte [rbx + r8]  ; AL recebe o valor do tabuleiro no índice 1
    mov dl, byte [rbx + r9]  ; DL recebe o valor do tabuleiro no índice 2
    mov ah, byte [rbx + r10] ; AH recebe o valor do tabuleiro no índice 3

    ; Passo C: Comparamos os 3 valores (exatamente como você fazia antes)
    cmp al, dl
    jnz NEXT_LINE            ; Se falhar, pula para testar a próxima combinação
    cmp dl, ah
    jnz NEXT_LINE            ; Se falhar, pula para a próxima

    ; Se sobreviveu aos pulos acima, alguém venceu!
    mov byte [DONE], 1
    jmp BOARD

NEXT_LINE:
    add rsi, 3            ; Avança o ponteiro RSI em 3 bytes (para a próxima linha do gabarito)
    dec rcx               ; Diminui nosso contador de 8 para 7, 6...
    jnz CHECK_LOOP        ; Se o contador não for Zero, volta para CHECK_LOOP

    ; Se o contador chegou a zero e não pulou para BOARD, checa empate
    jmp DRAWCHECK
            
    DRAWCHECK:
        mov al, [MOVES]
        cmp al, 9
        jb PLRCHANGE
        mov byte [DR], 1
        jmp BOARD
;alterado até aqui Rosa

; ------------ ALTERNÂNCIA DE JOGADOR ----------        
PLRCHANGE:
    cmp byte [PLAYER], 49
    jz SET_P2
    
    mov byte [PLAYER], 49
    mov byte [CUR], 88     ; 'X'
    jmp BOARD
         
    SET_P2:
        mov byte [PLAYER], 50
        mov byte [CUR], 79     ; 'O'
        jmp BOARD

; ------------- RENDERIZAÇÃO DO TABULEIRO (ESTILO GITHUB) ----------   
BOARD: 
    call clear_screen

    mov edx, BR_len
    lea rsi, [BR]
    call print_string

    ; Bloco Superior
    mov edx, L_V_len
    lea rsi, [L_V]
    call print_string
    mov al, [C1]
    mov [L_V_C1], al
    mov al, [C2]
    mov [L_V_C2], al
    mov al, [C3]
    mov [L_V_C3], al
    mov edx, L_VALS_len
    lea rsi, [L_VALS]
    call print_string
    mov edx, L_V_len
    lea rsi, [L_V]
    call print_string

    ; Divisória 1
    mov edx, L_DIV_len
    lea rsi, [L_DIV]
    call print_string

    ; Bloco Central
    mov edx, L_V_len
    lea rsi, [L_V]
    call print_string
    mov al, [C4]
    mov [L_V_C1], al
    mov al, [C5]
    mov [L_V_C2], al
    mov al, [C6]
    mov [L_V_C3], al
    mov edx, L_VALS_len
    lea rsi, [L_VALS]
    call print_string
    mov edx, L_V_len
    lea rsi, [L_V]
    call print_string

    ; Divisória 2
    mov edx, L_DIV_len
    lea rsi, [L_DIV]
    call print_string

    ; Bloco Inferior
    mov edx, L_V_len
    lea rsi, [L_V]
    call print_string
    mov al, [C7]
    mov [L_V_C1], al
    mov al, [C8]
    mov [L_V_C2], al
    mov al, [C9]
    mov [L_V_C3], al
    mov edx, L_VALS_len
    lea rsi, [L_VALS]
    call print_string
    mov edx, L_V_len
    lea rsi, [L_V]
    call print_string
     
    mov edx, BR_len
    lea rsi, [BR]
    call print_string
     
    cmp byte [DONE], 1
    jz VICTORY
        
    cmp byte [DR], 1
    jz DRAW

; ------------ PROCESSAMENTO DE INPUT --------------
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
    
    inc byte [MOVES] 
         
    mov bl, al 
    sub bl, 48 
        
    mov cl, byte [CUR] 
        
    cmp bl, 1
    jz  C1U 
    cmp bl, 2
    jz  C2U
    cmp bl, 3
    jz  C3U
    cmp bl, 4
    jz  C4U
    cmp bl, 5
    jz  C5U
    cmp bl, 6
    jz  C6U
    cmp bl, 7
    jz  C7U
    cmp bl, 8
    jz  C8U
    cmp bl, 9
    jz  C9U  
    
    ; Input Inválido Corrigido
    dec byte [MOVES] 
            
    mov edx, WI_len
    lea rsi, [WI]
    call print_string
        
    call read_input
    jmp BOARD
        
TAKEN:
    ; Correção do operando inválido aplicada aqui
    dec byte [MOVES]
            
    mov edx, TKN_len
    lea rsi, [TKN]
    call print_string  
        
    call read_input
    jmp BOARD
        
    C1U:
        cmp byte [C1], 88 
        jz TAKEN
        cmp byte [C1], 79 
        jz TAKEN 
        mov byte [C1], cl
        jmp CHECK
             
    C2U:
        cmp byte [C2], 88
        jz TAKEN
        cmp byte [C2], 79
        jz TAKEN 
        mov byte [C2], cl
        jmp CHECK
    C3U:
        cmp byte [C3], 88
        jz TAKEN
        cmp byte [C3], 79
        jz TAKEN 
        mov byte [C3], cl
        jmp CHECK
    C4U: 
        cmp byte [C4], 88
        jz TAKEN
        cmp byte [C4], 79
        jz TAKEN 
        mov byte [C4], cl
        jmp CHECK 
    C5U: 
        cmp byte [C5], 88
        jz TAKEN
        cmp byte [C5], 79
        jz TAKEN 
        mov byte [C5], cl
        jmp CHECK
    C6U:
        cmp byte [C6], 88
        jz TAKEN
        cmp byte [C6], 79
        jz TAKEN 
        mov byte [C6], cl
        jmp CHECK
    C7U: 
        cmp byte [C7], 88
        jz TAKEN
        cmp byte [C7], 79
        jz TAKEN 
        mov byte [C7], cl
        jmp CHECK 
    C8U: 
        cmp byte [C8], 88
        jz TAKEN
        cmp byte [C8], 79
        jz TAKEN 
        mov byte [C8], cl
        jmp CHECK
    C9U:
        cmp byte [C9], 88
        jz TAKEN
        cmp byte [C9], 79
        jz TAKEN 
        mov byte [C9], cl
        jmp CHECK

; ----------- ROTINA REINICIAR PARTIDA -----------
TRYAGAIN:
    call clear_screen
        
    mov edx, TRA_len
    lea rsi, [TRA]
    call print_string
        
    call read_input
    mov al, byte [IN_CHAR]
    
    cmp al, 121  ; 'y'
    jz INIT 
    cmp al, 89   ; 'Y'
    jz INIT
    cmp al, 115  ; 's'
    jz INIT
    cmp al, 83   ; 'S'
    jz INIT
        
    cmp al, 110  ; 'n'
    jz EXIT
    cmp al, 78   ; 'N'
    jz EXIT  
        
    mov edx, WI_len
    lea rsi, [WI]
    call print_string
        
    call read_input
    jmp TRYAGAIN     

EXIT:
    mov edi, 0
    mov eax, 60  ; sys_exit Linux
    syscall 


segment readable writeable

;alterado Rosa
WIN_LINES db 0,1,2  ; Linha 1
          db 3,4,5  ; Linha 2
          db 6,7,8  ; Linha 3
          db 0,3,6  ; Coluna 1
          db 1,4,7  ; Coluna 2
          db 2,5,8  ; Coluna 3
          db 0,4,8  ; Diagonal Principal
          db 2,4,6  ; Diagonal Secundária
;até aqui Rosa

; Estruturação Visual Baseada na Imagem do Github
ANSI_cls     db 0x1B, "[2J", 0x1B, "[H"
ANSI_cls_len = $ - ANSI_cls
BR           db 0x0A
BR_len       = $ - BR

; Linhas do Tabuleiro Alinhadas (Espaços limpos)
L_V          db "     |     |     ", 0x0A
L_V_len      = $ - L_V
L_DIV        db "-----+-----+-----", 0x0A
L_DIV_len    = $ - L_DIV

; Modelo de Linha de Valores Dinâmicos
L_VALS       db "  "
L_V_C1       db "1"
             db "  |  "
L_V_C2       db "2"
             db "  |  "
L_V_C3       db "3"
             db "  ", 0x0A
L_VALS_len   = $ - L_VALS

PAK db "Pressione ENTER para continuar...", 0x0A
PAK_len = $ - PAK

; Menu de Regras
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

; Células Mutáveis
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

; Strings de Interação em Português
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
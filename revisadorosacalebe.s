format ELF64 executable 3

segment readable executable
entry $

main:
    jmp INICIO

; ----------- FUNÇÕES AUXILIARES DE SISTEMA (MUDADAS PARA O TOPO) -----------
imprimir_string:
    mov edi, 1   ; stdout
    mov eax, 1   ; sys_write
    syscall
    ret

ler_entrada:
    mov edx, 16
    lea rsi, [BUFFER_ENTRADA]
    mov edi, 0   ; stdin
    mov eax, 0   ; sys_read
    syscall
    mov al, byte [BUFFER_ENTRADA]
    mov byte [CARACTERE_LIDO], al
    ret

limpar_tela:
    mov edx, ANSI_cls_len
    lea rsi, [ANSI_cls]
    call imprimir_string
    ret

; --------- EXIBIÇÃO DA TELA DE TÍTULO ---------     
INICIO:
    call limpar_tela
    
    mov edx, T1_len
    lea rsi, [T1]
    call imprimir_string

    mov edx, T2_len
    lea rsi, [T2]
    call imprimir_string
        
    mov edx, continuar_len
    lea rsi, [continuar]
    call imprimir_string
        
    call ler_entrada
    jmp REGRAS

; ----------- EXIBIÇÃO DAS REGRAS DO JOGO --------------                                                 
REGRAS:
    call limpar_tela
    mov edx, R_len
    lea rsi, [R]
    call imprimir_string
        
    mov edx, R1_len
    lea rsi, [R1]
    call imprimir_string 

    mov edx, R2_len
    lea rsi, [R2]
    call imprimir_string 
        
    mov edx, R3_len
    lea rsi, [R3]
    call imprimir_string 
        
    mov edx, R4_len
    lea rsi, [R4]
    call imprimir_string 
            
    mov edx, R5_len
    lea rsi, [R5]
    call imprimir_string 
            
    mov edx, R6_len
    lea rsi, [R6]
    call imprimir_string 
             
    mov edx, R7_len
    lea rsi, [R7]
    call imprimir_string 
            
    mov edx, continuar_len
    lea rsi, [continuar]
    call imprimir_string 
        
    call ler_entrada 
    jmp INICIARTABULEIRO
 
INICIARTABULEIRO: 
    mov byte [jogador], 49      
    mov byte [SIMBOLO_ATUAL], 88       
    mov byte [JOGADAS], 0  
    mov byte [VENCEDOR_ENCONTRADO], 0
    mov byte [FLAG_EMPATE], 0 
            
    mov byte [C1], 49         
    mov byte [C2], 50
    mov byte [C3], 51
    mov byte [C4], 52
    mov byte [C5], 53
    mov byte [C6], 54
    mov byte [C7], 55
    mov byte [C8], 56
    mov byte [C9], 57
                                     
    jmp TABULEIRO

; ------------ TELA DE VITÓRIA ------------------------
VITORIA:
    mov edx, BR_len
    lea rsi, [BR]
    call imprimir_string

    mov edx, W1_len
    lea rsi, [W1]
    call imprimir_string
            
    mov edx, 1
    lea rsi, [jogador]
    call imprimir_string
            
    mov edx, W2_len
    lea rsi, [W2]
    call imprimir_string
                
    mov edx, continuar_len
    lea rsi, [continuar]
    call imprimir_string
            
    call ler_entrada    
    jmp TENTAR_DE_NOVO 
            
; ------------ TELA DE EMPATE ------------  
EMPATE:
    mov edx, BR_len
    lea rsi, [BR]
    call imprimir_string

    mov edx, EMPATEW_len
    lea rsi, [EMPATEW]
    call imprimir_string 
                
    mov edx, continuar_len
    lea rsi, [continuar]
    call imprimir_string
            
    call ler_entrada    
    jmp TENTAR_DE_NOVO                      

; ------------ VERIFICAÇÃO DAS CONDIÇÕES DE VITÓRIA -----------

;aterado Rosa
VERIFICA:
    lea rsi, [LINHAS_VITORIA]  ; RSI agora aponta para o nosso "gabarito" de vitórias
    mov rcx, 8            ; RCX será nosso contador de loop (temos 8 chances de ganhar)

CHECAR_LOOP:
    ; Passo A: Lemos os 3 índices da combinação atual
    movzx r8, byte [rsi]     ; Pega o 1º índice (ex: 0)
    movzx r9, byte [rsi+1]   ; Pega o 2º índice (ex: 1)
    movzx r10, byte [rsi+2]  ; Pega o 3º índice (ex: 2)

    ; Passo B: Usamos esses índices para ler o tabuleiro real
    lea rbx, [C1]            ; RBX aponta para o início do tabuleiro (C1)
    mov al, byte [rbx + r8]  ; AL recebe o valor do tabuleiro no índice 1
    mov dl, byte [rbx + r9]  ; DL recebe o valor do tabuleiro no índice 2
    mov r11b, byte [rbx + r10] ; MUDADO: r11b no lugar de ah para evitar o erro de REX prefix

    ; Passo C: Comparamos os 3 valores (exatamente como você fazia antes)
    cmp al, dl
    jnz NEXT_LINE            ; Se falhar, pula para testar a próxima combinação
    cmp dl, r11b             ; CORRIGIDO: Agora compara com o registrador correto!
    jnz NEXT_LINE            ; Se falhar, pula para a próxima

    ; Se sobreviveu aos pulos acima, alguém venceu!
    mov byte [VENCEDOR_ENCONTRADO], 1
    jmp TABULEIRO

PROXIMA_COMBINACAO:
    add rsi, 3            ; Avança o ponteiro RSI em 3 bytes (para a próxima linha do gabarito)
    dec rcx               ; Diminui nosso contador de 8 para 7, 6...
    jnz CHECAR_LOOP        ; Se o contador não for Zero, volta para CHECAR_LOOP

    ; Se o contador chegou a zero e não pulou para TABULEIRO, checa empate
    jmp CHECA_EMPATE
    
    CHECA_EMPATE:
        mov al, [JOGADAS]
        cmp al, 9
        jb TROCA_JOGADOR
        mov byte [FLAG_EMPATE], 1
        jmp TABULEIRO

; ------------ ALTERNÂNCIA DE JOGADOR ----------        
TROCA_JOGADOR:
    cmp byte [jogador], 49
    jz DEFINIR_JOGADOR_2
    
    mov byte [jogador], 49
    mov byte [SIMBOLO_ATUAL], 88     ; 'X'
    jmp TABULEIRO
         
    DEFINIR_JOGADOR_2:
        mov byte [jogador], 50
        mov byte [SIMBOLO_ATUAL], 79     ; 'O'
        jmp TABULEIRO

; ------------- RENDERIZAÇÃO DO TABULEIRO (ESTILO GITHUB) ----------   
TABULEIRO: 
    call limpar_tela

    mov edx, BR_len
    lea rsi, [BR]
    call imprimir_string

    ; Bloco Superior
    mov edx, L_V_len
    lea rsi, [L_V]
    call imprimir_string
    mov al, [C1]
    mov [L_V_C1], al
    mov al, [C2]
    mov [L_V_C2], al
    mov al, [C3]
    mov [L_V_C3], al
    mov edx, L_VALS_len
    lea rsi, [L_VALS]
    call imprimir_string
    mov edx, L_V_len
    lea rsi, [L_V]
    call imprimir_string

    ; Divisória 1
    mov edx, L_DIV_len
    lea rsi, [L_DIV]
    call imprimir_string

    ; Bloco Central
    mov edx, L_V_len
    lea rsi, [L_V]
    call imprimir_string
    mov al, [C4]
    mov [L_V_C1], al
    mov al, [C5]
    mov [L_V_C2], al
    mov al, [C6]
    mov [L_V_C3], al
    mov edx, L_VALS_len
    lea rsi, [L_VALS]
    call imprimir_string
    mov edx, L_V_len
    lea rsi, [L_V]
    call imprimir_string

    ; Divisória 2
    mov edx, L_DIV_len
    lea rsi, [L_DIV]
    call imprimir_string

    ; Bloco Inferior
    mov edx, L_V_len
    lea rsi, [L_V]
    call imprimir_string
    mov al, [C7]
    mov [L_V_C1], al
    mov al, [C8]
    mov [L_V_C2], al
    mov al, [C9]
    mov [L_V_C3], al
    mov edx, L_VALS_len
    lea rsi, [L_VALS]
    call imprimir_string
    mov edx, L_V_len
    lea rsi, [L_V]
    call imprimir_string
     
    mov edx, BR_len
    lea rsi, [BR]
    call imprimir_string
     
    cmp byte [VENCEDOR_ENCONTRADO], 1
    jz VITORIA
        
    cmp byte [FLAG_EMPATE], 1
    jz EMPATE

; ------------ PROCESSAMENTO DE INPUT --------------
INPUT:
    mov edx, MSG_VEZ_1_len
    lea rsi, [MSG_VEZ_1]
    call imprimir_string

    mov edx, 1
    lea rsi, [SIMBOLO_ATUAL]
    call imprimir_string

    mov edx, MSG_VEZ_2_len
    lea rsi, [MSG_VEZ_2]
    call imprimir_string
        
    call ler_entrada
    mov al, byte [CARACTERE_LIDO]
    
    inc byte [JOGADAS] 
         
    mov bl, al 
    sub bl, 48 
        
    mov cl, byte [SIMBOLO_ATUAL] 
        
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
    
    ; Input Inválido
    dec byte [JOGADAS] 
            
    mov edx, MSG_INVALIDA_len
    lea rsi, [MSG_INVALIDA]
    call imprimir_string
        
    call ler_entrada
    jmp TABULEIRO
        
CELULA_OCUPADA:
    dec byte [JOGADAS]
            
    mov edx, MSG_OCUPADA_len
    lea rsi, [MSG_OCUPADA]
    call imprimir_string  
        
    call ler_entrada
    jmp TABULEIRO
        
    C1U:
        cmp byte [C1], 88 
        jz CELULA_OCUPADA
        cmp byte [C1], 79 
        jz CELULA_OCUPADA 
        mov byte [C1], cl
        jmp VERIFICA
             
    C2U:
        cmp byte [C2], 88
        jz CELULA_OCUPADA
        cmp byte [C2], 79
        jz CELULA_OCUPADA 
        mov byte [C2], cl
        jmp VERIFICA
    C3U:
        cmp byte [C3], 88
        jz CELULA_OCUPADA
        cmp byte [C3], 79
        jz CELULA_OCUPADA 
        mov byte [C3], cl
        jmp VERIFICA
    C4U: 
        cmp byte [C4], 88
        jz CELULA_OCUPADA
        cmp byte [C4], 79
        jz CELULA_OCUPADA 
        mov byte [C4], cl
        jmp VERIFICA 
    C5U: 
        cmp byte [C5], 88
        jz CELULA_OCUPADA
        cmp byte [C5], 79
        jz CELULA_OCUPADA 
        mov byte [C5], cl
        jmp VERIFICA
    C6U:
        cmp byte [C6], 88
        jz CELULA_OCUPADA
        cmp byte [C6], 79
        jz CELULA_OCUPADA 
        mov byte [C6], cl
        jmp VERIFICA
    C7U: 
        cmp byte [C7], 88
        jz CELULA_OCUPADA
        cmp byte [C7], 79
        jz CELULA_OCUPADA 
        mov byte [C7], cl
        jmp VERIFICA 
    C8U: 
        cmp byte [C8], 88
        jz CELULA_OCUPADA
        cmp byte [C8], 79
        jz CELULA_OCUPADA 
        mov byte [C8], cl
        jmp VERIFICA
    C9U:
        cmp byte [C9], 88
        jz CELULA_OCUPADA
        cmp byte [C9], 79
        jz CELULA_OCUPADA 
        mov byte [C9], cl
        jmp VERIFICA

; ----------- ROTINA REINICIAR PARTIDA -----------
TENTAR_DE_NOVO:
    call limpar_tela
        
    mov edx, MSG_REINICIAR_len
    lea rsi, [MSG_REINICIAR]
    call imprimir_string
        
    call ler_entrada
    mov al, byte [CARACTERE_LIDO]
    
    cmp al, 115  ; s
    jz INICIARTABULEIRO
    cmp al, 83   ; S
    jz INICIARTABULEIRO
        
    cmp al, 110  ; n
    jz ENCERRAR
    cmp al, 78   ; N
    jz ENCERRAR  
        
    mov edx, MSG_INVALIDA_len
    lea rsi, [MSG_INVALIDA]
    call imprimir_string
        
    call ler_entrada
    jmp TENTAR_DE_NOVO     

ENCERRAR:
    mov edi, 0
    mov eax, 60  ; sys_ENCERRAR Linux
    syscall 


segment readable writeable

;alterado Rosa
LINHAS_VITORIA db 0,1,2  ; Linha 1
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

; Linhas do Tabuleiro Alinhadas
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

; Interface Gráfica da Logo
T1 db "Você está prestes a jogar o JOGO DA VELHA", 0x0A
T1_len = $ - T1
T2 db "Este jogo foi desenvolvido para a disciplica de Organização e Arquitetura de Computadores 2026.1", 0x0A
T2_len = $ - T2


continuar db "Pressione ENTER para continuar...", 0x0A
continuar_len = $ - continuar

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
R7  db "Estaremos nas trincheiras obeservando sua indole durante o jogo", 0x0A
R7_len = $ - R7

; Células 
C1 db '1'
C2 db '2'
C3 db '3'
C4 db '4'
C5 db '5'
C6 db '6'
C7 db '7'
C8 db '8'
C9 db '9'

jogador db 49
JOGADAS  db 0
VENCEDOR_ENCONTRADO   db 0
FLAG_EMPATE db 0 
SIMBOLO_ATUAL    db 88

; Strings de Interação
MSG_VEZ_1   db "Vez do "
MSG_VEZ_1_len = $ - MSG_VEZ_1
MSG_VEZ_2   db ". Escolha uma celula: "
MSG_VEZ_2_len = $ - MSG_VEZ_2

MSG_OCUPADA db "Esta celula ja foi ocupada! Pressione ENTER...", 0x0A
MSG_OCUPADA_len = $ - MSG_OCUPADA 

W1 db "Jogador "
W1_len = $ - W1
W2 db " venceu o jogo!", 0x0A
W2_len = $ - W2
EMPATEW db "O jogo terminou em EMPATE!", 0x0A
EMPATEW_len = $ - EMPATEW

MSG_REINICIAR db "Deseja jogar novamente? (s/n): "
MSG_REINICIAR_len = $ - MSG_REINICIAR
MSG_INVALIDA db "Entrada invalida! Pressione ENTER...", 0x0A
MSG_INVALIDA_len = $ - MSG_INVALIDA

CARACTERE_LIDO   db 0
BUFFER_ENTRADA rb 16

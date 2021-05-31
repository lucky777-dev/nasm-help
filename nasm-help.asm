; nasm -f elf64 -F dwarf mov_tst.asm
; ld -o mov_tst -e main mov_tst.o
; ./mov_tst

; rax, rbx, rcx, rdx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14 et r15
; rax->eax->ax->ah/al
; rsi->esi->si->sil
; r8->r8d->r8w->r8b

; DB Define Byte = 1
; DW Define Word = 2
; DD Define Double Word = 4
; DQ Define QuadWord = 8

; and 0->0
; or 1->1
; xor 1->not

; rdi, rsi, rdx, rcx, r8, r9

; Open (r11 et rcx perdus)
; rax, 2
; rdi, chemin vers le fichier: chaîne zéro terminée
; rsi, options (/usr/include/bits/fcntl-linux.h) 1q | 2000q=WRONLY & 0_APPEND
; rdx, mode (si création de fichier)

; Close
; rax, 3
; rdi, descripteur du fichier (rax après open)

; Read
; rax, 0
; rdi, descripteur du fichier (rax après open)
; rsi, adresse où stocker le résultat de la lecture
; rdx, nombre de bytes à lire

; Write
; rax, 1
; rdi, descripteur du fichier (rax après open)
; rsi, adresse de ce qui doit être écrit
; rdx, nombre de bytes à écrire

; Tableau de 5 éléments de 1 byte dans lequel on place "abc" en position 0, 1 et 2
; tab RESB 5
; mov byte [tab], `a`
; mov byte [tab+1], `b`
; mov r9, msg
; mov r8, 2
; mov byte [r9+r8], `d`
; byte word dword qword

; Boucle de 0 à 7 (exclu)
; mov rax, 0
; while:
; cmp rax, 7
; jz end_while
;   inc rax
;   jmp while
; end_while

; Compter négatifs dans le tableau
; tab DD -8, -2, 7, 14, -6
; mov rax, 0
; mov rcx, 0
; loop:
; bt dword [tab+rcx*4], 31
; jnc positive
;   inc rax
; positive:
;   int rcx
; cmp rcx, 5
; jnz loop

; Fonctions
; call label
; label:
;   push rbp
;   mov rbp, rsp
;   ...
;   mov rsp, rbp
;   pop rbp
;   ret

global main

section .data
tab1 DB 0, 1, 2, 3 ; Tableau de 4 éléments de taille 1 byte chacun
tab2 DD 'A', 'B'   ; Tableau de 3 éléménts (2+1) de taille 4 bytes chacun
   DD 'C'
tailleTab1 DQ tab1-tab2           ; Variable 8 bytes, contenu égal à 4 (4*1)
tailleTab2 DW tailleTab1-tab2     ; Variable 2 bytes, contenu égal à 12 (3*4)
nbElemTab2 DD (tailleTab1-tab2)/4 ; Variable 4 bytes, contenu égal à 3 (12/4)

section .rodata
    nomFichier DB `brol`, 0 ; ne pas oublier le 0 fin de chaîne
    msgErreur DB `Une erreur!\n`
    lgrMsgErreur DQ lgrMsgErreur - msgErreur ; Longueur de la variable
    msg DB `OK!\n`
    lgrMsg DQ lgrMsg - msg ; Longueur de la variable
    ; Tableaux
    tab3 times 4 DW 0xAB ; Taille 8 bytes, contenu égal à 8 (4*2)
    tailleTab3 DQ $-tab3 ; $ est égal à tab3 ici
    ; Variables identiques
    s1 DB "abc" ; 3 bytes
    s1_long DB "a", "b", "c"
    s1_alt DB 0x61, 0x62, 0x63
    s2 DW "abc"                 ; Define DoubleWord
    s2_long DB "a", "b", "c", 0 ; Zéro terminé
    s2_alt DB 0x70, 0x71, 0x72, 0x00
    s3_guillemets DB "abc\n"    ; 5 bytes
    s3_accents DB `abc\n`       ; 4 bytes (\n échappé)
    
section .bss
    tab4 RESB 1 ; Tableau d'1 élément de taille 1 byte
    tab5 RESW 6 ; Tableau de 6 éléments de taille 2 bytes chacun
    
section .text
main:
    ; ouverture de brol en écriture seule avec placement
    ; de la tete d'écriture en fin de fichier
    mov rax, 2 ; open
    mov rdi, nomFichier ; /adresse/ du 1er caractère du nom
    mov rsi, 1q | 2000q ; WRONLY + O_APPEND
    mov rdx, [lgrMsg]   ; Longueur de la variable
    syscall
    
    cmp rax, 0 ; Compare rax avec 0
    js erreur  ; Jump si rax est négatif
    
ok:
    mov rdi, rax      ; Dedcripteur de fichier dans rdi
    mov rax, 1        ; WRITE
    mov rsi, msg      ; Variable
    mov rdx, [lgrMsg] ; Longueur variable
    syscall
    
    mov rax, 1
    mov rdi, 1  ; Afficher à l'écran
    mov rsi, msg
    mov rdx, [lgrMsg]
    syscall
    
fin:
    mov rax, 60 ; Fin de programme
    mov rdi, 0  ; Pas d'erreurs
    syscall
    
erreur:
    mov rax, 1
    mov rdi, 1   ; Afficher à l'écran
    mov rsi, msgErreur
    mov rdx, [lgrMsgErreur]
    syscall
    
    jmp fin
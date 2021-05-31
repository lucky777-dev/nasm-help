; nasm -f elf64 -F dwarf mov_tst.asm
; ld -o mov_tst -e main mov_tst.o
; ./mov_tst

; rax, rbx, rcx, rdx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14 et r15
; rax->eax->ax->ah/al
; rsi->esi->si->sil
; r8->r8d->r8w->r8b

; and 0->0
; or 1->1
; xor 1->not

; rdi, rsi, rdx, rcx, r8, r9

; Open
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

global main

section .rodata
    nomFichier DB `brol`, 0 ; ne pas oublier le 0 fin de chaîne
    msgErreur DB `Une erreur!\n`
    lgrMsgErreur DQ lgrMsgErreur - msgErreur ; Longueur de la variable
    msg DB `OK!\n`
    lgrMsg DQ lgrMsg - msg ; Longueur de la variable
    
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
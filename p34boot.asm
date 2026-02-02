ORG 0
BITS 16

start:
    cli         ; Disable interrupts
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax  ; Set SS to zero to be used later
    mov ax, 0x00
    mov ss, ax
    sti         ; Enable interrupts
    ; Set up our new interrupt handler
    mov ax, 0x7c0       ; Segment address of our code
    mov word[ss:0x02], ax      ; Store it in interrupt vector 0
    mov ax, div_zero_handler    ; Offset of our exception handler
    mov word[ss:0x00], ax      ; Store it in interrupt vector 0
    ; Intentionally cause a divide by zero error
    mov ax, 0
    div ax
    jmp $

div_zero_handler:
    mov si, div_zero_message
    call print
    iret

print:
    mov bx, 0       ; Clear BX register to use it as a counter
.loop:
    lodsb           ; Load the byte at address SI into AL and increment SI
    cmp al, 0       ; Compare the value in AL to 0(end of string)
    je .done        ; If AL is o, then we're at the end of the string and we're done
    call print_char ; Otherwise, print the character in AL
    jmp .loop       ; Loop to the next character
.done:              ; NOTICE WE SWAPPED IT BACK FROM IRET TO RET
    ret             ; Return from the print function
print_char:
    mov ah, 0eh     ; Move oeh into AH
    int 0x10        ; Call BIOS interrupt 0x10
    ret             ; Return from the print_char function

div_zero_message: db 'Divide by zero error!', 0 
times 510-($-$$) db 0
dw 0xAA55               ; The boot sector signature.
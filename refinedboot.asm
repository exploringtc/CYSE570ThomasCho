ORG 0           ; This tells NASM where in memory our program will run
BITS 16         ; We're writing 16-bit code

start:
    cli
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax
    mov ax, 0x00
    mov ss, ax
    sti
    mov si, message         ;ADDRES OF 'MESSAGE' MOVE INTO THE si REGISTER
    call print              ; Call our print function
    jmp $               ; infinite loop, GOTO THIS instruction
print:
    mov bx, 0       ; clear BX register to use it as a counter
.loop:
    lodsb       ; Load the byte at address SI into AL and increment SI
    cmp al, 0       ; Compare the value in AL to 0 (end of string)
    je .done        ; If AL is 0, then we're at the end of the string and we're done
    call print_char         ; Otherwise, print the character in AL
    jmp .loop       ; Loop to the next character
.done:
    ret         ; Return from the print function
print_char:
    mov ah, 0eh         ; Move 0eh into AH, this is the BIOS service number for printing a character
    int 0x10        ; Call BIOS interrupt 0x10, which handles screen operations
    ret         ; Return from the print_char function

message: db 'Hello, World!', 0      ; Our null-terminated string to be printed

times 510-($-$$) db 0       ; Fill the rest of the sector with zeros upto 510 bytes
dw 0xAA55       ; The boot sector signature

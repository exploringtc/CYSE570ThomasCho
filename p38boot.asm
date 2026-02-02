ORG 0
BITS 16

start:
    cli
    mov ax, 0x7c0
    mov dx, ax
    mov es, ax
    mov ax, 0x00
    mov ss, ax
    sti

    ; Setup registers to read from the disk
    mov bx, 0x0200
    mov ah, 0x02
    mov al, 0x01
    mov ch, 0x00
    mov cl, 0x02
    mov dh, 0x00
    mov dl, 0x80
    int 0x13            ;Read from disk

    mov si, 0x200
    call print       ; Call our print function
    jmp $           ; infinite loop, GOTO THIS instruction
print:
    mov bx, 0      ; clear BX register to use it as a counter
.loop:
    lodsb
    cmp al, 0
    je .done
    call print_char
    jmp .loop
.done:
    ret

print_char:
    mov ah, 0eh
    int 0x10
    ret

times 510-($-$$) db 0
dw 0xAA55       ; The boot sector signature
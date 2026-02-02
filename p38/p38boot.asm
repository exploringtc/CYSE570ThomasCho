ORG 0
BITS 16

start:
    cli
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax
    mov ax, 0x00
    mov ss, ax
    mov sp, 0x7c00      ; Set stack pointer
    sti

    ; Display startup message
    mov si, msg_startup
    call print_string

    ; Read disk sector
    call read_disk
    
    ; Check if read was successful
    jc .read_error
    
    ; Display read success message
    mov si, msg_success
    call print_string

    ; Print data read from disk
    mov si, 0x200       ; Data loaded at 0x0200 in memory
    call print_string
    
    jmp $               ; infinite loop

.read_error:
    mov si, msg_error
    call print_string
    jmp $
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

print_string:
    mov ah, 0x0e    ; BIOS teletype mode
    mov bx, 0x0000  ; page 0
.loop:
    lodsb           ; Load byte at DS:SI into AL
    cmp al, 0       ; Check for null terminator
    je .done
    int 0x10        ; BIOS video interrupt
    jmp .loop
.done:
    ret

print_char:
    mov ah, 0eh
    int 0x10
    ret

read_disk:
    ; BIOS INT 0x13 read disk sectors
    ; AH = 0x02 (read sectors)
    ; AL = number of sectors to read
    ; CH = cylinder number (bits 0-7)
    ; CL = sector number (bits 0-5) + cylinder (bits 6-7)
    ; DH = head number
    ; DL = drive number (0x80 for first hard disk)
    ; ES:BX = buffer address
    
    mov bx, 0x200       ; Buffer address: 0x0000:0x0200
    mov ah, 0x02        ; Read sectors function
    mov al, 0x01        ; Read 1 sector
    mov ch, 0x00        ; Cylinder 0
    mov cl, 0x02        ; Sector 2 (bootloader is sector 1)
    mov dh, 0x00        ; Head 0
    mov dl, 0x80        ; Drive 0x80 (first hard disk)
    int 0x13            ; Call BIOS disk interrupt
    ret

; Messages
msg_startup:
    db 'Bootloader starting...', 0x0d, 0x0a, 0

msg_success:
    db 'Sector read successfully!', 0x0d, 0x0a, 0

msg_error:
    db 'Error reading disk!', 0x0d, 0x0a, 0

times 510-($-$$) db 0
dw 0xAA55       ; The boot sector signature
ORG 0x7C00
BITS 16

start:
    cli                     ; disable interrupts while we set things up
    xor ax, ax
    mov ss, ax              ; SS = 0
    mov sp, 0x7C00          ; stack starts just below our code
    mov ds, ax              ; DS = 0
    mov es, ax              ; ES = 0

    push cs
    pop ax                  ; AX = CS (e.g., 0x07C0)

    mov [0x80*4],   word my_isr   ; offset (IP) of handler
    mov [0x80*4+2], word ax       ; segment (CS) of handler
    sti                     ; re-enable interrupts

    mov ds, ax              ; DS = CS (segment of our code/data)
    mov es, ax

    mov si, message
    int 0x80                ; call our custom interrupt
    jmp $                   ; infinite loop 
    
my_isr:
    push ax
    push bx
    push si

.print_loop:
    lodsb                   ; AL = [DS:SI], SI++
    cmp al, 0
    je .done
    mov ah, 0x0E            ; teletype output function
    mov bx, 0x0007          ; page 0, attribute 7
    int 0x10                ; BIOS video interrupt
    jmp .print_loop

.done:
    pop si
    pop bx
    pop ax
    iret                    

message: db 'Hello, World!', 0  ; null-terminated string
times 510-($-$$) db 0
dw 0xAA55                     ; boot sector signature

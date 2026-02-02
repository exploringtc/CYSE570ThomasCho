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
                        ; We use SS as a segment because it is equal to zero.
                        ; 0x00*16 = 0+0x202=0x202 absolute address
    mov word[ss:0x202], ax      ; Store segment 0x7c0 in IVT
    lea ax, [print]             ; Offset of our print function
    mov word[ss:0x200], ax      ; Store the offset to the print routine in interrupt vector 0x80
    lea si, [message]   ; Address of 'message' moveinto the SI register
    int 0x80            ; Call our new interrupt!
    jmp $               ; Infinite loop, GOTO THIS instruction

print:
    mov bx, 0       ; Clear BX register to use it as a counter
.loop:
    lodsb           ; Load the byte at address SI into AL and increment SI
    cmp al, 0       ; Compare the value in AL to 0(end of string)
    je .done        ; If AL is o, then we're at the end of the string and we're done
    call print_char ; Otherwise, print the character in AL
    jmp .loop       ; Loop to the next character
.done:              ; THIS IS IRET NOW (INTERRUPT RETURN)
                    ; ENSURE IT IS NOT SET TO "RET"
    iret            ; Return from the print interrupt routine ISR

print_char:
    mov ah, 0eh     ; Move oeh into AH
    int 0x10        ; Call BIOS interrupt 0x10
    ret             ; Return from the print_char function

message: db 'Hello, World!', 0  ; Our null-terminated string
isr_message: db 'Interrupt Happened!',0 ; Our null-terminated string

;BELOW CODE GUARANTEES A 512 BYTE FILE SIZE

times 510-($-$$) db 0
dw 0xAA55               ; The boot sector signature.
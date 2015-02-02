
    org 0x100

; ===== CODE SECTION =====

start:
    mov ax, 0x13
    int 0x10
    
    mov ax, 0xA000
    mov es, ax
    
calculate:
    finit
    mov cx, 200
    
    nextY:
        push cx
        mov cx, 320
        
        nextX:
            ; y = sqrt(x)
            fild word [point.x]
            fsqrt
            fist word [point.y]
    
            ; Place pixel in video memory
            cmp word [point.x], 320
            jge .xOutOfBounds
            cmp word [point.y], 200
            jge .yOutOfBounds
            
            mov ax, word [point.y]
            push dx
            mov dx, word [point.z]
            add ax, dx
            mov dx, 320
            mul dx
            pop dx
            add ax, word [point.x]
            mov di, ax
            mov al, byte [color]
            stosb

            .yOutOfBounds:    
            inc word [point.x]
            .xOutOfBounds:
            loop nextX 

        ; Update color, vertical offset
        inc byte [color]
        mov word [point.x], 0
        inc word [point.z]
        pop cx
        loop nextY
    
exit:
    xor ax, ax
    int 0x16
    
    mov ax, 0x03
    int 0x10
    
    ret

; ===== DATA SECTION =====    
point.x  dw 0
point.y  dw 0
point.z  dw 0
color    db 1

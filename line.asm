
_COLOR	equ 0x0F

	org 0x100

; ===== MACRO SECTION =====

macro drawLine _x1*, _y1*, _x2*, _y2* {
      mov word [x1], _x1
      mov word [y1], _y1
      mov word [x2], _x2
      mov word [y2], _y2
      call proc_drawLine
}

; ===== CODE SECTION =====

start:
	mov ax, 0x13
	int 0x10

	mov ax, 0xA000
	mov es, ax
	;mov cx, 320
	finit

calculate:
	drawLine 0, 0, 320-1, 200-1
	drawLine 0, 200-1, 320-1, 0
	drawLine 50, 50, 50, 150
	drawLine 60, 60, 120, 60
	drawLine 20, 200-10, 40, 5

exit:
	xor ax, ax
	int 0x16

	mov ax, 0x03
	int 0x10

	ret

; ===== PROCEDURE SECTION =====

proc_putPixel:
	; di = (yCoord * 320) + xCoord
	mov ax, word [yCoord]
	push dx
	mov dx, 320
	mul dx
	mov dx, word [xCoord]
	add ax, dx
	pop dx
	mov di, ax
	mov byte [es:di], _COLOR

	; Return
	ret

proc_drawLine:
	; dx = x2 - x1
	mov ax, word [x2]
	mov bx, word [x1]
	sub ax, bx
	mov word [_dx], ax

	; dy = y2 - y1
	mov ax, word [y2]
	mov bx, word [y1]
	sub ax, bx
	mov word [_dy], ax

	; absdy = abs(dy)
	fild word [_dy]
	fabs
	fist word [absdy]

	; newX = newY = 0
	mov word [newX], 0
	mov word [newY], 0

	; Iterate along the X axis if the slope is not steep
	; if (dx >= abs(dy)) {...}
	mov ax, word [_dx]
	cmp ax, word [absdy]
	jl .yLine

	.xLine:
		; for (newX = 0; newX <= dx; newX++) {...}
		mov ax, [newX]
		cmp ax, word [_dx]
		jg .exit

		.xLine.next:
			; newY = (dy * newX) / dx
			fild word [_dy]
			fild word [newX]
			fmulp
			fild word [_dx]
			fdivp
			fist word [newY]

			; xCoord = newX + x1
			mov ax, word [newX]
			mov bx, word [x1]
			add ax, bx
			mov word [xCoord], ax

			; yCoord = newY + y1
			mov ax, word [newY]
			mov bx, word [y1]
			add ax, bx
			mov word [yCoord], ax

			; Put pixel
			call proc_putPixel

			; Update newX
			inc word [newX]

			; Next iteration
			jmp .xLine

	; Iterate along the Y axis if the slope is too steep
	; else {...}
	.yLine:
		; for (newY = 0; newY <= abs(dy); newY++) {...}
		mov ax, [newY]
		cmp ax, word [absdy]
		jg .exit

		.yLine.next:
			; newX = (dx * newY) / abs(dy)
			fild word [_dx]
			fild word [newY]
			fmulp
			fild word [absdy]
			fdivp
			fist word [newX]

			; xCoord = newX + x1
			mov ax, word [newX]
			mov bx, word [x1]
			add ax, bx
			mov word [xCoord], ax

			; if (dy >= 0) {...}
			cmp word [_dy], 0
			jl .yLine.next.negativeDy

			.yLine.next.positiveDy:
				mov ax, word [newY]
				mov bx, word [y1]
				add ax, bx
				jmp @f

			.yLine.next.negativeDy:
				mov ax, word [y1]
				mov bx, word [newY]
				sub ax, bx

			@@:
			mov word [yCoord], ax

			; Put pixel
			call proc_putPixel

			; Update newY
			inc word [newY]

			; Next iteration
			jmp .yLine

	.exit:
		; Return
		ret

; ===== DATA SECTION =====

x1	dw ?
y1	dw ?
x2	dw ?
y2	dw ?
_dx	dw ?
_dy	dw ?
newX	dw ?
newY	dw ?
absdy	dw ?

xCoord	dw ?
yCoord	dw ?

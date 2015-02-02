
_COLOR	equ 0x0F

	org 0x100

start:
	mov ax, 0x13
	int 0x10

	mov ax, 0xA000
	mov es, ax
	mov cx, 320
	finit

calculate:
	; y = (x/4) * sin(x/10)
	; sin(x/10)
	fild word [x2]
	fild word [_10]
	fdivp
	fsin

	; x/4
	fild word [x2]
	fild word [_4]
	fdivp

	; () * ()
	fmulp

	; y += 100 for screen
	fild word [_100]
	faddp
	fist word [y2]

	; Draw line between points 1 and 2
	call proc_drawLine

	; Move point 2 data to point 1
	mov ax, word [x2]
	mov word [x1], ax
	mov ax, word [y2]
	mov word [y1], ax

	; Next X, and loop
	inc word [x2]
	loop calculate

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

x1	dw 0
y1	dw 100
x2	dw ?
y2	dw ?
_dx	dw ?
_dy	dw ?
newX	dw ?
newY	dw ?
absdy	dw ?

xCoord	dw ?
yCoord	dw ?

_160	dw 160
_100	dw 100
_10	dw 10
_4	dw 4
_2	dw 2

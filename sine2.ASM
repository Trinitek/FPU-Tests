
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
	fild word [point.x]
	fild word [_10]
	fdivp
	fsin

	; x/4
	fild word [point.x]
	fild word [_4]
	fdivp

	; () * ()
	fmulp

	; y += 100 for screen
	fild word [_100]
	faddp
	fist word [point.y]

	; Plot the pixel on the screen
	mov ax, word [point.y]
	push dx
	mov dx, 320
	mul dx
	mov dx, word [point.x]
	add ax, dx
	pop dx
	mov di, ax
	mov byte [es:di], _COLOR

	inc word [point.x]
	loop calculate

exit:
	xor ax, ax
	int 0x16

	mov ax, 0x03
	int 0x10

	ret

point.x dw 0
point.y dw 0
_160	dw 160
_100	dw 100
_10	dw 10
_4	dw 4
_2	dw 2

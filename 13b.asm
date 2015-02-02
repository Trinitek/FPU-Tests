
macro pixelOfs reg*, x*, y*
{
	mov ax, y
	push dx
	mov dx, 320
	mul dx
	pop dx
	add ax, x
	mov reg, ax
}

macro sqrt dest*, n*
{
	finit
	fild word [n]
	mov bp, sp
	sub sp, 2
	push 160
	fild word [bp]
	fmulp
	fsqrt
	fist word [dest]
}

	org 0x100

start:
	mov ax, 0x13
	int 0x10

	mov ax, 0xA000
	mov es, ax
	xor di, di
	mov cx, 200

plot:
	sqrt point.x, point.y
	pixelOfs di, [point.x], [point.y]

	stosb
	inc al
	inc [point.y]
	loop plot

exit:
	xor ax, ax
	int 0x16
	mov ax, 0x03
	int 0x10
	ret

; ===== DATA =====

point:
	.x dw ?
	.y dw ?
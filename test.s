.data
	file: .asciz "file.txt"
	exit_str:     .asciz  "\nFim do Programa.\n"
	.equ size_exit, 18

	.balign 1
	buffer: .byte 1

.text
.global main
.func main 

main:
	
	mov r6, #0
	mov r1, #0
	mov r2, #0
	
	mov r6, #0x61

	@Leitura do arquivo de entrada output.txt
	ldr r0, =file
	mov r7, #5
	ldr r1, =#0x241 @ parametro para criar arquivo caso não exista e caso exista apagar o conteudo dele e escrever o que tem em input.txt
	mov r2, #384
	swi #0

	mov r5,r0
	
	l1:
		and r1, r6, #1
		add r1, r1, #48		
			
		ldr r2, =buffer
		strb r1, [r2]

		mov r7, #4
		mov r0, r5
		ldr r1, =buffer
		mov r2, #1
		swi 0
		
		cmp r6, #0
		beq close_file
	
		lsr r6, #1
		b l1

	close_file:
		@fechar output
		mov r0, r5
		mov r7, #6
		swi #0		


	exit:
		mov r7, #4
		mov r0, #1
		mov r2, #size_exit
		ldr r1, =exit_str
		swi #0
		mov r7, #1
		swi #0	

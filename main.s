
.data	
.balign 1
	user_input: .byte	1
	buffer: .byte 1

.balign 4
	menu_str:     .asciz "------MENU------\n|1 - Executar  |\n|2 - Sair      |\n----------------\n"
	.equ size_menu, 68
	exit_str:     .asciz  "\nFim do Programa.\n"
	.equ size_exit, 18
	error_str:    .asciz  "\nERROR.\n"
	.equ size_error, 9
	printf_str: .asciz "\033c"
	
.text

.global main
.func main

main:
	
loop_menu:	

	menu:
		mov r7, #4
		mov r0, #1
		mov r2, #size_menu
		ldr r1, =menu_str
		swi #0
		
		mov r7, #3
		mov r0, #0
		ldr r1, =user_input
		mov r2, #2
		swi 0

		ldrb r0, [r1]
		cmp r0, #0x31
		beq exec
		
		cmp r0, #0x32
		beq exit
		
		ldr r0, =printf_str
		bl printf
		
		mov r7, #4
		mov r0, #1
		mov r2, #size_error
		ldr r1, =error_str
		swi #0
		
		b loop_menu
		
	exec: 
		b exit

	exit:
		mov r7, #4
		mov r0, #1
		mov r2, #size_exit
		ldr r1, =exit_str
		swi #0
		mov r7, #1
		swi #0

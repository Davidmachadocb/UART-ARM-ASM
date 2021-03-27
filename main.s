@-----------------------Segmento de dados-------------------------@
@ user_input: input do usuário para escolher menu inicial.        @
@                                                                 @
@ buffer: variavel para receber o char do arquivos ou escrever um @
@         char em especifico.                                     @
@                                                                 @
@ menu_str: string que representa o menu.                         @
@ size_menu: constante com o tamanho da string menu_str.          @
@                                                                 @
@ exit_str: string para indicar que o programa acabou.            @        
@ size_exit: constante com tamanho da string exit_str.            @
@                                                                 @
@ error_str: string para indicar que houver error.                @
@ size_error: tamanho da string de error.                         @
@                                                                 @
@ clear_str: string que contém a palavra clear que vai ser usado  @
@            como argumento para a função system.                 @
@-----------------------------------------------------------------@
.data	

.balign 1
	user_input: .byte 1
	buffer: .byte 1


.balign 4
	
	input_txt:  .asciz "text_input.txt"
	uart:      .asciz "UART.txt"
	output_txt:  .asciz "text_output.txt"
			
	menu_str:     .asciz "--------MENU--------\n|1 - txt para UART |\n|2 - UART para txt |\n|3 - Sair          |\n--------------------\nUser input: "
	.equ size_menu, 117
	exit_str:     .asciz  "\nFim do Programa.\n"
	.equ size_exit, 18
	error_str:    .asciz  "\nERROR.\n"
	.equ size_error, 9
	clear_str: .asciz "clear"

.text

.global main
.func main

main:
	
loop_menu:	

	menu:
		
		@ Imprimir o menu na tela por meio da chamada de sistema.
		mov r7, #4
		mov r0, #1
		mov r2, #size_menu
		ldr r1, =menu_str
		swi #0
		
		@Receber o input do usuário atráves de uma chamada de sistema e 
		@ salvar em user_input.
		mov r7, #3
		mov r0, #0
		ldr r1, =user_input
		mov r2, #2
		swi 0

		@Carregar o valor de user_input em r0 para fazer as comparações
		@ com as opções do menu.
		ldrb r0, [r1]
		cmp r0, #0x31
		beq opt1
		
		@Carregar o valor de user_input em r0 para fazer as comparações
		@ com as opções do menu.
		cmp r0, #0x32
		beq opt2
				
		cmp r0, #0x33
		beq exit
		
		@Caso não tenha  
		ldr r0, =clear_str
		bl system
		
		mov r7, #4
		mov r0, #1
		mov r2, #size_error
		ldr r1, =error_str
		swi #0
		
		b loop_menu
		
	opt1: 
		@Leitura do arquivo de entrada input.txt
		ldr r0, =input_txt
		mov r7, #5 
		mov r1, #0 @ passar zero para leitura
		mov r2, #0
		swi #0
		
		cmp r0, #0
		bmi error

		mov r4, r0
		
		@Leitura do arquivo de entrada output.txt
		ldr r0, =uart
		mov r7, #5
		ldr r1, =#0x241 @ parametro para criar arquivo caso não exista e caso exista apagar o conteudo dele e escrever o que tem em input.txt
		mov r2, #384
		swi #0

		cmp r0, #0
		bmi error

		mov r5, r0
		mov r6, #0

		loop1:
			@passando parametros para realizar chamada do sistema
			@e ler um byte do input.txt e salvar em buffer
			mov r7, #0x03
			mov r0, r4
			ldr r1, =buffer
			mov r2, #1
			swi 0			
			
			@compara r0 com 0, por conta que se o r0 tiver o valor de 0
			@foi por conta que o arquivo acabou, e se for zero o programa 
			@pula para fim
			cmp r0, #0
			beq close_files1	
			
			ldr r6, =buffer			
			ldrb r6, [r6]

			mov r1, #48
			ldr r2, =buffer
			strb r1, [r2]
	
			mov r7, #4
			mov r0, r5
			ldr r1, =buffer
			mov r2, #1
			swi 0
	
			mov r3, #0
			
			loop2:
				cmp r6, #0
				beq zeros		
		
				and r1, r6, #1
				add r1, r1, #48		
			
				ldr r2, =buffer
				strb r1, [r2]

				mov r7, #4
				mov r0, r5
				ldr r1, =buffer
				mov r2, #1
				swi 0
			
				add r3, r3, #1		
		
				lsr r6, #1
				b loop2


			zeros:
				cmp r3, #8
				bge finished_loop2
		
				mov r1, #48
				ldr r2, =buffer
				strb r1, [r2]

				mov r7, #4
				mov r0, r5
				ldr r1, =buffer
				mov r2, #1
				swi 0

				add r3, r3, #1

				b zeros

			finished_loop2:
				mov r1, #49
				ldr r2, =buffer
				strb r1, [r2]

				mov r7, #4
				mov r0, r5
				ldr r1, =buffer
				mov r2, #1
				swi 0	

				b loop1

		
		close_files1:
			@fechar input
			mov r0, r4
			mov r7, #6
			swi #0
							
			mov r0, r5
			mov r7, #6
			swi 0


	opt2: 
		@Leitura do arquivo de entrada input.txt
		ldr r0, =uart
		mov r7, #5 
		mov r1, #0 @ passar zero para leitura
		mov r2, #0
		swi #0
		
		cmp r0, #0
		bmi error

		mov r4, r0
		
		@Leitura do arquivo de entrada output.txt
		ldr r0, =output_text
		mov r7, #5
		ldr r1, =#0x241 @ parametro para criar arquivo caso não exista e caso exista apagar o conteudo dele e escrever o que tem em input.txt
		mov r2, #384
		swi #0

		cmp r0, #0
		bmi error

		mov r5, r0
		mov r6, #0

	



	exit:
		mov r7, #4
		mov r0, #1
		mov r2, #size_exit
		ldr r1, =exit_str
		swi #0
		mov r7, #1
		swi #0

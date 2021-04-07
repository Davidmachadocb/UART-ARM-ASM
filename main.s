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
	user_input: 	.byte 1
	buffer: 	.byte 0
	bufOut:		.byte 0
	control:	.byte 0


.balign 4
	
	input_txt:  .asciz "text_input.txt"
	uart:      .asciz "UART.bin"
	output_txt:  .asciz "text_output.txt"
	InFileFd:        .skip 4
	OutFileFd:        .skip 4
			
	menu_str:     .asciz "--------MENU--------\n|1 - txt para UART |\n|2 - UART para txt |\n|3 - Sair          |\n--------------------\nUser input: "
	.equ size_menu, 117
	errorUart_str:	.asciz 	"Houve um erro de ascii para uart. Bits incompletos."
	.equ size_errorUart, 51
	exit_str:     .asciz  "\nFim do Programa.\n"
	.equ size_exit, 18
	error_str:    .asciz  "\nERROR.\n"
	.equ size_error, 9
	inv_str:      .asciz "   Opção inválida\n"
	.equ size_inv, 22
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
		beq _exit
		
		@Caso não tenha  
		ldr r0, =clear_str
		bl system
		
		mov r7, #4
		mov r0, #1
		mov r2, #size_inv
		ldr r1, =inv_str
		swi #0
		
		b loop_menu
		
	opt1: 
		@ Abrindo arquivo de entrada.
		ldr r0, =input_txt
		bl _openIn
		cmp r0,#0								@ r0 menor do que 0 significa que houve um erro.
		bmi errorOpen

		@ Salvando fd do arquivo de entrada.
		ldr r1, =InFileFd
		str r0,[r1]

		@ Abre/Cria arquivo de saída.
		ldr r0, =uart
		bl _openOut

		@ Salvando fd do arquivo de saída.
		ldr r1, =OutFileFd
		str r0,[r1]

		@ Lendo valores do arquivo de entrada.
		readValue_opt1:
			bl _readByte

			@ Verificando se leu algo.
			cmp r0, #0
			beq end

		@ Convertendo valor lido.
		txt_uart:
			bl asciiUart                                 @vai concerter de ascii para uart
			b readValue_opt1


	opt2: 
		@ Abrindo arquivo de entrada.
		ldr r0, =uart
		bl _openIn
		cmp r0,#0							@ r0 menor do que 0 significa que houve um erro.
		bmi errorOpen

		@ Salvando fd do arquivo de entrada.
		ldr r1, =InFileFd
		str r0,[r1]

		@ Abre/Cria arquivo de saída.
		ldr r0, =output_txt
		bl _openOut

		@ Salvando fd do arquivo de saída.
		ldr r1, =OutFileFd
		str r0,[r1]

		@ Lendo valores do arquivo de entrada.
		readValue_opt2:
		
			@ ler o primeiro bit de controle
			bl _readByte

			@ Verificando se leu algo.
			cmp r0, #0
			beq end

		@ Convertendo cadeira de bits em um valor ascii.
		uart_txt:
			bl uartAscii
			b readValue_opt2


	end:
		bl _close								@ Fecha todos os arquivos abertos.
		b _exit


@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
@========================================================================================
@ascii->uart
asciiUart:
	push {lr}								@ salva o contexto atual do código

@START
	mov r2, #0x0                                                           @ primeiro bit de controle 0
	bl bitControl
	ldr r5, =buffer								@ De onde será retirado o byte escrito.
	ldr r6, [r5]                                                            @ carrega r5 em r6
	mov r3, #8								@ contador de bits

l1_asciiUart:
	and r1, r6, #1                                                          @ r1 recebe o resultado de um and entre o bit menos significativo de r6 e 1

	strb r1, [r5]                                                                 
	ldr r1, =buffer								@ De onde será retirado o byte escrito.	
	bl _writeByte                                                           @ chama a label onde o bit será impresso

	lsr r6,#1                                                               @ faz um deslocamento pra direita em r6 pra pegar o próximo bit
	sub r3,r3,#1								@ diminui r3 em 1, já que um bit foi impresso
	cmp r3,#0								@ se r3 chegar em 0 o código continua pra imprimir o próximo bit de controle
	bgt l1_asciiUart

end_l1_asciiUart:
@END
	mov r2, #0x1								@ r2 recebe 1
	bl bitControl								@ chama a label pra imprimir o bit de controle
	pop {pc}								@ volta pra o início de asciiUart para pegar o próximo char

@========================================================================================
bitControl:
	push {lr}								@ salva o contexto
	ldr r4, =control							@ coloca o bit de controle em control
	strb r2,[r4]

writeControl:
@ write in file:	
	ldr r1, =control								@ Char impresso estará em control.
	bl _writeByte									@ chama a label onde o bit será impresso
	pop {pc}									@ volta pro contexto anterior 

@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
@========================================================================================
@uart->ascii
uartAscii:
	push {lr}

@START
	ldr r5, =bufOut								@ De onde será retirado o byte escrito.
	mov r3, #0

@ limpando assim o bufOut usado anteriormente
	strb r3,[r5]

l1_uartAscii:
	bl _readByte

@ verifica se leu algo
	cmp r0, #0
	beq errorUart
	ldr r1, =buffer
	ldr r1, [r1]

@ valor do bufOut em r6
	ldr r6, [r5]

@ valor lido esta em r1


@ faz uma mascara para pegar apenas o bit menos significativo
	and r1, r1, #0x1

@ Passo: r6 = r6 + (r1 << r3)
	add r6, r6, r1, LSL r3
	strb r6, [r5]

	add r3,r3,#1
	cmp r3,#8
	bmi l1_uartAscii

end_l1_uartAscii:
@ Parece que o valor em ascii já fica em bufOut por algum motivo kkkkk
	ldr r1, [r5]
	and r1, r1, #0xff
	strb r1, [r5]

@write ascii
	mov r7, #4
	ldr r0, =OutFileFd
	ldr r0, [r0]								@ Valor de fd guardado em OutFileFd.
	ldr r1, =bufOut								@ De onde será retirado o byte escrito.
	mov r2, #1								@ Quantos bytes serão escritos.
	swi #0

@END
	@ ler o segundo bit de controle
	bl _readByte
	pop {pc}

@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
@ Chamadas essenciais:
@----------------------------------------------------------------------------------------
@ Atividade: Abre arquivo de entrada apenas para leitura (flag 0x0 - O_RDONLY).
@ Retorna: fd do arquivo de entrada em r0.
_openIn:
	push {lr}
	mov r7, #5
	mov r1, #0								@ flags: 0x0
	mov r2, #0								@ permissões: 0x0
	swi #0
	pop {pc}

@----------------------------------------------------------------------------------------
@ Atividade: Abre arquivo de saída apenas para leitura (flag 0x1 - O_WRONLY), truncando o seu tamanho para 0 (flag 0x200 - O_TRUNC).
@ 	Se o arquivo de saída não existir,então é criado outro (flag 0x40 - O_CREAT) com todas as permissões (0x1FF).
@ Retorna fd do arquivo de saída em r0.
_openOut:
	push {lr}
	mov r7, #5
	ldr r1, =#0x241								@ flags: 0x200 or 0x40 or 0x1
	ldr r2, =#0x1FF								@ permissões: FFF em octa
	swi #0
	pop {pc}

@----------------------------------------------------------------------------------------
@ Atividade: Fecha arquivos abertos.
_close:
	push {lr}

@ Fechando arquivo de entrada.
	mov r7, #6
	ldr r0, =InFileFd
	ldr r0, [r0]								@ Valor de fd guardado em InFileFd.
	swi #0

@ Fechando arquivo de saída.
	mov r7, #6
	ldr r0, =OutFileFd
	ldr r0, [r0]								@ Valor de fd guardado em OutFileFd.
	swi #0
	pop {pc}

@----------------------------------------------------------------------------------------
@ Atividade: Ler apenas um byte de um arquivo.
@ Retorna: A quantidade de Bytes lido. 0 significa que não leu nada.
_readByte:
	push {lr}
	mov r7, #3
	ldr r0, =InFileFd
	ldr r0, [r0]								@ Valor de fd guardado em InFileFd.
	ldr r1, =buffer								@ Aonde será colocado os bytes lidos.
	mov r2, #1								@ Quantos bytes serão lidos.
	swi #0
	pop {pc}

@----------------------------------------------------------------------------------------
@ Atividade: Escreve apenas um byte no arquivo de saída.
@ Retorna: A quantidade de Bytes escritos. 0 significa que não escreveu nada.
_writeByte:
	push {lr}
	mov r7, #4
	ldr r0, =OutFileFd
	ldr r0, [r0]								@ Valor de fd guardado em OutFileFd.
	mov r2, #1								@ Quantos bytes serão escritos.
	swi #0
	pop {pc}

@----------------------------------------------------------------------------------------
@ Atividade: Imprime algo no terminal.
@ Observação: fd, mensagem e dado são colocados em seus respectivos registradores antes de chegar aqui.
_print:
	push {lr}
	mov r7, #4
	mov r0, #1								@ Imprimir no terminal (stdout)
	swi #0
	pop {pc}


@----------------------------------------------------------------------------------------
@ Atividade: Imprime mensagem de erro ao abrir o arquivo entrada e finaliza a execução.
errorOpen:
	ldr r1, =error_str								@ Mensagem que será impressa.
	mov r2, #size_error								@ 34 bytes serão impressos.
	bl _print
	b _exit

@----------------------------------------------------------------------------------------
@ Atividade: Imprime mensagem de erro por ter menos bits do que 8 para compor o char de Uart para txt.
errorUart:
	ldr r1, =errorUart_str							@ Mensagem que será impressa.
	mov r2, #size_errorUart								@ 34 bytes serão impressos.
	bl _print
	b _exit

@----------------------------------------------------------------------------------------
@ Atividade: Finaliza execução.
_exit:
	mov r7, #4
	mov r0, #1
	mov r2, #size_exit
	ldr r1, =exit_str
	swi #0
	mov r7, #1
	swi #0



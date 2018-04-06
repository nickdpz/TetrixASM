	INCLUDE 'MC9S08JM16.INC' 
	
;INTERUPCIONES 	
KBIE	EQU		1
KBACK	EQU		2
IRQACK	EQU	2
;LCD
RS		EQU	0		;Define bit 0 del PTD
ENABLE	EQU	1		;Define bit 1 del PTD
;MATRIZ
C0 		EQU 0		;Define bit 0 del PTB como columna C0
C1		EQU 1		;Define bit 1 del PTB como columna C0
C2		EQU 2		;Define bit 2 del PTB como columna C0
C3		EQU 3		;Define bit 3 del PTB como columna C0
C4		EQU 0		;Define bit 0 del PTF como columna C0
C5		EQU 1		;Define bit 1 del PTF como columna C0
C6		EQU 4		;Define bit 4 del PTF como columna C0
C7		EQU 5		;Define bit 5 del PTF como columna C0
CLK		EQU 5		;Define bit 4 del PTC CLK del contador

;RELOJ INTERNO
LOCK	EQU	6		;Bit 6 del registro MCGSC

		ORG 	0B0H  ;Direccion de RAM  (Variables)
			
TABLERO   DS 21
TABLERO_F DS 21 
CONT      DS 1
FILA_C    DS 1
COLM_C    DS 1
PUNTAJE   DS 2
PUNTAJE_M DS 2
NIVEL     DS 1  
GAME_OVER DS 1
START     DS 1
PAUSE     DS 1

		ORG		0C000H; Direccion de RAM  (Memoria para programa)

INICIO:	;----------CONFIGURACION RELOJ----------------------------------------------
		MOV		#0AAH,	MCGTRM
		MOV 	#6,		MCGC1
		BRCLR	LOCK,	MCGSC,	*
;---------------CONFIGURACION MICRO-------------------------------------------------------------
		CLRA;Limpia registro A 
		STA SOPT1;Carga registro SOPT1 con ceros para Deshabilitar Modulo COP		
		LDHX	#4B0H
		TXS
;--------------CONFIGURACION IRQ----------------------------------------
		MOV		#01110110B, IRQSC 
		
;---------------CONFIGURACION TECLADO--------------------------------------------
		;MOV		#7FH,	PTEDD			;Configuramos el puerto E todo como salidas
		;LDA		#0CH			 	;HABILITAR RESISTENCIAS DE PULL UP G2-G3
		;STA		PTGPE				;MODIFICA REGISTRO
		;LDA		#30H			 	;HABILITAR  RESITENCIA PULL-UP B4-B5
		;STA		PTBPE		
		;LDA		#3
		;STA		PTGDD			 	;CONFIGURAR PUERTO G0,G1	SALIDA
		;MOV		#7FH,PTDDD		 ;PUERTO D COMO SALIDA
		;MOV		#11110000B,KBIPE	;HABILITAR INTERRUPCIONES DE PUERTOS B4,B5,G2,G3
		;BSET	KBACK, KBISC
		;BSET	KBIE,  KBISC
;-------------------------------------------------------------------------------
;------------------CONFIGURACION PINES PARA MATRIX------------------------------
		MOV		#33H,	PTFDD			;Configuramos los pines F0,F1,F4,F5	como salidas	
		MOV		#0FH,	PTBDD			;Configuramos los pines B0,B1,B2,B3	como salidas
		MOV		#00001000B,	PTCDD			;Configuracion del reloj del contador
;-------------------------------------------------------------------------------
;------------------CONFIGURACION LCD--------------------------------------------
		LDHX	#50000D
		JSR		TIEMPO		
		MOV		#0FFH,	PTEDD			;Configuramos el puerto E todo como salidas
		MOV		#3,		PTDDD			;Configuramos bits 0 y 1 del puerto D como salidas
		BCLR	ENABLE,	PTDD				;Mandamos el bit 1 del registro D a 0
		MOV #00111000B,	PTED			;Enviamos el comando para colocar bus a 8 BITS, las 2 lineas habilitadas y matriz de 5x7 en cada cuadro
		JSR		COMANDO					;Saltamos a sub rutina para enviar el comando
		MOV	#00000110B,	PTED			;Enviamos el comando para escribir de izquierda a derecha y display estático
		JSR		COMANDO					;Saltamos a sub turtina para enviar el comando
		MOV	#00001100B,	PTED			;Enviamos el comando para encender el display, apagar el cursor y mantener el cursor estático
		JSR		COMANDO					;Saltamos a sub rutina para enviar el comando
		MOV #00000001B,	PTED			;Enviamos el comando para borrar el display
		JSR		COMANDO
		LDHX	#20000D
		JSR		TIEMPO
		MOV	#10000000B,	PTED			;Enviamos comando para mover el cursor a la posición 2 en la línea 1
		JSR		COMANDO
		LDHX	#0
LINEA1: LDA 	TABLAF1,X
		CBEQA	#0FFH,LINEA2
		STA		PTED
		JSR		DATOLCD
		AIX 	#1
		JMP		LINEA1
LINEA2:	MOV		#11001011B,PTED
		JSR     COMANDO
		LDHX 	#0			
;--------------------------------------		
;----------------Limpia Variables------
		MOV		#0H,PTFD
		MOV		#0H,PTBD;
		BCLR    CLK,PTGD;
		MOV 	#0FFH,TABLERO
		MOV 	#0FFH,TABLERO+1
		MOV 	#0FFH,TABLERO+2
		MOV 	#0FFH,TABLERO+3
		MOV 	#0FFH,TABLERO+4
		MOV 	#0FFH,TABLERO+5
		MOV 	#0FFH,TABLERO+6
		MOV 	#0FFH,TABLERO+7
		MOV 	#0FFH,TABLERO+8
		MOV 	#0FFH,TABLERO+9
		MOV 	#0FFH,TABLERO+10
		MOV 	#0FFH,TABLERO+11
		MOV 	#0FFH,TABLERO+12
		MOV 	#0FFH,TABLERO+13
		MOV 	#0FFH,TABLERO+14
		MOV 	#0FFH,TABLERO+15
		MOV 	#0FFH,TABLERO+16
;------------------------------------------
;----------------CICLO PRINCIPAL-----------		
CICLO:	JSR		VISUAL;
		JMP 	CICLO;
;----------------------------------------------------------------------
;-------------------INTERRUPCION IRQ------------------------------------		
INT_IRQ:
;----------------------------------------------------------------------
;-------------------INTERRUPCION KBI------------------------------------		
INT_KBI:
;--------------ORGANIZACION Y ENMASCARADO DATOS LEIDOS---------------------	
;--------VISUALIZACION DINAMICA ------------------------------
VISUAL:	MOV		#10H,CONT
CICLOV:	MOV		#0H,PTCD
		;-------------
		LDHX	#50000D
		JSR	    TIEMPO;
		LDHX	#50000D
		JSR	    TIEMPO;
		LDHX	#50000D
		JSR	    TIEMPO;
		LDHX	#50000D
		JSR	    TIEMPO;
		LDHX	#50000D
		JSR	    TIEMPO;
		LDHX	#50000D
		JSR	    TIEMPO;
		LDHX	#50000D
		JSR	    TIEMPO;
		LDHX	#50000D
		JSR	    TIEMPO;
	
		;-------------
		LDX		CONT;
		LDA		TABLERO,X
		AND		#0FH;
		STA		PTBD
		LDA		TABLERO,X
		AND		#33H;
		STA		PTFD
		MOV		#08H,PTCD			;Configuracion del reloj del contador
		;-------------
		LDHX	#50000D
		JSR	    TIEMPO;
		LDHX	#50000D
		JSR	    TIEMPO;
		LDHX	#50000D
		JSR	    TIEMPO;
		LDHX	#50000D
		JSR	    TIEMPO;
		LDHX	#50000D
		JSR	    TIEMPO;
		LDHX	#50000D
		JSR	    TIEMPO;
		LDHX	#50000D
		JSR	    TIEMPO;
		LDHX	#50000D
		JSR	    TIEMPO;
		;-------------
		DBNZ	CONT,CICLOV
		RTS

;--------INICIO RUTINA DE TIEMPO------------------------------
TIEMPO: AIX		#-1D         ; pierde tiempo
		CPHX	#0H          ; compara HX con 0
		BNE		TIEMPO       ; Si hx es igual a 0 sigue
		RTS                  ; retorna
;--------RUTINA COMANDO---------------------------------- Envia Informacion a la LCD 
COMANDO:BCLR	RS,		PTDD					;Mandamos el bit RS del LCD al 0 para saber que vamos a enviar un comando
		JMP		SALTOLCD						;Pasamos a hacer el pulso del enable
DATOLCD:BSET	RS,		PTDD				;Mandamos el bit RS del LCD a 1 para saber que vamos a enviar un dato
SALTOLCD:
		BSET	ENABLE,	PTDD				;Mandamos el pulso en alto al bit ENABLE del LCD
		NOP									;Con esto esperamos tiempo en alto del bit ENABLE		
		NOP
		NOP
		NOP									;Con esto esperamos tiempo en alto del bit ENABLE		
		NOP
		NOP
		NOP
		BCLR	ENABLE,	PTDD				;Bajamos el bit a 0 y así aseguramos el pulso
		PSHX								;Guarda datos correspondientes lo que venia antes  
		PSHH								;para subrutina de tiempo no sobre escriba
		LDHX	#50D
		JSR		TIEMPO
		PULH								;Obtiene 
		PULX								;Datos
		RTS
		
		
TABLAF1:FCB 'LVL: 0 BEST: 0000',0FFH
TABLAF2:FCB 'POINT: 0000      ',0FFH
TABLAN:FCB '0','1','2','3','4','5','6','7','8','9',0FFH
;---------------------------------------------------------------				
;------VECTORES DE INTERUPCION----------------------------------
		ORG		0FFCCH
		FDB		INT_KBI
		
		ORG		0FFFAH
		FDB		INT_IRQ
;---------------------------------------------------------------				
;------POSICION DE INICIO----------------------------------
		ORG     0FFFEH
		FDB		INICIO

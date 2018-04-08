	INCLUDE 'MC9S08JM16.INC' 
	
;INTERUPCIONES 	
KBIE	EQU		1
KBACK	EQU		2
IRQACK	EQU	2
;LCD
RS		EQU	0		;Define bit 0 del PTD
ENABLE	EQU	1		;Define bit 1 del PTD

;RELOJ INTERNO
LOCK	EQU	6		;Bit 6 del registro MCGSC

		ORG 	0B0H  ;Direccion de RAM  (Variables)
			
TABLERO   DS 21
CUADRO 	  DS 4 
CONT      DS 1
CONTP	  DS 1
FILA_C    DS 1
COLUM_C    DS 1
PUNTAJE   DS 2
PUNTAJE_M DS 2
NIVEL     DS 1  
GAME_OVER DS 1
START     DS 1
PAUSE     DS 1
AUX		  DS 1
SEM_1	  DS 1
SEM_2	  DS 1
FUENT	  DS	1	
DEST	  DS 1
TEMP 	  DS 1

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
		BCLR	ENABLE,	PTDD			;Mandamos el bit 1 del registro D a 0
		MOV 	#00111000B,	PTED			;Enviamos el comando para colocar bus a 8 BITS, las 2 lineas habilitadas y matriz de 5x7 en cada cuadro
		JSR		COMANDO					;Saltamos a sub rutina para enviar el comando
		MOV		#00000110B,	PTED			;Enviamos el comando para escribir de izquierda a derecha y display estático
		JSR		COMANDO					;Saltamos a sub turtina para enviar el comando
		MOV		#00001100B,	PTED			;Enviamos el comando para encender el display, apagar el cursor y mantener el cursor estático
		JSR		COMANDO					;Saltamos a sub rutina para enviar el comando
		MOV 	#00000001B,	PTED			;Enviamos el comando para borrar el display
		JSR		COMANDO
		LDHX	#20000D
		JSR		TIEMPO
		MOV		#10000000B,	PTED			;Enviamos comando para mover el cursor a la posición 2 en la línea 1
		JSR		COMANDO
		LDHX	#0		
;--------------------------------------		
;----------------Limpia Variables------
		;--------------------------------------		
;----------LIMPIA VARIABLES------------
		MOV		#0H,PTFD;
		MOV		#0H,PTBD;
		MOV		#0H,PTCD
		MOV		#0H,CONT;;Configuracion UP del reloj del contador		
SINCR:	MOV		#8H,PTCD	;POR LO PONEMOS EN CERO
		LDHX	#01H		; TIEMPO EN ALTO 50 D 
		JSR	    TIEMPO		;	
		;-------------
		MOV		#0H,PTCD	;Configuracion UP del reloj del contador
		;-------------
		LDHX	#01H		;HACEMOS UN PERIODO DE 50 us
		JSR	    TIEMPO		;
		LDA		CONT		;
		INCA				;
		STA		CONT		;		
		CBEQA	#0FH,FINSINC;
		JMP 	SINCR		;
FINSINC:
		;-----VACIA TABLERO PRINCIPAL
		MOV 	#0FFH,TABLERO; PISO
		MOV 	#0H,TABLERO+1;
		MOV 	#0H,TABLERO+2;
		MOV 	#0H,TABLERO+3;
		MOV 	#0H,TABLERO+4;
		MOV 	#0H,TABLERO+5;
		MOV 	#0H,TABLERO+6;
		MOV 	#0H,TABLERO+7;
		MOV 	#0H,TABLERO+8;
		MOV 	#0H,TABLERO+9;
		MOV 	#0H,TABLERO+10;
		MOV 	#0H,TABLERO+11;
		MOV 	#0H,TABLERO+12;
		MOV 	#0H,TABLERO+13;
		MOV 	#0H,TABLERO+14;
		MOV 	#0H,TABLERO+15;
		MOV		#0H,TABLERO+16;
		MOV		#0H,TABLERO+17;
		MOV		#0H,TABLERO+18;
		MOV 	#0H,TABLERO+19;
		MOV 	#0H,TABLERO+20;
		
		MOV		#0H,CUADRO
		MOV		#00011100B,CUADRO+1
		MOV		#00001000B,CUADRO+2
		MOV		#0H,CUADRO+3
		;----------------------
		MOV		#20D,FILA_C
		MOV		#0H,COLUM_C;
		MOV		#02H,CONTP;
		MOV		#0H,PTCD; POR LO PONEMOS EN CERO

;------------------------------------------
;----------------CICLO PRINCIPAL-----------		
CICLO:
	JSR VISUAL
	JMP 	CICLO;
;----------------------------------------------------------------------
;-------------------INTERRUPCION IRQ------------------------------------		
INT_IRQ:
;----------------------------------------------------------------------
;-------------------INTERRUPCION KBI------------------------------------		
INT_KBI:
;--------------RUTINA VISUALIZAR---------------------	
VISUAL:	MOV		#1H,CONT;
		MOV		#0H,PTCD	;Configuracion UP del reloj del contador		
CICLOV:	
;------- AUMENTA CONTEO-----
		LDA 	CONT
		CBEQA   #1H,VSALTO	
		MOV		#8H,PTCD	;POR LO PONEMOS EN CERO
VSALTO:	;-------------
		LDHX	#01FEH		; TIEMPO EN ALTO 50 D 
		JSR	    TIEMPO		;	
		;-------------
		MOV		#0H,PTCD	;Configuracion UP del reloj del contador
		;-------------
		LDHX	#01FEH		;HACEMOS UN PERIODO DE 50 us
		JSR	    TIEMPO		;
		LDA		FILA_C		
		CBEQ	CONT,VPR	;
		DECA				;F+1
		CBEQ	CONT,VPR	;
		DECA				;F+2
		CBEQ	CONT,VPR	;
		DECA				;F+3
		CBEQ	CONT,VPR;
		LDX		CONT
		LDA		TABLERO,X;
		JMP		VAND  
VPR:	LDA		FILA_C		;	
		SUB     CONT		;
		PSHA				;PONE EN LA PILA Z
		LDX		CONT		;CARGA X CON CONTADOR	
		LDA		TABLERO,X	;X NO SE MODIFICA 
		PULX		
		ORA		CUADRO,X	;INCREMENTO PARA COLUMNA+3 EN A 
VAND:	PSHA				;PONGO EN LA PILA A 
		;----------------
		STA		AUX			;
		MOV		#0H,PTFD	;
		BRCLR	4H,AUX,AJ1	;
		BSET	0H,PTFD		;
AJ1:	BRCLR	5H,AUX,AJ2
		BSET	1H,PTFD
AJ2:	BRCLR	6H,AUX,AJ3
		BSET	4H,PTFD
AJ3:	BRCLR	7H,AUX,VC
		BSET	5H,PTFD				
VC:		PULA				;OBTENGO EL DATO
		AND		#0FH		;SE ENMASCARA
		STA		PTBD		; IMPRIME EN EL PUERTO B
	
;-----------RENUEVA VARIABLE
		LDA		CONT		;
		INCA				;
		STA		CONT		;		
		CBEQA	#11H,VFIN	;
		JMP 	CICLOV		;
VFIN:	MOV		#08H,PTCD	;Configuracion UP del reloj del contador
		;-------------
		LDHX	#01FEH		;HACEMOS UN PERIODO DE 50 us
		JSR	    TIEMPO;
		LDA 	CONT
		MOV		#0H,PTCD	;POR LO PONEMOS EN CERO
		LDHX	#01EFH; TIEMPO EN ALTO 50 D 
		JSR	    TIEMPO
		RTS

;--------INICIO RUTINA DE TIEMPO------------------------------
TIEMPO: AIX		#-1D         ; pierde tiempo
		CPHX	#0H          ; compara HX con 0
		BNE		TIEMPO       ; Si hx es igual a 0 sigue
		RTS                  ; retorna
;--------RUTINA COMANDO---------------------------------- Envia Informacion a la LCD 
COMANDO:BCLR	RS,		PTDD					;Mandamos el bit RS del LCD al 0 para saber que vamos a enviar un comando
		JMP		SALTOLCD						;Pasamos a hacer el pulso del enable
DATOLCD:
		BSET	RS,		PTDD				;Mandamos el bit RS del LCD a 1 para saber que vamos a enviar un dato
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

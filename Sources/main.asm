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
;---------------------------------------------------------------------------------
;------------------CONFIGURACION DE ALEATORIO-------------------------------------
		LDA     SEM_1
		ADD     PUNTAJE_M
		STA     SEM_1
		LDX     #100D
		CLRH
		DIV 
		PSHH
		PULA
		CMP     #11D
		BPL     CMP10_1
		MOV     #13D,SEM_1
CMP10_1:INC     SEM_2
		CLRH
		DIV 
		PSHH
		PULA
		STA 	SEM_2
		CMP     #11D
		BPL     CMP10_2
		MOV     #15D,SEM_1

;-------------------------------------------------------------------------------
;------------------CONFIGURACION LCD--------------------------------------------
CMP10_2:LDHX	#50000D
		JSR		TIEMPO		
		MOV		#0FFH,	PTEDD			;Configuramos el puerto E todo como salidas
		MOV		#3,		PTDDD			;Configuramos bits 0 y 1 del puerto D como salidas
		BCLR	ENABLE,	PTDD				;Mandamos el bit 1 del registro D a 0
		MOV #00111000B,	PTED			;Enviamos el comando para colocar bus a 8 BITS, las 2 lineas habilitadas y matriz de 5x7 en cada cuadro
		JSR		COMANDO					;Saltamos a sub rutina para enviar el comando
		MOV	#00000110B,	PTED			;Enviamos el comando para escribir de izquierda a derecha y display est�tico
		JSR		COMANDO					;Saltamos a sub turtina para enviar el comando
		MOV	#00001100B,	PTED			;Enviamos el comando para encender el display, apagar el cursor y mantener el cursor est�tico
		JSR		COMANDO					;Saltamos a sub rutina para enviar el comando
		MOV #00000001B,	PTED			;Enviamos el comando para borrar el display
		JSR		COMANDO
		LDHX	#20000D
		JSR		TIEMPO
		MOV	#10000000B,	PTED			;Enviamos comando para mover el cursor a la posici�n 2 en la l�nea 1
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
;----------LIMPIA VARIABLES------------
		MOV		#0H,PTFD;
		MOV		#0H,PTBD;
		MOV		#0H,PTCD
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
		
		MOV		#0FH,CUADRO
		MOV		#07H,CUADRO+1
		MOV		#03H,CUADRO+2
		MOV		#01H,CUADRO+3
		;----------------------
		MOV		#21D,FILA_C
		MOV		#0H,COLUM_C;
		MOV		#0FFH,CONTP;
		MOV		#0H,PTCD; POR LO PONEMOS EN CERO
;------------------------------------------
;----------------CICLO PRINCIPAL-----------		
CICLO:	JSR		VISUAL;
		DBNZ    CONTP,CICLO; SALTE A CICLO O HAGA LA LOGICA
		LDA		#2H;
		JSR		MOVI;
		MOV		#0AFH,CONTP;
END:	JMP 	CICLO;
;----------------------------------------------------------------------
;-------------------INTERRUPCION IRQ------------------------------------		
INT_IRQ:
;----------------------------------------------------------------------
;-------------------INTERRUPCION KBI------------------------------------		
INT_KBI:
;--------------ORGANIZACION Y ENMASCARADO DATOS LEIDOS---------------------	
;--------VISUALIZACION DINAMICA ------------------------------
MOVI:	CBEQA	#0H,RIG;
		CBEQA	#1H,LEF;
		DEC		FILA_C;
		LDX		FILA_C;
		LDA		TABLERO,X
		LDX		#0H;
		AND		CUADRO,X
		CBEQA	#0H,MAJ1
		JMP		MREG
MAJ1:	LDX		FILA_C;
		DECX		  ;
		LDA		TABLERO,X
		LDX		#1H;
		AND		CUADRO,X
		CBEQA	#0H,MAJ2		
		JMP		MREG
MAJ2:	LDX		FILA_C;
		DECX		  ;
		DECX		  ; 
		LDA		TABLERO,X
		LDX		#2H;
		AND		CUADRO,X
		CBEQA	#0H,MAJ3		
		JMP		MREG	
MAJ3:	LDX		FILA_C;
		DECX		  ;
		DECX
		DECX
		LDA		TABLERO,X
		LDX		#3H;
		AND		CUADRO,X
		CBEQA	#0H,MORTS		
		JMP		MREG
MORTS:	RTS				; POSICION VALIDA REGRESA PARA VISUALIZAR		
MREG: 	INC		FILA_C	;
		LDX		FILA_C
		LDA		TABLERO,X
		EOR		CUADRO;
		STA		TABLERO,X
		DEC		FILA_C		;DECREMENTA FILA PARA GUARDAR PERDIENDO PIBOTE 
		LDX		FILA_C		;
		LDA		TABLERO,X
		EOR		CUADRO+1;
		STA		TABLERO,X
		DEC		FILA_C		;DECREMENTA FILA PARA GUARDAR PERDIENDO PIBOTE 
		LDX		FILA_C		;
		LDA		TABLERO,X
		EOR		CUADRO+2;
		STA		TABLERO,X
		DEC		FILA_C		;DECREMENTA FILA PARA GUARDAR PERDIENDO PIBOTE 
		LDX		FILA_C		;
		LDA		TABLERO,X
		EOR		CUADRO+3;
		STA		TABLERO,X
		MOV		#20D,FILA_C	;
		RTS					;
RIG:
LEF:		

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
		LDX		FILA_C		;CARGA X CON CONTADOR
		DECX	
		LDA		TABLERO,X	;X NO SE MODIFICA 
		PULX
		EOR		CUADRO,X	;INCREMENTO PARA COLUMNA+3 EN A 
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
DATOLCD:BSET	RS,		PTDD				;Mandamos el bit RS del LCD a 1 para saber que vamos a enviar un dato
SALTOLCD:
		BSET	ENABLE,	PTDD				;Mandamos el pulso en alto al bit ENABLE del LCD
		NOP									;Con esto esperamos tiempo en alto del bit ENABLE		
		NOP
		NOP									;Con esto esperamos tiempo en alto del bit ENABLE		
		NOP
		NOP
		NOP
		BCLR	ENABLE,	PTDD				;Bajamos el bit a 0 y as� aseguramos el pulso
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

	INCLUDE 'MC9S08JM16.INC' 
	
LOCK	EQU		6    ; Verificar el enganche del reloj
LEDV	EQU     2
LEDA    EQU     3
LEDR    EQU     4

		ORG 	0B0H  ;Direccion de memoria de variables
			
AUTOSET DS 1
V1      DS 1
A1      DS 1
R1      DS 1 
V2 		DS 1
AUX     DS 1
CONT    DS 1 

		ORG		0C000H; Direccion de memoria para programa

INICIO:	CLRA 				      ;Limpiar acumulador
		STA		SOPT1		      ;Desbilitar
		LDHX	#4B0H 		      ;Reubicar pila
		TXS 			          ;Lo que esta en x a la posicion de la pila
		MOV		#0AAH,MCGTRM;	
		MOV		#6,MCGC1		  ;Ajuste frecuencia del oscilador interno
		BRCLR	LOCK,MCGSC,*      ;Espere a que el oscilador se enganche
		MOV		#00011100B,PTBDD  ;PUERTO B SALIDA 3 PINES DE SALIDA   
		LDA		#00000011B        ;PARA RESISTENCIA DE PULL-UP  00011000
		STA		PTBPE 			  ;PUERTO B ENTRADA /
		CLR 	AUTOSET           ;--------------------------
		MOV 	#6H, V1
		MOV 	#5H, AUX           ; Valores de la secuencia 1
		MOV 	#4H, R1
		MOV 	#1H, A1
		MOV 	#2H, V2            ;--------------------------	


;--------INICIO RUTINA DE TIEMPO------------------------------
TIEMPO: LDHX    #50000D     ; Tiempo de 50ms
CICLOT: AIX		#-1D         ; pierde tiempo
		CPHX	#0H          ; compara HX con 0
		BNE		CICLOT      ; Si hx es igual a 0 sigue
		DBNZA   TIEMPO      ; si acomulador es igual a 0 sigue 
		LDA     #1H          ; carga acomulador con 1 para 1s
		RTS                 ; retorna
;--------FIN RUTINA DE TIEMPO-----------------------------------		
		ORG     0FFFEH
		FDB		INICIO

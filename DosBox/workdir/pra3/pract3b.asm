;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 	SBM 2019. Practica 3									;
;   Javier Delgado del Cerro								;
;	Javier Lopez Cano										;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DGROUP GROUP _DATA, _BSS				;; Se agrupan segmentos de datos en uno

_DATA SEGMENT WORD PUBLIC 'DATA' 		;; Segmento de datos DATA publico

_DATA ENDS

_BSS SEGMENT WORD PUBLIC 'BSS'			;; Segmento de datos BSS publico

_BSS ENDS

_TEXT SEGMENT BYTE PUBLIC 'CODE' 		;; Definicion del segmento de codigo
ASSUME CS:_TEXT, DS:DGROUP, SS:DGROUP

;; DEFINIMOS CONSTANTES PARA EVITAR 'NUMEROS MAGICOS'
ASCII_CERO_SUM		EQU		30h
NUM_DIG_COUNTRY		EQU 	3
NUM_DIG_COMPANY		EQU 	4
NUM_DIG_PRODUCT		EQU 	5
NUM_DIG_CONTROL		EQU 	1

PUBLIC _createBarCode					;; Hacer visible y accesible la función desde C
_createBarCode PROC FAR 				;; En C es int unsigned long int factorial(unsigned int n)
	PUSH BP 							;; Salvaguardar BP en la pila para poder modificarle sin modificar su valor
	MOV BP, SP							;; Igualar BP el contenido de SP
	
	PUSH DS ES AX BX CX SI				;; Guardamos el contenido de los registros
	
	LDS BX, [BP + 16]					;; Leemos la direccion donde guardar el codigo de barras

	MOV AX, [BP + 6]					;; Leemos el country code
	XOR DX, DX
	PUSH DS 							;; Pasamos la direccion donde escribir 
	PUSH BX
	MOV CX, NUM_DIG_COUNTRY	
	PUSH CX								;; Pasamos el numero de digitos a escribir
	PUSH DX 							;; Pasamos los 4 bytes que puede llegar a tener el numero
	PUSH AX
	CALL NUM_ASCII
	ADD BX, NUM_DIG_COUNTRY				;; Avanzamos BX hasta el siguiente campo
	ADD SP, 10

	MOV AX, [BP + 8]					;; Leemos el company code
	XOR DX, DX
	PUSH DS 							;; Pasamos la direccion donde escribir 
	PUSH BX
	MOV CX, NUM_DIG_COMPANY	
	PUSH CX								;; Pasamos el numero de digitos a escribir
	PUSH DX 							;; Pasamos los 4 bytes que puede llegar a tener el numero
	PUSH AX
	CALL NUM_ASCII
	ADD BX, NUM_DIG_COMPANY				;; Avanzamos BX hasta el siguiente campo
	ADD SP, 10

	MOV AX, [BP + 10]					;; Leemos el product code
	MOV DX, [BP + 12]
	PUSH DS 							;; Pasamos la direccion donde escribir 
	PUSH BX
	MOV CX, NUM_DIG_PRODUCT
	PUSH CX								;; Pasamos el numero de digitos a escribir
	PUSH DX 							;; Pasamos los 4 bytes que puede llegar a tener el numero
	PUSH AX
	CALL NUM_ASCII
	ADD BX, NUM_DIG_PRODUCT				;; Avanzamos BX hasta el siguiente campo
	ADD SP, 10

	MOV AX, [BP + 14]					;; Leemos el control code
	XOR AH, AH
	XOR DX, DX
	PUSH DS 							;; Pasamos la direccion donde escribir 
	PUSH BX
	MOV CX, NUM_DIG_CONTROL
	PUSH CX								;; Pasamos el numero de digitos a escribir
	PUSH DX 							;; Pasamos los 4 bytes que puede llegar a tener el numero
	PUSH AX
	CALL NUM_ASCII
	ADD BX, NUM_DIG_CONTROL				;; Avanzamos BX hasta el siguiente campo
	ADD SP, 10

	MOV BYTE PTR DS:[BX], 0				;; Escribimos el caracter de fin de cadena de C

	POP SI CX BX AX ES DS				;; Restaurar los registros antes de salir
	POP BP								;; Restaurar el valor de BP antes de salir
	RET									;; Retorno de la funcion que nos ha llamado, devolviendo el resultado del computeControlDigit en AX
_createBarCode ENDP						;; Termina la funcion computeControlDigit


; Escribe en una posicion pasada el numero recibido rellenando con ceros a la izquierda
; Esto es posible porque sabemos cuantos digitos vamos a necesitar en cada caso.

;_______________________________________________________________ 
; SUBRUTINA PARA CONVERTIR UN NUMERO DE 4B A N DIGITOS ASCII,
; RELLENANDO CON CEROS A LA IZQUIERDA SI ES NECESARIO. 
; ENTRADA: POR LA PILA, DE POSICIONES MAYORES A MENORES:
; 			- SEGMENTO DE DONDE ESCRIBIR EL NUMERO EN ASCII
;			- OFFSET DONDE DEBE EMPEZAR EL NUMERO EN ASCII
;			- N, NUMERO DE DIGITOS DEL NUMERO A ESCRIBIR
;			- PARTE ALTA DEL NUMERO
;			- PARTE BAJA DEL NUMERO
;_______________________________________________________________ 
NUM_ASCII PROC NEAR
	PUSH BP 							
	MOV BP, SP
	
	PUSH SI AX BX CX DX DS

	MOV AX, [BP + 4]					;; Cargamos el numero en DX:AX
	MOV DX, [BP + 6]
	MOV SI, [BP + 8]					;; Cargamos el numero de digitos a escribir
	LDS BX, [BP + 10]					;; Cargamos la direccion en la que escribir en DS:BX
	
	MOV CX, 10

	DIVIDIR:
	DEC SI
										;; Dividimos el numero en DX:AX entre 10
	DIV CX
	ADD DL, ASCII_CERO_SUM				;; Convertimos el resto a ASCII
	MOV DS:[BX][SI], DL 				;; Almacenamos el resto en su posicion correspondiente

	CMP AX, 0				
	JZ COMPLETAR_CEROS
	CMP SI, 0
	JZ FIN 								;; Comprobamos que no escribamos más digitos de los pedidos
	XOR DX, DX							;; El numero es, como maximo, de 5 cifras. Una vez dividido por 10 cabe en 2B
	JMP DIVIDIR

	COMPLETAR_CEROS:					;; Rellenamos con ceros en ASCII la parte izquierda
	CMP SI, 0
	JZ FIN
	DEC SI
	MOV BYTE PTR DS:[BX][SI], ASCII_CERO_SUM
	JMP COMPLETAR_CEROS

	FIN:
	POP DS DX CX BX AX SI 				;; Reestablecemos la pila y terminamos la funcion
	POP BP
	RET

NUM_ASCII ENDP

_TEXT ENDS
END
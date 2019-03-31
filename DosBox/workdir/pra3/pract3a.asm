;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 	SBM 2019. Practica 3									;
;   Javier Delgado del Cerro								;
;	Javier Lopez Cano										;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DGROUP GROUP _DATA, _BSS				;; Se agrupan segmentos de datos en uno

_DATA SEGMENT WORD PUBLIC 'DATA' 		;; Segmento de datos DATA p�blico

_DATA ENDS

_BSS SEGMENT WORD PUBLIC 'BSS'			;; Segmento de datos BSS p�blico

_BSS ENDS

_TEXT SEGMENT BYTE PUBLIC 'CODE' 		;; Definici�n del segmento de c�digo
ASSUME CS:_TEXT, DS:DGROUP, SS:DGROUP
			

PUBLIC _computeControlDigit				;; Hacer visible y accesible la funci�n desde C
_computeControlDigit PROC FAR 			;; En C es int unsigned long int factorial(unsigned int n)
	PUSH BP 							;; Salvaguardar BP en la pila para poder modificarle sin modificar su valor
	MOV BP, SP							;; Igualar BP el contenido de SP
	
	PUSH ES BX CX SI					;; Guardamos el contenido de los registros
	
	LES BX, [BP + 6]					;; Leemos la direccion del codigo de barras
	MOV CL, ES:[BX]						;; Sumamos todos los impares
	ADD CL, ES:[BX + 2]
	ADD CL, ES:[BX + 4]
	SUB CL, 30H*3						;; Pasamos de ASCII a binario. Como cada uno esta entre 30h y 39h, no se pueden desbordar
	ADD CL, ES:[BX + 6]
	ADD CL, ES:[BX + 8]
	ADD CL, ES:[BX + 10]
	SUB CL, 30H*3						;; Pasamos de ASCII a binario. Como cada uno esta entre 30h y 39h, no se pueden desbordar
	
	MOV SI, 1
	
	PARES:
	MOV AL, ES:[BX][SI]					;; Multiplicamos los numeros pares por tres y los sumamos. La suma siempre va a ser menor de 255
	SUB AL, 30H
	ADD CL, AL
	ADD CL, AL
	ADD CL, AL
	ADD SI, 2
	CMP SI, 13							;; Cuando SI > 11, ya hemos acabado. Como empezamos en 1 y vamos de dos en dos
	JNZ PARES
	
	XOR AH, AH							;; Calculamos el digito de control
	MOV AL, CL
	MOV CL, 10
	DIV CL
	ADD AH, 0
	JZ FIN
	
	SUB CL, AH
	MOV AH, CL
		
	FIN:
		MOV AL, AH
		XOR AH, AH
		POP SI CX BX ES					;; Restaurar los registros antes de salir
		POP BP							;; Restaurar el valor de BP antes de salir
		RET								;; Retorno de la funcion que nos ha llamado, devolviendo el resultado del computeControlDigit en AX
_computeControlDigit ENDP				;; Termina la funcion computeControlDigit

PUBLIC _decodeBarCode					;; Hacer visible y accesible la funci�n desde C
_decodeBarCode PROC FAR 				;; En C es int unsigned long int factorial(unsigned int n)
	PUSH BP 							;; Salvaguardar BP en la pila para poder modificarle sin modificar su valor
	MOV BP, SP							;; Igualar BP el contenido de SP
	
	PUSH DS ES BX CX SI					;; Guardamos el contenido de los registros
	
	LES BX, [BP + 6]					;; Leemos la direccion del codigo de barras
	LDS SI, [BP + 10]					;; Leemos la direccion de country code
	
	;; Cargamos el codigo de pais
	PUSH ES
	PUSH BX
	MOV DX, 3
	PUSH DX
	CALL ASCII_NUM
	MOV DS:[SI], AX ;; Escribimos en memoria el resultado. Sabemos que en este caso son solo dos bytes


	; TODO Quitar numeros mágicos: quitr 3*2 y poner NUM_DIG_COMPANY
	ADD BX, 3*2 ;; Nos posicionamos al comienzo del codigo de empresa
	LDS SI, [BP + 14]					;; Leemos la direccion de companyCode
	PUSH ES
	PUSH BX
	MOV DX, 4
	PUSH DX
	CALL ASCII_NUM
	MOV DS:[SI], AX ;; Escribimos en memoria el resultado. Sabemos que en este caso son solo dos bytes

	;; TODO QUITAR 4*2, NUMERO MAGICO
	ADD BX, 4*2 ;; Nos posicionamos al comienzo del codigo de producto
	LDS SI, [BP + 18]					;; Leemos la direccion de productCode
	PUSH ES
	PUSH BX
	MOV DX, 5
	PUSH DX
	CALL ASCII_NUM
	MOV DS:[SI], AX ;; Escribimos en memoria el resultado. Sabemos que en este caso son cuatro bytes
	MOV DS:[SI + 2], DX

	;; TODO QUITAR NUMERO MAGICO
	ADD BX, 5*2	;; Nos posicionamos al comienzo del codigo de control
	LDS SI, [BP + 14]					;; Leemos la direccion de controlDigit
	PUSH ES
	PUSH BX
	MOV DX, 1
	PUSH DX
	CALL ASCII_NUM
	MOV DS:[SI], AL ;; Escribimos en memoria el resultado. Sabemos que en este caso es solo un byte
		
	MOV AL, AH
	XOR AH, AH
	POP SI CX BX ES	DS					;; Restaurar los registros antes de salir
	POP BP								;; Restaurar el valor de BP antes de salir
	RET									;; Retorno de la funcion que nos ha llamado, devolviendo el resultado del computeControlDigit en AX
_decodeBarCode ENDP						;; Termina la funcion computeControlDigit



; Devuelve un numero de hasta 17bits en DX:AX
ASCII_NUM PROC NEAR
	PUSH BP 							
	MOV BP, SP
	
	PUSH SI BX CX DX DS
	MOV BX, [BP + 6]	; Numero de digitos a leer, >= 1
	LDS SI, [BP + 8]
	
	MOV SI, 0
	MOV CX, 10
	XOR DX, DX

	; Cargamos el numero entre la posicion que indica BX y SI
	CARGAR_NUM:
	; Cargamos el numero en AX
	MOV AL, DS:[SI]
	SUB AL, 30h
	XOR AH, AH

	INC SI
	DEC BX
	JZ FIN_CONVERSION

	MUL CX
	JMP CARGAR_NUM


	FIN_CONVERSION:
	POP DS DX CX BX SI
	POP BP
	RET

ASCII_NUM ENDP


_TEXT ENDS
END
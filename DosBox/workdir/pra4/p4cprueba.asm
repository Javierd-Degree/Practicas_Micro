codigo SEGMENT
	ASSUME cs : codigo
	ORG 256
	
INICIO:
	MOV AX, codigo
	MOV CS, AX
	MOV DS, AX

	;; TODO Calcular inversa etc

	# En DS ya esta el segmento de la rutina
	MOV DX, OFFSET cadena


	INICIO_FIN:
	; Terminamos el programa
	MOV AX, 4C00h
	INT 21h



;; Variables globales
NUM_RUTINA	EQU 57h
FIRMA 		EQU "KK"
CADENA DB "HOLA"
PROGRAMA_INSTALADO_STR DB "Programa ya instalado en memoria",13,10,"$"
PROGRAMA_NO_INSTALADO_STR DB "Programa no instalado",13,10,"$"
INFORMACION_PROGRAMA DB "Desarrollado por la pareja formada por Javier Delgado del Cerro y Javier Lopez Cano",13,10,"$"
ERRR_PARAMETROS_STR DB "El programa solo se puede ejecutar de tres formas: ", 13, 10, "- Sin parametros para mostrar si esta o no instalado.", 13, 10, "- Con /I para instalarlo.", 13, 10, "- Con /D para desinstalarlo.",13,10,"$"
ERR_PARAM_INTERR_STR DB "La interrupción admite los siguientes parámetros en AH:", 13, 10, "- Codificar: 10h", 13, 10, "- Decodificar: 11h", 13, 10, "$"

matrizPolibio DB "345678", "9ABCDE", "FGHIJK", "LMNOPQ", "RSTUVW", "XYZ012"
matrizInversa DB 256 dup(?, ?)
FLAG DW 0
CONTADOR DW 0
INDEX DW 0
TEMP DB 256 dup(?)
sign DB "KK"

; Rutina de servicio a la interrupción
RSI_2 PROC FAR
	PUSH AX BX CX SI DI

	MOV BX, DX
	
	CMP AH, 10h
	JZ CODIFICACION
	CMP AH, 11h
	JZ DECODIFICACION

	;; La funcion especificada no existe, salimos sin hacer nada
	JMP FIN
	
	CODIFICACION:
	XOR SI, SI
	BUCLE_CODIFICACION:
	MOV DI,  DS:[BX][SI]	;; Leemos el caracter en DI
	AND DI, 00FFh			;; Solo queremos leer los 8bytes del primer caracter
	CMP DI, 13
	JZ FIN_COD
	ADD DI, DI
	MOV DX, WORD PTR matrizInversa[DI]		;; Cargamos en DL la fila, en DH la columna
	MOV DI, SI
	ADD DI, DI
	MOV WORD PTR TEMP[DI], DX
	INC SI
	JMP BUCLE_CODIFICACION

	FIN_COD:
	ADD SI, SI
	MOV TEMP[SI], '$'
	JMP FIN
	
	DECODIFICACION:
	XOR DI, DI
	BUCLE_DECODIFICACION:
	MOV SI, DI
	ADD SI, SI
	MOV AX,  DS:[BX][SI]	;; Leemos las dos coordenadas. En AH la segunda y en AL la primera
	CMP AL, 13			;; La cadena ha acabado
	JZ FIN_DECOD
	
	;; Restar 30h a ambos para pasar a decimal, Buscar en la tabla e imprimir.
	;; El elemento estará en 6*(AL-1) + AH-1
	SUB AL, 30h
	SUB AH, 30h
	XOR CL, CL
	CALC_COORD:			;; 	Calculamos CL = 6*(AL-1) Como son numeros pequeños nunca sobrepasan 255
	DEC AL
	CMP AL, 0
	JZ FIN_CALC
	ADD CL, 6
	JMP CALC_COORD

	FIN_CALC:
	DEC AH
	ADD CL, AH 			;; En AL tenemos la posicion del elemento
	XOR CH, CH 			;; Lo escribimos como 16bits para pasarlo a DI
	
	MOV SI, CX
	MOV DL, matrizPolibio[SI]
	MOV TEMP[DI], DL
	INC DI
	JMP BUCLE_DECODIFICACION

	FIN_DECOD:
	MOV TEMP[DI], '$'
	
	FIN:
	MOV WORD PTR FLAG, 0				;; Reseteamos el contador y el flag
	MOV WORD PTR CONTADOR, 0
	CALL IMPRIMIR
	POP DI SI CX BX AX
	IRET
RSI_2 ENDP

RSI_1 PROC FAR	
	PUSH AX
	MOV AX, CONTADOR
	INC AX
	MOV CONTADOR, AX
	CMP AX, 18
	JNE FIN_INT
	
	MOV WORD PTR FLAG, 1 
	MOV WORD PTR CONTADOR, 0

	FIN_INT:
	POP AX
	IRET
RSI_1 ENDP

IMPRIMIR PROC NEAR
	PUSH SI DX 

	XOR SI, SI
	MOV AH, 2h

	BUCLE_IMP:
	MOV DL, TEMP[SI]
	CMP DL, '$'
	JZ FIN_IMP

	BUCLE_TEMP:
	CMP WORD PTR FLAG, 1
	JNZ BUCLE_TEMP

	MOV FLAG, 0
	INT 21h
	INC SI
	JMP BUCLE_IMP

	FIN_IMP:
	POP DX SI 
	RET
IMPRIMIR ENDP

calcularInversa PROC NEAR
	PUSH AX BX CX DX SI DI

	XOR SI, SI
	XOR AX, AX
	XOR BX, BX
									;; Bucle externo con BL de 0 a 6, interno con BH de 0 a 6
	FOR_1:
	CMP BL, 6
	JZ FIN_INVERSA
	XOR BH, BH
	FOR_2:
	MOV DL, matrizPolibio[SI]
	XOR DH, DH
	ADD DX, DX
	MOV DI, DX 						;; Guardamos BL, BH en DI*2
	
	;; Almacenamos en matrizInversa[caracter*2] la fila y la columna, en ASCII, empezando por 1
	ADD BL, 31h
	ADD BH, 31h
	MOV WORD PTR matrizInversa[DI], BX
	SUB BL, 31h
	SUB BH, 31h
	
	INC SI
	INC BH
	CMP BH, 6
	JNZ FOR_2
	INC BL
	JMP FOR_1
	
	FIN_INVERSA:
	POP DI SI DX CX BX AX
	RET
calcularInversa ENDP

codigo ENDS
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION
END INICIO
	
codigo SEGMENT
	ASSUME cs : codigo
	ORG 256
	
INICIO:
	MOV CL, DS:[80h]			;; Comprobamos los parámetros de entrada
								
	CMP CL, 0					;; Si no hay ningun parametro, informamos del estado
	JNZ INICIO_PARAMETROS
	CALL SHOW_STATUS
	JMP INICIO_FIN

	INICIO_PARAMETROS:
	CMP CL, 3 					;; Si hay entrada, tiene que tener tamaño 3 (espacio+/+I o D)
	JNZ INICIO_ERR_PARAM
	MOV CX, DS:[82h]			;; Cargamos los dos caracteres a leer
	CMP CL, '/'					;; Aseguramos que el parámetro sea valido
	JNZ INICIO_ERR_PARAM

	CMP CH, 'I'					;; Si es una I, instalamos
	JZ INICIO_INSTALL

	CMP CH, 'D'					;; Si es una D, desinstalamos
	JZ INICIO_UNINSTALL

	JMP INICIO_ERR_PARAM 		;; Si no es ninguno de los anteriores, es incorrecto

	INICIO_INSTALL:
	JMP INSTALL

	INICIO_UNINSTALL:
	CALL UNINSTALL
	JMP INICIO_FIN

	INICIO_ERR_PARAM:
	MOV DX, OFFSET ERRR_PARAMETROS_STR		;; Mostramos las distintas formas de ejecutar el programa
	MOV AH, 9
	INT 21h
	JMP INICIO_FIN

	INICIO_FIN:
	; Terminamos el programa
	MOV AX, 4C00h
	INT 21h



;; Variables globales
NUM_RUTINA	EQU 57h
FIRMA 		EQU "KK"
TIEMPO	DB "TIEMPO$"
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

; Rutina de servicio a la interrupción 57h
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
	CMP DI, 13				;; En este caso, es una cadena leida de teclado, acaba en 13
	JZ FIN_COD   	
	ADD DI, DI
	MOV DX, WORD PTR matrizInversa[DI]		;; Cargamos en DL la fila, en DH la columna
	MOV DI, SI
	ADD DI, DI 	
	MOV WORD PTR TEMP[DI], DX 				;; Guardamos en TEMP las coordenadas para posteriormente imprimirlas
	INC SI 									;; Incrementamos el contador
	JMP BUCLE_CODIFICACION 					;; Saltamos al bucle para codificar el siguiente caracter.

	FIN_COD:
	ADD SI, SI
	MOV TEMP[SI], '$' 		;; Añadimos un '$' al final de TEMP para indicar que es el final de la cadena.
	JMP FIN_IMPRIMIR
	
	DECODIFICACION:
	XOR DI, DI
	BUCLE_DECODIFICACION:
	MOV SI, DI
	ADD SI, SI
	MOV AX,  DS:[BX][SI]	;; Leemos las dos coordenadas. En AH la segunda y en AL la primera
	CMP AL, 13				;; La cadena ha acabado
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
	ADD CL, AH 			;; En CL tenemos la posicion del elemento
	XOR CH, CH 			;; Lo escribimos como 16bits para pasarlo a DI
	
	MOV SI, CX
	MOV DL, matrizPolibio[SI]
	MOV TEMP[DI], DL
	INC DI
	JMP BUCLE_DECODIFICACION

	FIN_DECOD:
	MOV TEMP[DI], '$'
	
	FIN_IMPRIMIR:
	MOV WORD PTR FLAG, 0				;; Reseteamos el contador y el flag
	MOV WORD PTR CONTADOR, 0
	CALL IMPRIMIR  						;; Llamamos a la funcion que imprime la cadena.
	FIN:
	POP DI SI CX BX AX
	IRET
RSI_2 ENDP

;; Rutina de servicio a la interrupción 1Ch
RSI_1 PROC FAR	
	PUSH AX
	MOV AX, CONTADOR
	INC AX
	MOV CONTADOR, AX 		;; Incrementamos el contador.
	CMP AX, 18 				;; Cuando el contador lega a 18 ha pasado aproximadamente un segundo.
	JNE FIN_INT 			;; Si no ha pasado 1 segundo terminamos.
	
	MOV WORD PTR FLAG, 1 			;; Si ha pasado un segundo ponemos el falg a 1 para habilitar la impresión.
	MOV WORD PTR CONTADOR, 0		;; Reseteamos el contador.

	FIN_INT:
	POP AX
	IRET
RSI_1 ENDP

IMPRIMIR PROC NEAR
	PUSH SI DX 

	XOR SI, SI 			;; Ponemos SI a 0.
	MOV AH, 2h 			;; Ponemos en AH 2h (instrucción de impresión).

	BUCLE_IMP:
	MOV DH, TEMP[SI] 	;; Guardamos en DH el siguente caracter a imprimir.
	CMP DH, '$'			;; Comprobamos si es '$' pues este caracter indica el final de la cadena.
	JZ FIN_IMP

	BUCLE_TEMP:
	MOV DL, 7					
	INT 21h 					;; Imprimimos el caracter con ASCII 7 (nada) para dar tiempo a la interrupción 1Ch
	CMP WORD PTR FLAG, 1		;; Comprobamos si el FLAG que habilita la impresión está a 1.
	JNZ BUCLE_TEMP				;; Si no está a 1 saltamos de nuevo al bucle para no imprimir

	MOV WORD PTR FLAG, 0 		;; Si está a 1 lo ponemos a 0 y continuamos la impresión.
	MOV DL, DH 					;; Pasamos el caracter a imprimir de DH a DL para imprimirlo.
	INT 21h
	INC SI 						;; Imprimimos el caracter
	JMP BUCLE_IMP 				;; Saltamos al bucle de impresión para repetir el proceso con el siguiente caracter.

	FIN_IMP:
	MOV DL, 13
	INT 21H
	MOV DL, 10
	INT 21H 		;; Antes de acabar imprimimos un salto de linea.

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

;; TODO Comprobar al instalar desinstalar etc si el programa esta instalado

INSTALL:
	IN AX, 21h
	OR AX, 1
	OUT 21h, AX

	MOV AX, 0 
	MOV ES, AX
	MOV AX, OFFSET RSI_2 
	MOV BX, CS

	MOV ES:[NUM_RUTINA*4], AX 
	MOV ES:[NUM_RUTINA*4+2], BX 

	MOV CX, OFFSET RSI_1 

	MOV ES:[1Ch*4], CX 
	MOV ES:[1Ch*4+2], BX

	IN AX, 21h
	AND AX, 0FFFEh
	OUT 21h, AX
	
	CALL calcularInversa
	
	MOV DX, OFFSET INSTALL 
	INT 27h ; Acaba y deja residente 
			; PSP, variables y rutina rsi. 	
			
UNINSTALL PROC ; Desinstala RSI de INT 40h
	PUSH AX BX CX DS ES
	MOV CX, 0
	MOV DS, CX

	XOR AX, AX
	CALL CHECK_STATUS 					; Si nuestro programa no esta instalado, no hacemos nada
	CMP AX, 0
	JZ FIN_DESINSTALAR

			 									; Segmento de vectores interrupción
	MOV ES, DS:[NUM_RUTINA*4+2] 				; Lee segmento de RSI
	MOV BX, ES:[NUM_RUTINA] 					; Lee segmento de entorno del PSP de RSI
	MOV AH, 49h
	INT 21h 									; Libera segmento de RSI (es)
	MOV ES, BX
	INT 21H 									; Libera segmento de variables de entorno de RSI
												; Pone a cero vector de interrupción 40h
	CLI
	MOV DS:[57h*4], CX ; CX = 0
	MOV DS:[57h*4+2], CX
	STI

	FIN_DESINSTALAR:
	POP ES DS CX BX AX
	RET
UNINSTALL ENDP

SHOW_STATUS PROC
	PUSH AX DX

	CALL CHECK_STATUS
	CMP AX, 1					;; Si AX==1, el programa esta instalado, si no, no
	JNZ INF_NO_INSTALADO

	MOV DX, OFFSET PROGRAMA_INSTALADO_STR
	JMP END_INF_ESTADO

	INF_NO_INSTALADO:
	MOV DX, OFFSET PROGRAMA_NO_INSTALADO_STR

	END_INF_ESTADO:		;; Imprimos la cadena
	MOV AH, 9		
	INT 21h

	;; Informamos de los autores
	MOV DX, OFFSET INFORMACION_PROGRAMA
	INT 21h

	POP DX AX
	RET
SHOW_STATUS ENDP

;; Devuelve un 1 en AX si esta instalado, un 0 si no
;; Solo comprueba nuestra rutina, no la rutina 1Ch
CHECK_STATUS PROC
	PUSH BX ES DS

	XOR AX, AX
	MOV ES, AX
	;; Comprobamos los vectores de interrupcion guardados guardados 
	MOV AX, ES:[NUM_RUTINA*4 + 2]
	CMP AX, 0
	JZ NO_INSTALADO						;; Si AX (segmento) es 0, no esta instalado
	MOV BX, ES:[NUM_RUTINA*4]
	CMP BX, 0
	JZ NO_INSTALADO						;; Si BX (offset) es 0, no esta instalado 
	
	SUB BX, 2							;; Comprobamos la firma
	MOV DS, AX	
	MOV AX, DS:[BX]						
	CMP AX, FIRMA
	JNZ NO_INSTALADO
	MOV AX, 1	;; El programa esta instalado
	JMP FIN_PROG_INST

	NO_INSTALADO:
	MOV AX, 0	;; El programa no esta instalado

	FIN_PROG_INST:
	POP DS ES BX
	RET
CHECK_STATUS ENDP

codigo ENDS
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION
END INICIO
	
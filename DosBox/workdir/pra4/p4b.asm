;**************************************************************************
; SBM 2019. Programa pract1a.asm
; Grupo 2301
; Javier Delgado del Cerro y Javier López Cano
;**************************************************************************
; DEFINICION DEL SEGMENTO DE DATOS
DATOS SEGMENT
	infoPolibio DB "La matriz de Polibio es:", 13, 10, "$"
	infoCodificado DB "La cadena HOLAJAVIER codificada es:", 13, 10, "$"
	infoDeodificado DB 13, 10, "La cadena 33444122352255342651 decodificada es:", 13, 10, "$"
	matrizPolibio DB "345678", "9ABCDE", "FGHIJK", "LMNOPQ", "RSTUVW", "XYZ012"
	cadena DB "HOLAJAVIER$"
	cadenaCod DB "33444122352255342651$" 	;; HOLA
DATOS ENDS

;**************************************************************************
; DEFINICION DEL SEGMENTO DE PILA
PILA SEGMENT STACK "STACK"
	DB 40H DUP (0) ;ejemplo de inicialización, 64 bytes inicializados a 0
PILA ENDS

;**************************************************************************
; DEFINICION DEL SEGMENTO EXTRA
EXTRA SEGMENT
	RESULT DW 0,0 ;ejemplo de inicialización. 2 PALABRAS (4 BYTES)
EXTRA ENDS

;**************************************************************************
; DEFINICION DEL SEGMENTO DE CODIGO
CODE SEGMENT
ASSUME CS: CODE, DS: DATOS, ES: EXTRA, SS: PILA
; COMIENZO DEL PROCEDIMIENTO PRINCIPAL
INICIO PROC
	; INICIALIZA LOS REGISTROS DE SEGMENTO CON SU VALOR
	MOV AX, DATOS
	MOV DS, AX
	MOV AX, PILA
	MOV SS, AX
	MOV AX, EXTRA
	MOV ES, AX
	MOV SP, 64 ; CARGA EL PUNTERO DE PILA CON EL VALOR MAS ALTO
	; FIN DE LAS INICIALIZACIONES
	; COMIENZO DEL PROGRAMA
	
	;; Imprimimos la matriz
	MOV AH, 9
	MOV DX, OFFSET infoPolibio
	INT 21h
	CALL PRINT_MATRIZ

	;; Codificamos un string
	;; DS ya contiene el segmento de datos
	MOV AH, 9
	MOV DX, OFFSET infoCodificado
	INT 21h
	;; Llamamos a la interrupcion
	MOV AH, 10h
	MOV DX, OFFSET cadena
	INT 57h

	;; Decodificamos un string
	;; DS ya contiene el segmento de datos
	MOV AH, 9
	MOV DX, OFFSET infoDeodificado
	INT 21h
	;; Llamamos a la interrupcion
	MOV AH, 11h
	MOV DX, OFFSET cadenaCod
	INT 57h

	; FIN DEL PROGRAMA
	MOV AX, 4C00h
	INT 21h

INICIO ENDP


;_______________________________________________________________ 
; IMPRIME LA MATRIZ DE POLIBIO
;_______________________________________________________________ 
PRINT_MATRIZ PROC NEAR
	PUSH BP 							;; Salvaguardar BP en la pila para poder modificarle sin modificar su valor
	MOV BP, SP							;; Igualar BP el contenido de SP
	
	PUSH SI AX BX DX
	XOR BX, BX
	
	MOV AH, 2 ;; Para imprimir caracter a caracter
	
	FILA:
	XOR SI, SI
	
	DIGITO:
	MOV DL, matrizPolibio[BX][SI]
	INT 21h ;; Imprimimos el digito
	
	MOV DL, ' '
	INT 21h	;; Imprimimos espacios entre las letras
	
	INC SI
	CMP SI, 6
	JNZ DIGITO
	
	MOV DL, 13	;; Imprimimos en una nueva linea
	INT 21h
	MOV DL, 10
	INT 21h
	
	ADD BX, 6
	CMP BX, 36
	JNZ FILA
	
	
	POP DX BX AX SI
	POP BP
	RET
PRINT_MATRIZ ENDP


; FIN DEL SEGMENTO DE CODIGO
CODE ENDS
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION
END INICIO 
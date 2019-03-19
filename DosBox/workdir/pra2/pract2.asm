;**************************************************************************
; SBM 2019. Programa pract1a.asm
; Grupo 2301
; Javier Delgado del Cerro y Javier López Cano
;**************************************************************************
; DEFINICION DEL SEGMENTO DE DATOS
DATOS SEGMENT
	MATRIZ 		DB 	11, -3, 1, -3, 5, 7, 1, 7, -1
	CLR_PANT 	DB 	1BH,"[2","J$"
	OPC_EJEC	DB	4 dup (?)

	DET 		DB	6 dup(" "), "|             |", 13, 10, "|A| = |             | =     ", 13, 10, 6 dup(" "), "|             |", 13, 10, "$"

	INTRO_OPC_E	DB	"INTRODUCE LA OPCION DEL PROGRAMA A EJECUTAR:", 13, 10, "1 - VALORES POR DEFECTO", 13, 10, "2 - VALORES INTRODUCIDOS POR TECLADO", 13, 10, "$"
	INTRO_NUM_F	DB	"INTRODUCE LOS 9 NUMEROS DE LA MATRIZ SEPARADOS POR ESPACIOS. POR EJEMPLO: 1 0 0 0 1 0 0 0 1", 13, 10, "$"
	NUM_ERROR_F DB	"ALGUNO DE LOS NUMEROS INTRODUCIDOS NO ES VALIDO. PRUEBA CON OTRA ENTRADA", 13, 10, "$"
	SIGNO 		DB	?
	
	TEMP		DB	40 dup (?)
	NUM_DIG		DW	?

	AUX			DB	?
	READ_RESULT	DB	0



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

	;;; EJECUTAMOS LA OPCION 1 O 2
	READ_OPTION:
	MOV AH, 9h	; BORRA LA PANTALLA
	MOV DX, OFFSET CLR_PANT
	INT 21H
	MOV DX, OFFSET INTRO_OPC_E
	INT 21H

	MOV AH, 0Ah
	MOV DX, OFFSET OPC_EJEC
	MOV OPC_EJEC[0], 2
	INT 21H

	; Decidimos la opcion a ejecutar o volvemos a preguntar
	CMP OPC_EJEC[2], "1"
	JZ  CALCULATE
	CMP OPC_EJEC[2], "2"
	JZ  READ_FROM_KEYBOARD
	JMP READ_OPTION


	;;; LEEMOS POR TECLADO LOS CARACTERES
	READ_FROM_KEYBOARD:
	CALL READ
	CMP [READ_RESULT], -1
	JNZ CORRECT_ARGS
	; SI LA ENTRADA NO ES CORRECTA, FINALIZAMOS
	MOV AH, 9h
	MOV DX, OFFSET NUM_ERROR_F
	INT 21H
	JMP FIN

	CORRECT_ARGS:
	MOV AH, 9h	; BORRA LA PANTALLA
	MOV DX, OFFSET CLR_PANT
	INT 21H

	;;; IMPRIMIMOS LA LINEA SUPERIOR
	CALCULATE:
	; Primer numero
	MOV AH, MATRIZ[0]
	CALL NUM_8_DIGITS
	MOV BX, OFFSET DET + 7
	CALL DIGITS_ASCII 

	; Segundo numero
	MOV AH, MATRIZ[1]
	CALL NUM_8_DIGITS
	MOV BX, OFFSET DET + 12
	CALL DIGITS_ASCII
	
	; Tercer numero
	MOV AH, MATRIZ[2]
	CALL NUM_8_DIGITS
	MOV BX, OFFSET DET + 17
	CALL DIGITS_ASCII

	;;;	SEGUNDA FILA
	; Primer numero
	MOV AH, MATRIZ[3]
	CALL NUM_8_DIGITS
	MOV BX, OFFSET DET + 30
	CALL DIGITS_ASCII

	; Segundo numero
	MOV AH, MATRIZ[4]
	CALL NUM_8_DIGITS
	MOV BX, OFFSET DET + 35
	CALL DIGITS_ASCII
	
	; Tercer numero
	MOV AH, MATRIZ[5]
	CALL NUM_8_DIGITS
	MOV BX, OFFSET DET + 40
	CALL DIGITS_ASCII
	
	; Resultado del determinante
	CALL DETERMINANTE
	MOV AX, BX
	CALL NUM_DIGITS
	MOV BX, OFFSET DET + 47
	CALL DIGITS_ASCII

	;;; IMPRIMIMOS LA LINEA INFERIOR
	; Primer numero
	MOV AH, MATRIZ[6]
	CALL NUM_8_DIGITS
	MOV BX, OFFSET DET + 60
	CALL DIGITS_ASCII

	; Segundo numero
	MOV AH, MATRIZ[7]
	CALL NUM_8_DIGITS
	MOV BX, OFFSET DET + 65
	CALL DIGITS_ASCII

	; Tercer numero
	MOV AH, MATRIZ[8]
	CALL NUM_8_DIGITS
	MOV BX, OFFSET DET + 70
	CALL DIGITS_ASCII
	
	MOV AH, 9h
	MOV DX, OFFSET DET
	INT 21H
	
	FIN:
	; FIN DEL PROGRAMA
	MOV AX, 4C00h
	INT 21h

INICIO ENDP


;_______________________________________________________________ 
; SUBRUTINA PARA LEER LOS 9 NUMEROS DE LA MATRIZ POR TECLADO 
; SALIDA: MATRIZ Y READ_RESULT PARA RECONOCER POSIBLES ERRORES
; EN LA ENTRADA INTRODUCIDA
;_______________________________________________________________ 
READ PROC NEAR
	MOV DI, 0
	MOV AH, 9h
	MOV DX, OFFSET INTRO_NUM_F
	INT 21H

	; Leemos la linea entera introducida por teclado
	MOV AH, 0Ah
	MOV DX, OFFSET TEMP
	MOV TEMP[0], 40
	INT 21H

	MOV BX, 0

	; De la linea, extraemos los 9 numeros
	LEER:
	CALL ASCII_NUM

	; Aseguramos que los numeros estan en el rango adecuado
	CMP CL, 15
	JG NUM_ERROR
	CMP CL, -16
	JL NUM_ERROR	

	; Guardamos el numero en su posicion dentro de matriz
	MOV MATRIZ[DI], CL
	INC DI
	CMP DI, 9
	JNZ LEER
	RET

	NUM_ERROR:
	MOV [READ_RESULT], -1
	JMP LEER

READ ENDP

;_______________________________________________________________ 
; SUBRUTINA PARA OBTENER UN NUMERO ENTERO DE 1B PARTIR DE SU 
; REPRESENTACION EN CODIGO ASCII
; ENTRADA TEMP, BX PARA SABER EL DESPLAZAMIENTO DENTRO DE TEMP
; EN EL QUE LEER
; SALIDA CL
;_______________________________________________________________ 
ASCII_NUM PROC NEAR
	MOV SI, 2
	MOV CL, 0
	MOV DL, 10
	MOV [SIGNO], " "
	MOV AL, TEMP[SI][BX]
	CMP AL, "-"
	JNZ CARGAR_NUM

	; Almacenamos el signo del numero
	ST_SIGNO:
	MOV [SIGNO], AL
	INC SI

	; Cargamos el numero entre la posicion que indica BX y SI
	; y el siguiente espacio o fin de linea
	CARGAR_NUM:
	MOV AL, TEMP[SI][BX]
	SUB AL, 30h
	ADD CL, AL
	INC SI
	CMP TEMP[SI][BX], " "
	JZ APLICAR_SIGNO
	CMP TEMP[SI][BX], 13
	JZ APLICAR_SIGNO
	MOV AL, CL
	MUL DL
	MOV CL, AL
	JMP CARGAR_NUM


	APLICAR_SIGNO:
	;; Actualizamos BX antes de acabar
	ADD BX, SI
	SUB BX, 1
	CMP [SIGNO], "-"
	JZ CAMB_SIG
	RET

	CAMB_SIG:
	NEG CL
	RET

ASCII_NUM ENDP

;_______________________________________________________________ 
; SUBRUTINA PARA CALCULAR EL DETERMINANTE DE UNA MATRIZ 
; 3x3 CON NUMEROS DE 5BITS CON SIGNO
; SALIDA BX
;_______________________________________________________________ 

DETERMINANTE PROC NEAR 
    ;;; USAMOS LA REGLA DE CRAMER ALMACENANDO LAS SUMAS
    ;;; Y RESTAS EN BX
    ;;; MULTIPLICAMOS LOS DOS PRIMEROS NUMEROS COMO ENTEROS
    ;;; DE 8 BITS, Y EL RESULTADO, POR EL TERCERO, COMO ENTEROS
    ;;; DE 16 BITS. EL RESULTADO NUNCA VA A TENER MAS DE 15 BITS
    ;;; CON LO QUE PODEMOS IGNORAR LO ALMACENADO EN DX

    ; A11*A22*A33
	MOV AL, MATRIZ
	IMUL MATRIZ[4]
	MOV DH, MATRIZ[8]
	CALL EXTEND_NUM
	IMUL DX
	MOV BX, AX
	
	; A12*A23*A31
	MOV AL, MATRIZ[1]
	IMUL MATRIZ[5]
	MOV DH, MATRIZ[6]
	CALL EXTEND_NUM
	IMUL DX
	ADD BX, AX
	
	; A13*A21*A32
	MOV AL, MATRIZ[2]
	IMUL MATRIZ[3]
	MOV DH, MATRIZ[7]
	CALL EXTEND_NUM
	IMUL DX
	ADD BX, AX
	
	;;; Restamos las otras tres lineas
	; A13*A22*A31
	MOV AL, MATRIZ[2]
	IMUL MATRIZ[4]
	MOV DH, MATRIZ[6]
	CALL EXTEND_NUM
	IMUL DX
	SUB BX, AX
	
	; A11*A23*A32
	MOV AL, MATRIZ
	IMUL MATRIZ[5]
	MOV DH, MATRIZ[7]
	CALL EXTEND_NUM
	IMUL DX
	SUB BX, AX
	; A12*A21*A33
	MOV AL, MATRIZ[1]
	IMUL MATRIZ[3]
	MOV DH, MATRIZ[8]
	CALL EXTEND_NUM
	IMUL DX
	SUB BX, AX
    RET 
DETERMINANTE ENDP 

;_______________________________________________________________ 
; SUBRUTINA PARA EXTENDER UN NUMERO DE 1B A 2B
; ENTRADA DH
; SALIDA DX
;_______________________________________________________________
EXTEND_NUM:
	MOV AUX, CL
	MOV CL, 8
	SAR DX, CL
	MOV CL, AUX
	RET
	

;_______________________________________________________________ 
; SUBRUTINA PARA OBTENER LOS DIGITOS Y EL SIGNO DE UN 
; NUMERO DE 2B 
; ENTRADA AX
; SALIDA TEMP, SIGNO Y NUM_DIG
;_______________________________________________________________ 
NUM_DIGITS PROC NEAR
	MOV DI, 0
	MOV BX, 10
	ADD AX, 0
	; Almacenamos el signo y convertimos el numero en positivo
	JS	NEGATIVO
	MOV SIGNO, " "
	
	; Dividimos sucesivamente entre 10 hasta que el cociente
	; sea 0, almacenando el resto en TEMP
	COMUN:
	MOV DX, 0
	DIV BX
	MOV TEMP[DI], DL
	
	CMP AX, 0
	JZ FIN_NUM
	MOV DX, 0
	INC DI
	JMP COMUN
	
	; Guardamos el numero de digitos
	FIN_NUM:
	MOV NUM_DIG, DI
	RET
	
	NEGATIVO:
	MOV SIGNO, "-"
	NEG AX
	JMP COMUN
NUM_DIGITS ENDP

;_______________________________________________________________ 
; SUBRUTINA PARA OBTENER LOS DIGITOS Y EL SIGNO DE UN 
; NUMERO DE 1 Byte 
; ENTRADA AH
; SALIDA TEMP, SIGNO Y NUM_DIG
;_______________________________________________________________ 
NUM_8_DIGITS PROC NEAR
	MOV CL, 8
	SAR AX, CL
	CALL NUM_DIGITS
	RET
NUM_8_DIGITS ENDP

;_______________________________________________________________ 
; SUBRUTINA PARA OBTENER EL CODIGO ASCII A PARTIR DE SU
; SIGNO Y DIGITOS 
; ENTRADA SIGNO, TEMP, NUM_DIG, BX COMO OFFSET PARA INDICAR
;	DONDE GUARDAR LA CADENA DE TEXTO
; SALIDA DET
;_______________________________________________________________ 
DIGITS_ASCII PROC NEAR
	MOV SI, [NUM_DIG]
	MOV DI, 1
	MOV DL, SIGNO
	MOV [BX], DL

	; Recorremos todos los digitos sumandoles 30h
	; para pasarlos a codigo ASCII
	BUCLE:
	MOV AL, TEMP[SI]
	ADD AL, 30h
	MOV [BX][DI], AL
	
	INC DI
	DEC SI
	JNS BUCLE
	RET
	
DIGITS_ASCII ENDP


; FIN DEL SEGMENTO DE CODIGO
CODE ENDS
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION
END INICIO 
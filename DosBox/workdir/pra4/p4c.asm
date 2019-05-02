;**************************************************************************
; SBM 2019. Programa p4c.asm
; Grupo 2301
; Javier Delgado del Cerro y Javier López Cano
;**************************************************************************
; DEFINICION DEL SEGMENTO DE DATOS
DATOS SEGMENT 
	TEMP DB 40 DUP(?) ;variable para guardar la string leida por teclado
	CURRENT DW 10h ;variable para guardar la instrucciona ejecutar (10h codificar, 11h decodificar)
	COD DB "cod$" ;string cod (para comparar)
	DECOD DB "decod$" ;string decod (para comparar)
	QUIT DB "quit$" ;string quit (para comparar)
	CLR_PANT 	DB 	1BH,"[2","J$"
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
ASSUME CS: CODE, DS:DATOS, ES:EXTRA, SS:PILA
			

;_______________________________________________________________ 
; PROCEDIMIENTO PRINCIPAL
;_______________________________________________________________ 
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
	MOV BX, OFFSET QUIT

	BUCLE_READ:	
	;MOV AH, 9h
	;MOV DX, OFFSET CLR_PANT
	;INT 21H
	CALL READ	;llamamos a la funcion que lee de teclado y lo guarda en TEMP.
	MOV AH, 2h
	MOV DL, 13
	INT 21H
	MOV DL, 10
	INT 21H ;imprimimos un salto de linea.

	PUSH BX
	CALL CHECK_STR ;pasamos por pila la string quit y llamamos a la funcion que compara la string de teclado con ella.
	CMP AX, 1 
	JE ENDING ;si la string es quit acabamos el programa	

	CMP WORD PTR CURRENT, 10h ;comprobamos si estamos codificando o decodificando
	JNZ CALL_2

	CALL_1:
	MOV CX, OFFSET DECOD
	JMP FUNCT_CALL ;si estamos codificando metemos en cx la string decod

	CALL_2:
	MOV CX, OFFSET COD ;si no, metemos cod

	FUNCT_CALL:
	PUSH CX
	CALL CHECK_STR ;pasamos la string por la pila y llamamos a la fncion que compara.

	CMP AX, 1 ;si son iguales debemos cambiar la función que se esta ejecutando
	JE CHANGE

	MOV DX, OFFSET TEMP ;si no son iguales pasamos la string leida a DX para despues llamar a la interrupción.
	INC DX 
	INC DX ;incrementamos DX 2 veces pues al ser leída de teclado los caracteres leidos comienzan en la posición 2 (tercer byte).
	MOV AH, BYTE PTR CURRENT ;Ponemos en ah la instruccion que se va a ejecutar (10h u 11h).
	INT 57h ;llamamos a la interrupción 57h.
	JMP BUCLE_READ ;iniciamos de nuevo el proceso para codificar o decodificar una nueva string.

	CHANGE:
	CMP CURRENT, 10h 
	JNE OPT_2
	MOV CURRENT, 11h ;Si estamos en 10h cambiamos a 11h
	JMP BUCLE_READ ;volvemos a iniciar el proceso
	OPT_2:
	MOV CURRENT, 10h ;Si estamos en 11h cambiamos a 10h
	JMP BUCLE_READ ;volvemos a iniciar el proceso
	
	ENDING:	
	MOV AX, 4C00h
	INT 21h
INICIO ENDP


;_______________________________________________________________ 
; LEE UNA STRING POR TECLADO Y LA GUARDA EN TEMP
;_______________________________________________________________ 
READ PROC NEAR
	PUSH DX 	
	; Leemos la linea entera introducida por teclado
	MOV AH, 0Ah
	MOV DX, OFFSET TEMP
	MOV TEMP[0], 40
	INT 21H
	
	POP DX
	RET	
READ ENDP

;_______________________________________________________________ 
; COMPARA LA STRING ALMACENADA EN TEMP CON LA STRING QUE ESTA EN
; LA DIRECCIÓN DE MEMORIA PASADA POR LA PILA
; Retorno en AX: 0 si son diferentes, 1 sis on iguales
;_______________________________________________________________ 
CHECK_STR PROC NEAR
	PUSH BP
	MOV BP, SP
	PUSH BX CX SI 
	
	MOV BX, [BP + 4] ;recibimos por la pila la direccion en momeria de la string con la que queremos comparar.
	
	XOR SI, SI
	XOR AX, AX ;ponemos SI y AX a 0.
	BUCLE:
	MOV CH, TEMP[SI + 2] ;pasamos a CH el cracter de la string de teclado (le sumamos 2 pues empieza en el tercer byte).
	MOV CL, [BX + SI] ;movemos a CL el caracter de la string cuya dirección se ha recibido por pila.
	CMP CH, CL ;comparamos ambos caracteres.
	JNZ FIN_VALOR ;Si son diferentes pasamos a comprobar si es el final de las strings,
	INC SI 
	JMP BUCLE ;Si son iguales incrementamos el contador y volvemos al bucle para comparar el siguiente caracter.
	
	FIN_VALOR:
	CMP CH, 13 ;comprobamos si el caracter de la string de teclado es 13 (retorno de carro).
	JNZ FIN ;si no, acabamos pues la string no habia cabado y por tanto son diferentes.
	CMP CL, '$' ;comparamos el caracter de la string con la que estamos comoparando con '$'.
	JNZ FIN ;;si no es '$', acabamos pues la string no habia cabado y por tanto son diferentes.
	MOV AX, 1 ;si es '$' ponemos AX a 1 (para indicar que son igaules) y retornamos.
	
	FIN:
	POP SI CX BX BP
	RET
CHECK_STR ENDP
CODE ENDS
END INICIO
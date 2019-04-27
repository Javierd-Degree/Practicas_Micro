codigo SEGMENT
	ASSUME cs : codigo
	ORG 256
	
INICIO: jmp instalador

; Variables globales
NUM_RUTINA	EQU 57h
FIRMA 		EQU "JJ"
matrizPolibio DB "345678", "9ABCDE", "FGHIJK", "LMNOPQ", "RSTUVW", "XYZ012"
matrizInversa DB 256 dup(?, ?)
flag DW 0
firma DB FIRMA
; Rutina de servicio a la interrupción
rsi PROC FAR
	PUSH BX CX SI DI
	MOV BX, DX
	
	CMP AH, 10h
	JZ CODIFICACION
	CMP AH, 11h
	JZ DECODIFICACION
	JMP FIN
	
	CODIFICACION:
	XOR SI, SI
	MOV DI,  DS:[BX][SI]	;; Leemos el caracter en DI
	AND DI, 00FFh			;; Solo queremos leer los 8bytes del primer caracter
	CMP DI, "$"
	JZ FIN
	ADD DI, DI
	MOV DX, DS:[BX][DI]		;; Cargamos en DL la fila, en DH la columna
	MOV AH, 2h
	INT 21h
	MOV DL, DH
	INT 21h
	INC SI
	JMP CODIFICACION
	
	DECODIFICACION:
	XOR SI, SI
	MOV AX,  DS:[BX][SI]	;; Leemos las dos coordenadas. En AH la segunda y en AL la primera
	CMP AL, '$'	;La cadena ha acabado
	JMP FIN
	
	;; Restar 31h a ambos, Buscar en la tabla, pasar a AH e imprimir.
	;; El elemento estará en 6*(AL-1) + AH-1
	SUB AL, 31h
	SUB AH, 31h
	XOR CX, CX
	CALC_COORD:			;; 	Calculamos 6*(AL-1)
	CMP AL, 0
	JZ FIN_CALC
	ADD CX, 6
	DEC AL
	JMP CALC_COORD
	
	FIN_CALC:
	;; Tenemos que escribir AH en 16bits, no en 8
	MOV AL, AH
	XOR AH, AH
	
	MOV DI, CX
	ADD DI, AX
	MOV DL, DS:[BX][DI]
	MOV AH, 2h
	INT 21h
	JMP DECODIFICACION
	
	FIN:
	POP DI SI CX BX
	IRET
rsi ENDP	
	
calcularInversa PROC
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
	MOV DI, DX 		;; Guardamos BL, BH en DI*2
	
	;; Almacenamos en matrizInversa[caracter*2] la fila y la columna, en hexadecimal, empezando por 1
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

instalador:
	mov ax, 0 
	mov es, ax 
	mov ax, OFFSET rsi 
	mov bx, cs 
	cli 
	mov es:[ NUM_RUTINA*4 ], ax 
	mov es:[ NUM_RUTINA*4+2 ], bx 
	sti
	
	CALL calcularInversa
	
	mov dx, OFFSET instalador 
	int 27h ; Acaba y deja residente 
			; PSP, variables y rutina rsi. 	
			
desinstalador PROC ; Desinstala RSI de INT 40h
	push ax bx cx ds es
	mov cx, 0
	mov ds, cx 									; Segmento de vectores interrupción
	mov es, ds:[ NUM_RUTINA*4+2 ] 				; Lee segmento de RSI
	mov bx, es:[ NUM_RUTINA ] 					; Lee segmento de entorno del PSP de RSI
	mov ah, 49h
	int 21h 									; Libera segmento de RSI (es)
	mov es, bx
	int 21h 									; Libera segmento de variables de entorno de RSI
												; Pone a cero vector de interrupción 40h
	cli
	mov ds:[ NUM_RUTINA*4 ], cx ; cx = 0
	mov ds:[ NUM_RUTINA*4+2 ], cx
	sti
	pop es ds cx bx ax
	ret
desinstalador ENDP

;; Devuelve un 1 en AX si esta instalado, un 0 si no
programa_instalado PROC
	PUSH BX ES
	XOR AX, AX
	MOV ES, AX
	MOV AX, ES:[NUM_RUTINA*4 + 2]
	JZ NO_INSTALADO						;; Si AX es 0, no esta instalado
	MOV BX, ES:[NUM_RUTINA*4]
	JZ NO_INSTALADO						;; Si BX es 0, no esta instalado 
	
	SUB BX, 2							;; Comprobamos la firma
	MOV AX, ES:BX						
	CMP FIRMA, AX
	JZ NO_INSTALADO
	MOV AX, 1	;; El programa esta instalado
	
	NO_INSTALADO:
	MOV AX, 0	;; El programa no esta instalado

	FIN_PROG_INST:
	POP ES BX
	RET
programa_instalado ENDP

codigo ENDS
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION
END INICIO
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 			SBM 2016. Practica 3 - Ejemplo					;
;   Pareja													;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DGROUP GROUP _DATA, _BSS				;; Se agrupan segmentos de datos en uno

_DATA SEGMENT WORD PUBLIC 'DATA' 		;; Segmento de datos DATA público

_DATA ENDS

_BSS SEGMENT WORD PUBLIC 'BSS'			;; Segmento de datos BSS público

_BSS ENDS

_TEXT SEGMENT BYTE PUBLIC 'CODE' 		;; Definición del segmento de código
ASSUME CS:_TEXT, DS:DGROUP, SS:DGROUP
			

INICIO PROC FAR 					
	PUSH BP 							
	MOV BP, SP
	PUSH
	
	INC BYTE PTR CONTADOR
	CMP BYTE PTR CONTADOR, 18
	JNE FIN
	
	MOV AH 10h
	INT 57h
	
	FIN:
	POP
	RET
	
INICIO ENDP						


READ PROC NEAR
	PUSH BP
	MOV BP, SP
	PUSH BX DX 
	
	; Leemos la linea entera introducida por teclado
	MOV AH, 0Ah
	MOV DX, OFFSET TEMP
	MOV TEMP[0], 40
	INT 21H

	MOV BX, 0
	MOV AX, OFFSET TEMP
	
	POP DX BX BP
	
READ ENDP


CHECK_STR PROC NEAR
	PUSH BP
	MOV BP, SP
	PUSH BX CX DX SI 
	
	MOV BX, [BP + 4]
	MOV DX, [BP + 6]
	
	XOR SI, SI
	XOR AX, AX
	BUCLE:
	MOV CH, [DX + SI]
	CMP CH, '$'
	JE FIN_T
	CMP CH, [BX + SI]
	JNE FIN
	INC SI
	JMP BUCLE
	
	FIN_T:
	MOV CL, [BX + SI]
	CMP CL, '$'
	MOV AX, 1
	
	FIN:
	POP SI DX CX BX BP
	RET
CHECK_STR ENDP
_TEXT ENDS
END
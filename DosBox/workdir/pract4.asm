codigo SEGMENT
	ASSUME cs : codigo
	ORG 256
	
inicio: jmp instalador

; Variables globales
NUM_RUTINA	EQU 57h
matrizPolibio DB "345678", "9ABCDE", "FGHIJK", "LMNOPQ", "RSTUVW", "XYZ012"
flag DW 0

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
	
	JMP FIN
	
	DECODIFICACION:
	XOR SI, SI
	MOV AX,  DS:[BX][SI]	;; Leemos las dos coordenadas. En AH la segunda y en AL la primera
	CMP AL, '$'	;La cadena ha acabado
	JMP FIN
	
	;; Restar 30h a ambos, Buscar en la tabla, pasar a AH e imprimir
	
	FIN:
	POP DI SI CS BX
	IRET
rsi ENDP

instalador:
	mov ax, 0 
	mov es, ax 
	mov ax, OFFSET rsi 
	mov bx, cs 
	cli 
	mov es:[ NUM_RUTINA*4 ], ax 
	mov es:[ NUM_RUTINA*4+2 ], bx 
	sti 
	mov dx, OFFSET instalador 
	int 27h ; Acaba y deja residente 
			; PSP, variables y rutina rsi. 		
	instalador ENDP 
	
	
codigo ENDS 
	
;**************************************************************************
; SBM 2019. Programa pract1a.asm
; Grupo 2301
; Javier Delgado del Cerro y Javier López Cano
;**************************************************************************
; DEFINICION DEL SEGMENTO DE DATOS
DATOS SEGMENT
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

	; Cargamos 15h en AX
	MOV AX, 15h
	; Cargamos BBh en BX
	MOV BX, 0BBh
	; Cargamos 3412h en CX
	MOV CX, 3412h
	; Cargamos el contenido de CX en DX
	MOV DX, CX
	
	;; Cargamos el segmento en DS
	MOV AX, 6553h
	MOV DS, AX
	;; Cargamos el contenido de la posicion de memoria 65536h en BH
	MOV BH, DS:[6h]
	;; Cargamos el contenido de la posicion de memoria 65537h en BL
	MOV BL, DS:[7h]
	
	;; Cargamos el segmento en DS
	MOV AX, 5000h
	MOV DS, AX
	;; Cargamos el contenido de CH en la posicion de memoria 50005h
	MOV DS:[5h], CH
	;; Cargamos en AX el contenido de la dirección de memoria apuntada por SI 
	MOV AX, [SI]
	;; Cargar en BX el contenido de la dirección de memoria que está 10 bytes por encima de la dirección apuntada por BP 

	MOV BX, [BP]+10
	
	; FIN DEL PROGRAMA
	MOV AX, 4C00h
	INT 21h
INICIO ENDP
; FIN DEL SEGMENTO DE CODIGO
CODE ENDS
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION
END INICIO 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 	SBM 2019. Practica 3									;
;   Javier Delgado del Cerro								;
;	Javier López Cano										;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DGROUP GROUP _DATA, _BSS				;; Se agrupan segmentos de datos en uno

_DATA SEGMENT WORD PUBLIC 'DATA' 		;; Segmento de datos DATA público

_DATA ENDS

_BSS SEGMENT WORD PUBLIC 'BSS'			;; Segmento de datos BSS público

_BSS ENDS

_TEXT SEGMENT BYTE PUBLIC 'CODE' 		;; Definición del segmento de código
ASSUME CS:_TEXT, DS:DGROUP, SS:DGROUP
			

PUBLIC _computeControlDigit				;; Hacer visible y accesible la función desde C
_computeControlDigit PROC FAR 			;; En C es int unsigned long int factorial(unsigned int n)
	PUSH BP 							;; Salvaguardar BP en la pila para poder modificarle sin modificar su valor
	MOV BP, SP							;; Igualar BP el contenido de SP
	
	PUSH BX	CX							;; Guardamos el contenido de los registros
	
	LES BX, [BP + 6]					;; Leemos la direccion del codigo de barras
	MOV CL, ES:[BX]						;; Sumamos todos los impares
	ADD CL, ES:[BX + 2]
	ADD CL, ES:[BX + 4]
	SUB CL, 30H*3						;; Pasamos de ASCII a binario. Como cada uno esta entre 30h y 39h, no se pueden desbordar
	ADD CL, ES:[BX + 6]
	ADD CL, ES:[BX + 8]
	ADD CL, ES:[BX + 10]
	SUB CL, 30H*3						;; Pasamos de ASCII a binario. Como cada uno esta entre 30h y 39h, no se pueden desbordar
								
	MOV AL, ES:[BX + 1]					;; Multiplicamos los numeros pares por tres y los sumamos. La suma siempre va a ser menor de 255
	SUB AL, 30H
	ADD CL, AL
	ADD CL, AL
	ADD CL, AL
	
	MOV AL, ES:[BX + 3]
	SUB AL, 30H
	ADD CL, AL
	ADD CL, AL
	ADD CL, AL
	
	MOV AL, ES:[BX + 5]
	SUB AL, 30H
	ADD CL, AL
	ADD CL, AL
	ADD CL, AL
	
	MOV AL, ES:[BX + 7]
	SUB AL, 30H
	ADD CL, AL
	ADD CL, AL
	ADD CL, AL
	
	MOV AL, ES:[BX + 9]
	SUB AL, 30H
	ADD CL, AL
	ADD CL, AL
	ADD CL, AL
	
	MOV AL, ES:[BX + 11]
	SUB AL, 30H
	ADD CL, AL
	ADD CL, AL
	ADD CL, AL
	
	XOR AH, AH							;; Calculamos el digito de control
	MOV AL, CL
	MOV CL, 10
	DIV CL
	CMP AH, 0
	JZ FIN
	
	SUB CL, AL
	MOV AH, CL
		
	FIN:
		MOV AL, AH
		XOR AH, AH
		POP CX BX BP					;; Restaurar el valor de BP antes de salir
		RET								;; Retorno de la función que nos ha llamado, devolviendo el resultado del computeControlDigit en AX
_computeControlDigit ENDP				;; Termina la funcion computeControlDigit

_TEXT ENDS
END
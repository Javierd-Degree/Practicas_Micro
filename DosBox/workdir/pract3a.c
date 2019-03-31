/*********************************************************************
 * pract3.c
 *
 * Sistemas Basados en Microprocesador
 * 2018-2019
 * Practica 3
 * Codigos de Barras
 *
 *********************************************************************/
 
#include <stdio.h>
#include <stdlib.h>


/***** Declaracion de funciones *****/

/* Ejercicio 1 */

unsigned char computeControlDigit(char* barCodeASCII);


//////////////////////////////////////////////////////////////////////////
///// -------------------------- MAIN ------------------------------ /////
//////////////////////////////////////////////////////////////////////////
int main( void ){
	char barCodeStr[] = "7701234002008";
	unsigned char controlDigitCheck;


	controlDigitCheck = computeControlDigit(barCodeStr);
	printf("%d", controlDigitCheck);
	
	
	return 0;
}
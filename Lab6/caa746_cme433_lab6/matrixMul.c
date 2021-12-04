/**
* Matrix Multiplication: C = A * B
* CPU implementation code
*/

//system include
#include<stdio.h>
#include<stdlib.h>

//use program timer
#include<sys/time.h>
#include<time.h>

//define constant: matrix size
#define ROW1 512
#define COL1 512
#define ROW2 512
#define COL2 512
// #define DEBUG

//row-major order
float matrixA[ROW1 * COL1];
float matrixB[ROW2 * COL2];
float matrixC[ROW1 * COL2];

void matrixMultiple(float matrixa[], float matrixb[], float matrixc[]) {
		for (int r = 0; r<ROW1; r++){
			for (int c = 0; c<COL2; c++){
				int sum = 0;
				for (int i = 0; i < COL1; i++){
					sum = sum + matrixa[r*COL1+i] * matrixb[i*COL2+c];
				}
				matrixc[r*COL2+c] = sum;
			}
		}
}

int main(void) {


	int i;

	//define variables to use timer
	clock_t start, finish;
	float duration;

	//initialize matrix A and matrix B
	//put in random values
#ifndef DEBUG
	time_t t;
	srand((unsigned) time(&t));
#endif
	for(i = 0; i < ROW1 * COL1; i++)
	{
#ifdef DEBUG
		matrixA[i] = rand() % 2000;
#else
		matrixA[i] = rand();
#endif
	}
	for(i = 0; i < ROW2 * COL2; i++)
	{
#ifdef DEBUG
		matrixB[i] = rand() % 2000;
#else
		matrixB[i] = rand();
#endif
	}

	//record start time
	start = clock();

	matrixMultiple(matrixA, matrixB, matrixC);

	//record finish time
	finish = clock();


	//calculate time needed to do matrix multiplication
	duration = (double)(finish - start);

#ifdef DEBUG
	// output matrix
	printf("matrixA =");
	for(i = 0; i < ROW1 * COL1; i++)
	{
		if(i % COL1 == 0)
		{
			printf("\n");
		}
		printf("%.0f\t", matrixA[i]);
	}
	printf("\n\n");
	printf("matrixB =\n");
	for(i = 0; i < ROW2 * COL2; i++)
	{
		if(i % COL2 == 0)
		{
			printf("\n");
		}
		printf("%.0f\t", matrixB[i]);
	}
	printf("\n\n");
	printf("matrixC=\n");
	for(i = 0; i < ROW1 * COL2; i++)
	{
		if(i % COL2 == 0)
		{
			printf("\n");
		}
		printf("%.0f\t", matrixC[i]);
	}
	printf("\n\n");
#endif

	//output the matrix dimension and
	//elapsed time when doing multiplication
	printf("Dimension of matrixA: %d x %d\n", ROW1, COL1);
	printf("Dimension of matrixB: %d x %d\n", ROW2, COL2);
	printf("Multiplication of matrixA and matrixB need %f ms\n", duration);

	return 0;
}

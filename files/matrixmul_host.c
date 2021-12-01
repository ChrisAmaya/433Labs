/*************************************/
/* Matrix Multiplication OpenCL code */
/* matrixC = matrixA x matrixB       */
/* Nov 26, 2016                      */
/* Chandler Janzen
/*************************************/

// I recommend you make reference to vectorAdd.c (provided).

//I'm old. I have old code. This gets rid of warnings about me being old.
#define CL_USE_DEPRECATED_OPENCL_1_2_APIS

//system include
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#ifdef __APPLE__
#include <OpenCL/opencl.h>
#else
#include <CL/cl.h>
#endif

//define constant
//  WA: width of matrix A
//  HA: height of matrix A
#define WA 512
#define HA 512
#define WB WA
#define HB HA
#define WC WA
#define HC HA

#define MAX_SOURCE_SIZE (0x100000)

//This DEBUG symbol can be useful for troubleshooting
//#define DEBUG 1

//If you are clever, you'd pass matrix size as a parameter...
int main(int argc, char** argv)
{
    //error code returned from api calls
    int err;

    //compute device id
    cl_device_id device_id;
    //compute context
    cl_context context;
    //compute command queue
    cl_command_queue commands;
    //compute program
    cl_program program;
    //compute kernel
    cl_kernel kernel;
    //compute event
    cl_event event;

    //device memory for matrices
    cl_mem d_A;
    cl_mem d_B;
    cl_mem d_C;

    //host memory for vectors
    float *h_A;
	float *h_B;
	float *h_C;

    //allocate host memory for vectorA, vectorB, and vectorC





    //put random value into Matrix A and Matrix B
#ifndef DEBUG
    int seed;
    seed = 256; //Should Randomize this at some point...
    srand(seed);
#endif
    int i;
    for (i = 0; i < WA * HA; i++)
    {
#ifdef DEBUG
        h_A[i] = rand() % 2000;
#else
        h_A[i] = rand();
#endif
    }
    for (i = 0; i < WA * HA; i++)
    {
#ifdef DEBUG
        h_B[i] = rand() % 2000;
#else
        h_B[i] = rand();
#endif
    }

    //initialize OpenCL device
    printf("Initializing OpenCL device...\n");

    //get platform ID





    //choose a compute device




    //print Device Information




    //create a compute context




    //create a command commands




    //create the compute program from the source file
    //read the source file




    //create program




    //build the program executable




    //create compute kernel





    //create the input and output arrays in device memory





    printf("Running matrix multiplication for matrices A (%dx%d) and B (%dx%d) ...\n", WA,HA,WB,HB);

    //launch OpenCL kernel




    //define global and local work size




    //executing the kernel 
    //Hint: remember to set the dimension correctly...



    //calculate the execution time




    //retrieve result from device






    printf("Matrix multiplication completed...\n");

    //original time in nanosecond
    printf("\nExecution time in milliseconds = %0.3f ms\n", (total_time / 1000000.0));

#ifdef DEBUG
    //output matrix
    printf("matrixA = ");
    for (i = 0; i < WA * HA; i++)
    {
        if (i % WA == 0)
        {
            printf("\n");
        }
        printf("%.0f\t", h_A[i]);
    }
   printf("\n\n");

   printf("matrixB = ");
    for (i = 0; i < WB * HB; i++)
    {
        if (i % WB == 0)
        {
            printf("\n");
        }
        printf("%.0f\t", h_B[i]);
    }
   printf("\n\n");

   printf("matrixC = ");
    for (i = 0; i < WC * HC; i++)
    {
        if (i % WC == 0)
        {
            printf("\n");
        }
        printf("%.0f\t", h_C[i]);
    }
   printf("\n\n");
#endif

    //cleanup host and device

    




    return 0;
}

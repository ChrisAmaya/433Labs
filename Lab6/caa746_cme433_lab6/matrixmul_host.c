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
#include <time.h>
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
#define WB 512
#define HB 512
#define WC 512
#define HC 512

#define MAX_SOURCE_SIZE (0x100000)

//This DEBUG symbol can be useful for troubleshooting
// #define DEBUG 1

//If you are clever, you'd pass matrix size as a parameter...but why?
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
    h_A = (float*)malloc(sizeof(float) * WA * HA);
    h_B = (float*)malloc(sizeof(float) * WB * HB);
    h_C = (float*)malloc(sizeof(float) * WC * HC);

    //put random value into Matrix A and Matrix B
#ifndef DEBUG
    time_t t;
    srand((unsigned) time(&t));
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
    cl_uint dev_cnt = 0;
    clGetPlatformIDs(0,0,&dev_cnt);
    cl_platform_id platform_ids[dev_cnt];
    clGetPlatformIDs(dev_cnt, platform_ids, NULL);

    //choose a compute device
    int gpu = 1;
    err = clGetDeviceIDs(platform_ids[0], gpu ? CL_DEVICE_TYPE_GPU : CL_DEVICE_TYPE_CPU, 1, &device_id, NULL);
    if (err != CL_SUCCESS){
      printf("Error: Failed to create a device group!\n");
      return EXIT_FAILURE;
    }

    //print Device Information
    char* value;
  	size_t valueSize;
  	clGetDeviceInfo(device_id, CL_DEVICE_NAME, 0, NULL, &valueSize);
  	value = (char*)malloc(valueSize);
  	clGetDeviceInfo(device_id, CL_DEVICE_NAME, valueSize, value, NULL);
  	printf("Device: %s\n", value);
  	free(value);

    //create a compute context
    context = clCreateContext(0, 1, &device_id, NULL, NULL, &err);
    if (!context){
      printf("Error: Failed to create a compute context!\n");
      return EXIT_FAILURE;
    }

    //create a command queue
    commands = clCreateCommandQueue(context, device_id, CL_QUEUE_PROFILING_ENABLE, &err);
  	if (!commands){
  		printf("Error: Failed to create a command queue!\n");
  		return EXIT_FAILURE;
  	}

    //create the compute program from the source file
    //read the source file
    FILE *fp;
  	const char fileName[] = "./matrixmul_kernel.cl";
  	size_t kernel_size;
  	char *KernelSource;

  	fp = fopen(fileName, "r");
  	if (!fp){
  		fprintf(stderr, "Failed to load kernel.\n");
  		exit(1);
  	}
  	KernelSource = (char*)malloc(MAX_SOURCE_SIZE);
  	kernel_size = fread(KernelSource, 1, MAX_SOURCE_SIZE, fp);
  	fclose(fp);

    //create program
    program = clCreateProgramWithSource(context, 1, (const char **)&KernelSource, (const size_t *)&kernel_size, &err);
  	if (!program){
  		printf("Error: Failed to create compute program!\n");
  		return EXIT_FAILURE;
  	}

    //build the program executable
    //Just in Time compiling using runtime API on source read as text. 'online' mode.
    err = clBuildProgram(program, 1, &device_id, NULL, NULL, NULL);
    if (err != CL_SUCCESS){
      size_t len;
      char buffer[2048];
      printf("Error: Failed to build program executable!\n");
      clGetProgramBuildInfo(program, device_id, CL_PROGRAM_BUILD_LOG, sizeof(buffer), buffer, &len);
      printf("%s\n", buffer);
      exit(1);
    }

    //create compute kernel
    kernel = clCreateKernel(program, "matrixMul", &err);
  	if (!kernel || err != CL_SUCCESS){
  		printf("Error: Failed to create compute lernel!\n");
  		exit(1);
  	}

    //create the input and output arrays in device memory
    d_C = clCreateBuffer(context, CL_MEM_READ_WRITE, sizeof(float)*(WC*HC), NULL, &err);
  	d_A = clCreateBuffer(context, CL_MEM_READ_WRITE | CL_MEM_COPY_HOST_PTR, sizeof(float)*(WA*HA), h_A, &err);
  	d_B = clCreateBuffer(context, CL_MEM_READ_WRITE | CL_MEM_COPY_HOST_PTR, sizeof(float)*(WB*HB), h_B, &err);
  	if (!d_A || !d_B || !d_C){
  		printf("Error: Failed to allocate device memory!\n");
  		exit(1);
  	}

    printf("Running matrix multiplication for matrices A (%dx%d) and B (%dx%d) ...\n", WA,HA,WB,HB);

    //launch OpenCL kernel
    int wA = WA;
    int wB = WB;
  	err = clSetKernelArg(kernel, 0, sizeof(cl_mem), (void*)&d_C);
  	err |= clSetKernelArg(kernel, 1, sizeof(cl_mem), (void*)&d_A);
  	err |= clSetKernelArg(kernel, 2, sizeof(cl_mem), (void*)&d_B);
  	err |= clSetKernelArg(kernel, 3, sizeof(int), (void*)&wA);
    err |= clSetKernelArg(kernel, 4, sizeof(int), (void*)&wB);
  	if (err != CL_SUCCESS){
  		printf("Error: Failed to set kernel arguments! %d\n", err);
  		exit(1);
  	}

    //define global and local work size
    size_t localWorkSize, globalWorkSize;
  	localWorkSize = 1;
  	globalWorkSize = WA*HA;

    //executing the kernel
    //Hint: remember to set the dimension correctly...
	  err = clEnqueueNDRangeKernel(commands, kernel, 1, NULL, &globalWorkSize, NULL, 0, NULL, &event);

    //calculate the execution time
    clFinish(commands);
  	clWaitForEvents(1, &event);
  	cl_ulong time_start, time_end;
  	double total_time;

    //OpenCL will keep track of this information for us.
  	clGetEventProfilingInfo(event, CL_PROFILING_COMMAND_START, sizeof(time_start), &time_start, NULL);
  	clGetEventProfilingInfo(event, CL_PROFILING_COMMAND_END, sizeof(time_end), &time_end, NULL);

  	total_time = time_end - time_start;

  	if (err != CL_SUCCESS){
  		printf("Error: Failed to execute kernel! %d\n", err);
  		exit(1);
  	}


    //retrieve result from device
    err = clEnqueueReadBuffer(commands, d_C, CL_TRUE, 0, sizeof(float)*(WA*WB), h_C, 0, NULL, NULL);
    if (err != CL_SUCCESS){
      printf("Error: Failed to read output array! %d\n", err);
      exit(1);
    }

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
    free(h_A);
  	free(h_B);
  	free(h_C);

  	clReleaseMemObject(d_A);
  	clReleaseMemObject(d_B);
  	clReleaseMemObject(d_C);

  	clReleaseProgram(program);
  	clReleaseKernel(kernel);
  	clReleaseCommandQueue(commands);
  	clReleaseContext(context);






    return 0;
}

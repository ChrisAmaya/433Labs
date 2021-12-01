<<<<<<< HEAD

/* 
	vector addition kernel
*/

//OpenCL Kernel
__kernel void vectorAdd(__global float* C, __global float* A, __global float* B, int size)
{
	int tx = get_global_id(0);
	
	//each element is computed by one thread
	if (tx < size)
	{	
		C[tx] = A[tx] + B[tx];
	}
=======

/* 
	vector addition kernel
*/

//OpenCL Kernel
__kernel void vectorAdd(__global float* C, __global float* A, __global float* B, int size)
{
	int tx = get_global_id(0);
	
	//each element is computed by one thread
	if (tx < size)
	{	
		C[tx] = A[tx] + B[tx];
	}
>>>>>>> 6e938183a090e4a08a5bf0adf469e140d95a8de6
}
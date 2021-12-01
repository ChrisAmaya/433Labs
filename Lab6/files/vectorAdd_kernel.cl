
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
}
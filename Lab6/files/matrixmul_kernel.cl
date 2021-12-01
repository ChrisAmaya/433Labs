
/* kernel.cl
 * Matrix multiplication
 * Device code.
 * Check out vectorAdd.cl as an example...
 */

// OpenCL Kernel

__kernel void matrixMul(__global float* C, __global float* A, __global float* B, int wA, int wB) {
  const int globalRow = get_global_id(0);
  const int globalCol = get_global_id(1);

  float sum = 0.0f;
  for (int i = 0; i < wA; i++){
    float elementA = A[globalCol * wA + i];
    float elementB = B[i + wB + globalRow];
    sum += elementA * elementB;

  }
  C[globalCol * wA + globalRow] = sum;

}

/*
    Copyright (C) 2011  Abhinav Jauhri (abhinav.jauhri@gmail.com), Carnegie Mellon University - Silicon Valley 

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <stdio.h>
#include <cuda.h>
#include <cuda_runtime.h>
#include <math.h>
#include "matrix_mul.h"
#define TILE_WIDTH 32

namespace cuda
{
  __global__ 
  void 
  matrix_mul_kernel(float *sq_matrix_1, float *sq_matrix_2, float *sq_matrix_result, int sq_dimension)
  {

    int bx = blockIdx.x; int by = blockIdx.y;
    int tx = threadIdx.x; int ty = threadIdx.y;

    //compute the row element of Pd and Md 
    int Row = by * TILE_WIDTH + ty;

    //compute the col element of Pd and Md
    int Col = bx * TILE_WIDTH + tx;
    
    float sum = 0.0f;

    if((Row<sq_dimension)&&(Col<sq_dimension))
    {
      for(int k = 0; k < sq_dimension; k++)
        {
	        sum += sq_matrix_1[Row*sq_dimension + k] * sq_matrix_2[k*sq_dimension + Col];
        }
      sq_matrix_result[Row*sq_dimension + Col] = sum;
    }
  }
  
  void 
  matrix_multiplication(float *sq_matrix_1, float *sq_matrix_2, float *sq_matrix_result, unsigned int sq_dimension)
  {
    int size = sq_dimension * sq_dimension * sizeof(float);
    float *sq_matrix_1_d, *sq_matrix_2_d, *sq_matrix_result_d;
    
    /***************************************************
  1st Part: Allocation of memory on device memory  
    ****************************************************/
    
    /* copy sq_matrix_1 and sq_matrix_2 to device memory */
    cudaMalloc((void**) &sq_matrix_1_d, size);
    cudaMemcpy(sq_matrix_1_d, sq_matrix_1, size, cudaMemcpyHostToDevice);
    cudaMalloc((void**) &sq_matrix_2_d, size);
    cudaMemcpy(sq_matrix_2_d, sq_matrix_2, size, cudaMemcpyHostToDevice);
    
    /*allocate sq_matrix_result on host */
    cudaMalloc((void**) &sq_matrix_result_d, size);
    
    /***************************************************
   2nd Part: Inovke kernel 
    ****************************************************/
    dim3 dimBlock(TILE_WIDTH, TILE_WIDTH);
    dim3 dimGrid((int)ceil((double)sq_dimension/TILE_WIDTH),(int)ceil((double)sq_dimension/TILE_WIDTH),1);
    
    matrix_mul_kernel<<<dimGrid, dimBlock>>>(sq_matrix_1_d, sq_matrix_2_d, sq_matrix_result_d, sq_dimension);
    
    /***************************************************
   3rd Part: Transfer result from device to host 
    ****************************************************/
    cudaMemcpy(sq_matrix_result, sq_matrix_result_d, size, cudaMemcpyDeviceToHost);
    cudaFree(sq_matrix_1_d);
    cudaFree(sq_matrix_2_d);
    cudaFree(sq_matrix_result_d);
  }  
} // namespace cuda

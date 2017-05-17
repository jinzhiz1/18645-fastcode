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

#include <omp.h>
#include "matrix_mul.h"
#include "immintrin.h"
namespace omp
{
  void
  matrix_multiplication(float *sq_matrix_1, float *sq_matrix_2, float *sq_matrix_result, unsigned int sq_dimension )
  {
	float r;
	#pragma omp parllel for
	for(unsigned int i=0;i<sq_dimension*sq_dimension;i++)
		sq_matrix_result[i]=0.0;
		
	#pragma omp parallel for private(r)
    	for (unsigned int i = 0; i < sq_dimension; i++) 
       {	
		for (unsigned int k = 0; k < sq_dimension; k++){
 			r=sq_matrix_1[i*sq_dimension+k];
			__m256 ymm0, ymm1,ymm2;
			unsigned int j=0;	       
			for(j=0;j<sq_dimension-8;j+=8){
				ymm0=_mm256_loadu_ps(&sq_matrix_result[i*sq_dimension+j]);
				ymm1=_mm256_loadu_ps(&sq_matrix_2[k*sq_dimension+j]);
				ymm2=ymm1*r;
				ymm0=_mm256_add_ps(ymm0,ymm2);	
				_mm256_storeu_ps(&sq_matrix_result[i*sq_dimension+j], ymm0);
			}	
	    		for (; j < sq_dimension; j++)
	      			sq_matrix_result[i*sq_dimension + j] += r * sq_matrix_2[k*sq_dimension + j];
	  }
      }// End of parallel region
  }
  
} //namespace omp

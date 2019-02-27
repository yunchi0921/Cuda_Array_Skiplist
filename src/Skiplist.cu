/*
 ============================================================================
 Name        : Skiplist.cu
 Author      : Yunchi
 Version     :
 Copyright   : Your copyright notice
 Description : CUDA compute reciprocals
 ============================================================================
 */
#include"Skiplist.h"



/*Parallelize to Initial all elements of array*/
void __global__ Init(Node *sl,Node *n_arr,int N){

	int x =threadIdx.x+blockIdx.x*blockDim.x;
	int level=n_arr[x%N].level;
	if((x/N)<level)
		sl[x].key=n_arr[x%N].key;
}









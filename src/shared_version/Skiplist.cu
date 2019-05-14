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
void __global__ Init(Node *sl, int N) {
	extern __shared__ Node s[];
	int g = blockIdx.x * blockDim.x + threadIdx.x;
	int x = threadIdx.x;
	Node *shared_level_zero = s;
	shared_level_zero[x] = sl[g];
	int level = shared_level_zero[x].level;
	for(int i=0;i<level;i++){
			sl[g+N*i].key = shared_level_zero[x].key;
	}
}
void __global__ Connect(Node*sl, int N) {
	int g=blockIdx.x*blockDim.x+threadIdx.x;
	int x=threadIdx.x;
	extern __shared__ Node s[];
	Node* shared_level_zero=s;
	shared_level_zero[x]=sl[g];
	int level=shared_level_zero[x].level;
	if(x!=blockDim.x-1){
		int step=1;
		for(int i=0;i<level;i++){
			while(shared_level_zero[x+step].level<=i && x+step<blockDim.x) step++;
			sl[g+N*i].nextIdx=g+step;
		}
	}
}


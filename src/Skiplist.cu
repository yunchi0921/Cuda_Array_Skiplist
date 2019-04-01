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

	int x =blockIdx.x*blockDim.x+threadIdx.x;

	int level=n_arr[x%N].level;
	if((x/N)<level)
		sl[x].key=n_arr[x%N].key;
}
void __global__ Connect(Node*sl,int N){
	int x=blockIdx.x*blockDim.x+threadIdx.x;
	 if(sl[x].key!=-1 && x%N!=N-1){
		 int i=0;
		 do{
			 ++i;
		 }while(sl[x+i].key==0&&(x+i)%N!=0);
		 if((x+i)%N!=0)
			 sl[x].nextIdx=x+i;
		 else
			 sl[x].nextIdx=-1;
	 }
	 else
		 sl[x].nextIdx=-1;
}









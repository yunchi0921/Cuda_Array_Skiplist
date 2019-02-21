#include"Skiplist.h"
void __global__ add(Node **sl,Node *n, int *latest){
	int x=threadIdx.x+blockIdx.x*blockDim.x;
	int first_read,second_read;
	int new_latest=*latest+1;
	do{
		first_read=*latest;
		//Call Insert
		Insert(sl,n[x],first_read);
		//Assert latest haven't been changed
		second_read=atomicCAS((unsigned long long int*)latest,
				*(unsigned long long int *)&first_read,
				*(unsigned long long int *)&new_latest);
	}while(first_read!=second_read); //If latest was been changed , rework.
}

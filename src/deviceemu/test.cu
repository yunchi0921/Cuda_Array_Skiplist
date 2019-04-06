#include"Skiplist.h"
#include<iostream>
using namespace std;
#define BLOCKSIZE 512
#define GRIDSIZE 8192
Node* test_Init(Node *sl,Node *n_arr,int N){
	Init <<<GRIDSIZE,BLOCKSIZE>>> (sl,n_arr,N);
	return sl;
}
Node* test_Connect(Node*sl,int N){
	Connect<<<GRIDSIZE,BLOCKSIZE>>>(sl,N);
	return sl;
}
struct timespec diff(timespec start, timespec end) {
  struct timespec temp;
  if ((end.tv_nsec - start.tv_nsec) < 0) {
    temp.tv_sec = end.tv_sec - start.tv_sec - 1;
    temp.tv_nsec = 1000000000 + end.tv_nsec - start.tv_nsec;
  } else {
    temp.tv_sec = end.tv_sec - start.tv_sec;
    temp.tv_nsec = end.tv_nsec - start.tv_nsec;
  }
  return temp;
}

struct timespec add(timespec start, timespec end) {
	struct timespec temp;
	if((end.tv_nsec+start.tv_nsec) < 0) {
		temp.tv_sec = end.tv_sec+start.tv_sec + 1;
		temp.tv_nsec = end.tv_nsec + start.tv_nsec - 1000000000;
	}else{
		temp.tv_sec = end.tv_sec + start.tv_sec;
		temp.tv_nsec = end.tv_nsec + start.tv_nsec;
	}
	return temp;
}

int main(){
	int N;
	Node* sl;
	Node* d_sl;
	Node* n_arr;
	Node* d_n_arr;
	struct timespec time1,time2;
	int loop;
	struct timespec sum;
	for(int size=1;size<=GRIDSIZE;size<<=1){
		//initializtion
		N=BLOCKSIZE*size/MAX_LEVEL;
		sl=(Node*)malloc(N*MAX_LEVEL*sizeof(Node));
		n_arr=(Node*)malloc(N*sizeof(Node));
		cudaMalloc(&d_sl,N*MAX_LEVEL*sizeof(Node));
		cudaMalloc(&d_n_arr,N*sizeof(Node));
		for(int i=0 ; i<MAX_LEVEL*N ;i++){
					sl[i].key=-1;
					sl[i].level=0;
					sl[i].nextIdx=-1;
				}

		srand(time(NULL));
		for(int i=0;i<N;i++){
			n_arr[i].key=i;
			n_arr[i].level=rand()%MAX_LEVEL+1;
		}

		//test loop
		for(loop=1;loop<=1;loop++){
			clock_gettime(CLOCK_PROCESS_CPUTIME_ID,&time1);//timespec start
			cudaMemcpy(d_sl,sl,N*MAX_LEVEL*sizeof(Node),cudaMemcpyHostToDevice);
			cudaMemcpy(d_n_arr,n_arr,N*sizeof(Node),cudaMemcpyHostToDevice);
			test_Init(d_sl,d_n_arr,N);
			test_Connect(d_sl,N);
			cudaMemcpy(sl,d_sl,N*MAX_LEVEL*sizeof(Node),cudaMemcpyDeviceToHost);
			clock_gettime(CLOCK_PROCESS_CPUTIME_ID,&time2);//timespec stop
			sum = add(time1,time2);
			/*printf("Skiplist node value:\n");
			for(int i=0 ; i<MAX_LEVEL*N ;i++){
				printf("%2d ",sl[i].key);
				if(i%N==N-1)
				printf("\n");
			}
			printf("Skiplist nextIdx:\n");
			for(int i=0 ;i<MAX_LEVEL*N;i++){
				printf("%2d ",sl[i].nextIdx%N);
				if(i%N==N-1)
					printf("\n");
			}*/
		}
		printf("%d\t0.%.9ld\n",size,(sum.tv_sec*1000000000+sum.tv_nsec)/loop);
		free(sl);
		free(n_arr);
		cudaFree(d_sl);
		cudaFree(d_n_arr);
	}
}

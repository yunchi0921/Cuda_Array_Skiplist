#include"Skiplist.h"

Node* test_Init(Node *sl,Node *n_arr,int N){
	Init <<<1,256>>> (sl,n_arr,N);
	return sl;
}
Node* test_Connect(Node*sl,int N){
	Connect<<<1,256>>>(sl,N);
	return sl;
}
int main(){
	int N=10;
	Node* sl=(Node*)malloc(N*MAX_LEVEL*sizeof(Node));
	Node* d_sl;
	Node* n_arr=(Node*)malloc(N*sizeof(Node));
	Node* d_n_arr;

		for(int i=0 ; i<MAX_LEVEL*N ;i++){
				sl[i].key=0;
				sl[i].level=0;
				sl[i].nextIdx=0;
				sl[i].selfIdx=0;
			}

	srand(time(NULL));
	for(int i=0;i<10;i++){
		n_arr[i].key=i;
		n_arr[i].level=rand()%8+1;
	}


	cudaMalloc(&d_sl,N*MAX_LEVEL*sizeof(Node));
	cudaMalloc(&d_n_arr,N*sizeof(Node));
	cudaMemcpy(d_sl,sl,N*MAX_LEVEL*sizeof(Node),cudaMemcpyHostToDevice);
	cudaMemcpy(d_n_arr,n_arr,N*sizeof(Node),cudaMemcpyHostToDevice);
	test_Init(d_sl,d_n_arr,N);
	test_Connect(d_sl,N);
	cudaMemcpy(sl,d_sl,N*MAX_LEVEL*sizeof(Node),cudaMemcpyDeviceToHost);


	for(int i=0 ; i<MAX_LEVEL*N ;i++){

		printf("%d ",sl[i].key);
		if(i%N==N-1)
		printf("\n");
	}
	for(int i=0 ;i<MAX_LEVEL*N;i++){
		printf("%d ",sl[i].nextIdx%N);
		if(i%N==N-1)
			printf("\n");
	}
}

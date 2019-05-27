#include"Skiplist.h"
#include <thrust/sort.h>
#define BLOCKSIZE 1024
#define GRIDSIZE 16



void test_Init(Node *sl,int N) {
	Init<<<N/BLOCKSIZE,BLOCKSIZE, BLOCKSIZE * sizeof(Node)>>>(
			sl,N);

}
void test_Connect(Node*sl, int N) {
	Connect<<<GRIDSIZE, BLOCKSIZE, BLOCKSIZE * sizeof(Node)>>>(sl, N);
}
void shuffle(int *a,int n){
	int i,j,tmp,T=1000;
	while(T--)
	{
		i=rand()%n;
		j=rand()%n;
		tmp=a[i];
		a[i]=a[j];
		a[j]=tmp;
	}
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
	if ((end.tv_nsec + start.tv_nsec) < 0) {
		temp.tv_sec = end.tv_sec + start.tv_sec + 1;
		temp.tv_nsec = end.tv_nsec + start.tv_nsec - 1000000000;
	} else {
		temp.tv_sec = end.tv_sec + start.tv_sec;
		temp.tv_nsec = end.tv_nsec + start.tv_nsec;
	}
	return temp;
}

int main() {
	// Error code to check return values for CUDA calls
	cudaError_t err = cudaSuccess;
	int N=BLOCKSIZE*GRIDSIZE;
	Node* sl;
	Node* d_sl;
	struct timespec time1, time2;
	struct timespec sum;
	int loop = 1;
	int* input=(int*)malloc(N*sizeof(int));
	//initializtion
	sl = (Node*) malloc(N * MAX_LEVEL * sizeof(Node));
	err = cudaMalloc(&d_sl, N * MAX_LEVEL * sizeof(Node));
	if (err != cudaSuccess) {
		fprintf(stderr,
				"Failed to allocate device skiplist  (error code %s)!\n",
				cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}
	for(int i=0;i<N;i++){
		input[i]=i;
	}
	shuffle(input,N);//random the order
	clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &time1);
	thrust::sort(input,input+N);//sorting
	clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &time2);
	struct timespec temp=diff(time1,time2);
	double time_used=1000*(temp.tv_sec+(double)temp.tv_nsec/1000000000.0);
	printf("Sorting time= %f\n",time_used);
	srand(time(NULL)); // to rand the level
	for (int i = 0; i < N * MAX_LEVEL; i++) {
		if (i < N) {
			sl[i].key = input[i];
			if (i % BLOCKSIZE == BLOCKSIZE-1 || i % BLOCKSIZE == 0) {
				sl[i].level = MAX_LEVEL;
			} else {
				sl[i].level = rand() % MAX_LEVEL + 1;
			}
		} else {
			sl[i].key = -1;
		}
		if (i % BLOCKSIZE == BLOCKSIZE - 1)
			sl[i].nextIdx = i + 1;
		else
			sl[i].nextIdx = -1;
	}
	clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &time1); //timespec start
	err = cudaMemcpy(d_sl, sl, N * MAX_LEVEL * sizeof(Node),
			cudaMemcpyHostToDevice);

	if (err != cudaSuccess) {
		fprintf(stderr,
				"Failed to copy device skiplist from host to device (error code %s)!\n",
				cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}
	test_Init(d_sl,N);
	err = cudaGetLastError();

	if (err != cudaSuccess) {
		fprintf(stderr, "Failed to launch Init kernel (error code %s)!\n",
				cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	test_Connect(d_sl, N);
	err = cudaGetLastError();

	if (err != cudaSuccess) {
		fprintf(stderr, "Failed to launch connect kernel (error code %s)!\n",
				cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	err = cudaMemcpy(sl, d_sl, N * MAX_LEVEL * sizeof(Node),
			cudaMemcpyDeviceToHost);
	if (err != cudaSuccess) {
		fprintf(stderr,
				"Failed to copy device skiplist from device to host (error code %s)!\n",
				cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &time2); //timespec stop
	sum = add(time1, time2);
	/*printf("Skiplist node value:\n");
	for (int i = 0; i < MAX_LEVEL * N; i++) {
		printf("%2d ", sl[i].key);
		if (i % N == N - 1)
			printf("\n");
	}
	printf("Skiplist nextIdx:\n");
	for (int i = 0; i < MAX_LEVEL * N; i++) {
		printf("%2d ", sl[i].nextIdx % N);
		if (i % N == N - 1)
			printf("\n");
	}*/

	printf("%d\t%ld\n",N,(sum.tv_sec*1000000000+sum.tv_nsec)/loop);
	free(sl);
	err = cudaFree(d_sl);
	if (err != cudaSuccess) {
		fprintf(stderr, "Failed to free device skiplist (error code %s)!\n",
				cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}
}


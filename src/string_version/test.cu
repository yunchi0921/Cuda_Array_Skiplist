#include "Skiplist.h"
#include <thrust/sort.h>
#include <assert.h>
void test_Init(Node *sl, int N, int BLOCKSIZE, int GRIDSIZE) {
  Init<<<N / BLOCKSIZE, BLOCKSIZE, BLOCKSIZE * sizeof(Node)>>>(sl, N);
}
void test_Connect(Node *sl, int N, int BLOCKSIZE, int GRIDSIZE) {
  Connect<<<GRIDSIZE, BLOCKSIZE, BLOCKSIZE * sizeof(Node)>>>(sl, N);
}
void shuffle(vector<string> a,vector<string> b, int n) {
  int i, j, T = 1000;
  string tmp;
  while (T--) {
    i = rand() % n;
    j = rand() % n;
    tmp = a[i];
    a[i] = a[j];
    a[j] = tmp;
    tmp = b[i];
    b[i] = b[j];
    b[j] = tmp;
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

int main(int argc, char *argv[]) {
  cudaDeviceSetLimit(cudaLimitMallocHeapSize, 1024*1024*1024);
  if (argc < 3) {
    printf("error:Need more argument\n");
    return 0;
  }
  int gridsize = atoi(argv[1]);
  int blocksize = atoi(argv[2]);
  // Error code to check return values for CUDA calls
  cudaError_t err = cudaSuccess;
  int N = gridsize * blocksize;
  Node *sl;
  Node *d_sl;
  struct timespec time1, time2, temp;
  double time_used, sum = 0,sum_sort=0;
  int loop;
  vector<string> key,value;
  thrust::host_vector<string> h_key(N);
  thrust::host_vector<string> h_value(N);
  thrust::device_vector<string> d_key(N);
  thrust::device_vector<string> d_value(N);
  for (loop = 1; loop <=1; loop++) {
    //input = (string *)malloc(N * sizeof(string));
    // initializtion
    sl = (Node *)malloc(N * MAX_LEVEL * sizeof(Node));
    err = cudaMalloc(&d_sl, N * MAX_LEVEL * sizeof(Node));
    if (err != cudaSuccess) {
      fprintf(stderr, "Failed to allocate device skiplist  (error code %s)!\n",
              cudaGetErrorString(err));
      exit(EXIT_FAILURE);
    }
    for (int i = 0; i < N; i++) {
      key[i] = to_string(i);
      value[i] = to_string(i);
    }
    shuffle(key,value, N); // random the order
    for(int i=0;i<N;i++){
    	h_key[i]=key[i];
	h_value[i]=value[i];
    }

    d_key=h_key;
    d_value=h_value;

    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &time1);
    thrust::sort_by_key(d_key.begin(), d_key.end(),d_value.begin()); // sorting
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID,&time2);
    temp = diff(time1, time2);
    time_used = 1000 * (temp.tv_sec + (double)temp.tv_nsec / 1000000000.0);
    sum_sort+=time_used;
    //copy device to host
    h_key=d_key;
    h_value=d_value;
    //check 
    for(int i=0;i<N;i++){
    	assert(h_key[i]==to_string(i));
	assert(h_value[i]==to_string(i));
    }
    srand(time(NULL)); // to rand the level
    for (int i = 0; i < N * MAX_LEVEL; i++) {
      if (i < N) {
        sl[i].key = h_key[i];
	sl[i].value=h_value[i];
        if (i % blocksize == blocksize - 1 || i % blocksize == 0) {
          sl[i].level = MAX_LEVEL;
        } else {
          sl[i].level = rand() % MAX_LEVEL + 1;
        }
      } else {
        sl[i].key = -1;
	sl[i].value = -1;
      }
      if (i % blocksize == blocksize - 1)
        sl[i].nextIdx = i + 1;
      else
        sl[i].nextIdx = -1;
    }
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &time1); // timespec start
    err = cudaMemcpy(d_sl, sl, N * MAX_LEVEL * sizeof(Node),
                     cudaMemcpyHostToDevice);
    if (err != cudaSuccess) {
      fprintf(stderr,
              "Failed to copy device skiplist from host to device (error code "
              "%s)!\n",
              cudaGetErrorString(err));
      exit(EXIT_FAILURE);
    }
    test_Init(d_sl, N, blocksize, gridsize);
    err = cudaGetLastError();

    if (err != cudaSuccess) {
      fprintf(stderr, "Failed to launch Init kernel (error code %s)!\n",
              cudaGetErrorString(err));
      exit(EXIT_FAILURE);
    }

    test_Connect(d_sl, N, blocksize, gridsize);
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
              "Failed to copy device skiplist from device to host (error code "
              "%s)!\n",
              cudaGetErrorString(err));
      exit(EXIT_FAILURE);
    }

    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &time2); // timespec stop
    temp = diff(time1, time2);
    time_used = 1000 * (temp.tv_sec + (double)temp.tv_nsec / 1000000000.0);
    sum += time_used;
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

   // free(key);
    //free(value);
    free(sl);
    err = cudaFree(d_sl);
    if (err != cudaSuccess) {
      fprintf(stderr, "Failed to free device skiplist (error code %s)!\n",
              cudaGetErrorString(err));
      exit(EXIT_FAILURE);
    }
    
  }
  printf("Sorting time= %f\n", sum_sort/loop);
  printf("%d\t%f\n", N, sum / loop);
}

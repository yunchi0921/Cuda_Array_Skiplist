#include "Skiplist.h"
#include <thrust/sort.h>
#include <assert.h>
Node *test_Init(Node *sl, Node *n_arr, int N, int gridsize, int blocksize) {
  Init<<<gridsize, blocksize>>>(sl, n_arr, N);
  return sl;
}
Node *test_Connect(Node *sl, int N, int girdsize, int blocksize) {
  Connect<<<girdsize, blocksize>>>(sl, N);
  return sl;
}
void shuffle(int *a, int n) {
  int i, j, tmp, T = 1000;
  while (T--) {
    i = rand() % n;
    j = rand() % n;
    tmp = a[i];
    a[i] = a[j];
    a[j] = tmp;
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
  if (argc < 3) {
    printf("error:Need more argument\n");
    return 0;
  }
  int gridsize = atoi(argv[1]);
  int blocksize = atoi(argv[2]);
  int N;
  Node *sl;
  Node *d_sl;
  Node *n_arr;
  Node *d_n_arr;
  struct timespec time1, time2, temp;
  int loop;
  // initializtion
  double time_used,sum=0;
  N = gridsize * blocksize / MAX_LEVEL;
  for(loop=1;loop<=1;loop++){
  int *input = (int *)malloc(N * sizeof(int));
  for (int i = 0; i < N; i++) {
    input[i] = i;
  }
  srand(time(NULL));
  shuffle(input,N);

  thrust::host_vector<int> h_s(N);
    //give number to host_vector
    for(int i=0;i<N;i++){
    	h_s[i]=input[i];
    }
    thrust::device_vector<int> d_s(h_s);

    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &time1);
    thrust::sort(d_s.begin(), d_s.end()); // sorting
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID,&time2);
    temp = diff(time1, time2);
    time_used = 1000 * (temp.tv_sec + (double)temp.tv_nsec / 1000000000.0);
    printf("Sorting time= %f\n", time_used);
    //copy device to host
    h_s=d_s;
    //check
    for(int i=0;i<N;i++)
	    assert(h_s[i]==i);
  sl = (Node *)malloc(N * MAX_LEVEL * sizeof(Node));
  n_arr = (Node *)malloc(N * sizeof(Node));
  cudaMalloc(&d_sl, N * MAX_LEVEL * sizeof(Node));
  cudaMalloc(&d_n_arr, N * sizeof(Node));
  for (int i = 0; i < MAX_LEVEL * N; i++) {
    sl[i].key = -1;
    sl[i].level = 0;
    sl[i].nextIdx = -1;
  }

  srand(time(NULL));
  for (int i = 0; i < N; i++) {
    n_arr[i].key = h_s[i];
    n_arr[i].level = rand() % MAX_LEVEL + 1;
  }

  clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &time1); // timespec start
  cudaMemcpy(d_sl, sl, N * MAX_LEVEL * sizeof(Node), cudaMemcpyHostToDevice);
  cudaMemcpy(d_n_arr, n_arr, N * sizeof(Node), cudaMemcpyHostToDevice);
  test_Init(d_sl, d_n_arr, N, gridsize, blocksize);
  test_Connect(d_sl, N, gridsize, blocksize);
  cudaMemcpy(sl, d_sl, N * MAX_LEVEL * sizeof(Node), cudaMemcpyDeviceToHost);
  clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &time2); // timespec stop

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
  temp = diff(time1, time2);
  time_used = 1000 * (temp.tv_sec + (double)temp.tv_nsec / 1000000000.0);
  sum+=time_used;
  free(input);
  free(sl);
  free(n_arr);
  cudaFree(d_sl);
  cudaFree(d_n_arr);
  }
  printf("%d\t%f\n", N, sum/loop);
}

# Cuda Skiplist
---
This is a project that test Skiplist using Cuda.

It isn't really a Skiplist. It's a SkipArray. We will use `thrust sort` first , and construct node level and assign its value parallelly.

## Features

* Numbers of Node are same as numbers of threads.
* Use shared memory to increase speed.
* It isn't faster than normal Insert method but it is potential to pass normal Insert.
* We will try to use this on LevelDB

## Quick Start

```
$ make

```
### Change numbers of Node

if you want to change the number of Node , you can change the macro GRIDSIZE and BLOCKSIZE because it depends on product of these two.

```
#define GRIDSIZE "number u want"
#define BLOCKSIZE "number u want"
```

### Print the Skiplist

if you want to see the result of the Skiplist , you can delete annotation before printf in the loop.

```
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

```


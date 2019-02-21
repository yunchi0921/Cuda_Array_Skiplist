/*
 ============================================================================
 Name        : Skiplist.cu
 Author      : Yunchi
 Version     :
 Copyright   : Your copyright notice
 Description : CUDA compute reciprocals
 ============================================================================
 */

#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include"Skiplist.h"

#define MAX_LEVEL 12

void __device__ NodeSearch(Node **n,int key,int * update){

	//setting head
	Node cur=n[0][MAX_LEVEL];
	Node next_node;
	int level;

	for(level=MAX_LEVEL-1;level>=0;level--){
		next_node=n[cur.nextIdx][level];
		while(next_node.key!=INT_MAX&&next_node.key<key){
			cur=next_node;
			next_node=n[cur.nextIdx][level];
		}
		update[level]=cur.selfIdx;
	}
}

void __device__ Insert(Node **sl,Node n,int latest){
	int level=n.level;
	Node dest;
	int idx_first_read,idx_second_read;
	int update[MAX_LEVEL];
		do{
			NodeSearch(sl,n.key,update);
			for(int i=0;i<level;i++){
				dest=sl[update[i]][i];
				idx_first_read=dest.nextIdx;

				//Allow each node thread to set the forward facing index
				n.nextIdx=idx_first_read;

				idx_second_read
				=(int)atomicCAS((unsigned long long int*)&(dest.nextIdx),
						*(unsigned long long int *)&idx_first_read,
						*(unsigned long long int *)&latest);
			}
		}while(idx_first_read!=idx_second_read);

}

Node NodeCreate(int key,int level){
	Node n;
	n.key=key;
	n.level=level;
	return n;
}

Node __device__ IndexSetting(Node &n,int nextIdx,int latest ){
	n.nextIdx=nextIdx;
	n.selfIdx=latest;
	return n;
}







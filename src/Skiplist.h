/*
 * Skiplist.h
 *
 *  Created on: Feb 18, 2019
 *      Author: yunchi
 */

#ifndef SKIPLIST_H_
#define SKIPLIST_H_

struct Node{
	int key;
	int nextIdx,prevIdx,selfIdx;
	int level;
};

void __device__ Insert(Node ** sl,Node n,int latest );
void __device__ NodeSearch(Node ** sl ,int key,int *update);
Node NodeCreate(int key,int level);
Node __device__ IndexSetting(Node *n,int nextIdx,int latest);

#endif /* SKIPLIST_H_ */

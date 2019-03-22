/*
 * Skiplist.h
 *
 *  Created on: Feb 18, 2019
 *      Author: yunchi
 */
#include <stdio.h>
#include <stdlib.h>
#ifndef SKIPLIST_H_
#define SKIPLIST_H_
#define MAX_LEVEL 8
struct Node{
	int key;
	int nextIdx,selfIdx;
	int level;
};

void __global__ Init(Node *sl,Node *n,int N);
void __global__ Connect(Node *sl,int N);


#endif /* SKIPLIST_H_ */

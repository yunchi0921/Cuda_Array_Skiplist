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
#define MAX_LEVEL 4
/**
 * Skiplist will be constructed by several Node and save key and its nextIdx,each thread when it call Connect(Node*)
 *  it will set nextIdx to the key that is non zero index of node.
 */
struct Node{
	int key;
	int nextIdx;
	int level;
};

void __global__ Init(Node *sl,int N);
void __global__ Connect(Node *sl,int N);


#endif /* SKIPLIST_H_ */

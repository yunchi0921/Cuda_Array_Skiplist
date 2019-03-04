OPT=-O3

all: test

test: test.o Skiplist.o
	nvcc $(OPT) -rdc=true -o $@ $^

test.o: test.cu Skiplist.h Makefile
	nvcc $(OPT) -rdc=true -c -o $@ $<
Skiplist.o: Skiplist.cu Skiplist.h Makefile
	nvcc $(OPT) -rdc=true -c -o $@ $<



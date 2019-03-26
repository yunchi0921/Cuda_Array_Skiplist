
all: test_gpu

test_gpu: test.o Skiplist.o
	nvcc -g -o $@ $^
test.o: test.cu Skiplist.h Makefile
	nvcc -g -c -o $@ $<
Skiplist.o: Skiplist.cu Skiplist.h Makefile
	nvcc -g -c -o $@ $<
clean:
	rm test.o  Skiplist.o test_gpu



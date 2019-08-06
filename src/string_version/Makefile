
all: test_gpu

test_gpu: test.o Skiplist.o
	nvcc  -o $@ $^
test.o: test.cu Skiplist.h Makefile
	nvcc -c -o $@ $<
Skiplist.o: Skiplist.cu Skiplist.h Makefile
	nvcc -c -o $@ $<
clean:
	rm test.o  Skiplist.o test_gpu
plot:
	gnuplot time.gp


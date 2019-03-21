
all: test_cpu test_gpu

test_gpu: test.o Skiplist.o
	nvcc -g -o $@ $^
test_cpu: test_cpu.o Skiplist_cpu.o
	nvcc -deviceemu -g -o $@ $^

test.o: test.cu Skiplist.h Makefile
	nvcc -g -c -o $@ $<
Skiplist.o: Skiplist.cu Skiplist.h Makefile
	nvcc -g -c -o $@ $<

Skiplist_cpu.o: Skiplist.cu Skiplist.h Makefile
	nvcc -deviceemu -g -c -o $@ $<
test_cpu.o: test.cu Skiplist.h Makefile
	nvcc -deviceemu -g -c -o $@ $<
clean:
	rm test.o test_* Skiplist.o Skiplist_*


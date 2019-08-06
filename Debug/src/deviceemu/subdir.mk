################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CU_SRCS += \
../src/deviceemu/Skiplist.cu \
../src/deviceemu/test.cu 

OBJS += \
./src/deviceemu/Skiplist.o \
./src/deviceemu/test.o 

CU_DEPS += \
./src/deviceemu/Skiplist.d \
./src/deviceemu/test.d 


# Each subdirectory must supply rules for building sources it contributes
src/deviceemu/%.o: ../src/deviceemu/%.cu
	@echo 'Building file: $<'
	@echo 'Invoking: NVCC Compiler'
	/usr/local/cuda-10.0/bin/nvcc -G -g -O0 -gencode arch=compute_52,code=sm_52  -odir "src/deviceemu" -M -o "$(@:%.o=%.d)" "$<"
	/usr/local/cuda-10.0/bin/nvcc -G -g -O0 --compile --relocatable-device-code=false -gencode arch=compute_52,code=compute_52 -gencode arch=compute_52,code=sm_52  -x cu -o  "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '



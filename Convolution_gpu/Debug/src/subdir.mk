################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CU_SRCS += \
../src/Convolution_gpu.cu 

CU_DEPS += \
./src/Convolution_gpu.d 

OBJS += \
./src/Convolution_gpu.o 


# Each subdirectory must supply rules for building sources it contributes
src/Convolution_gpu.o: /home/angela/Documentos/DEV/ws_tmp/Convolution_gpu/src/Convolution_gpu.cu
	@echo 'Building file: $<'
	@echo 'Invoking: NVCC Compiler'
	/usr/local/cuda-7.5/bin/nvcc -I/usr/local/include -I/usr/local/include/opencv -G -g -O0 -gencode arch=compute_50,code=sm_50  -odir "src" -M -o "$(@:%.o=%.d)" "$<"
	/usr/local/cuda-7.5/bin/nvcc -I/usr/local/include -I/usr/local/include/opencv -G -g -O0 --compile --relocatable-device-code=false -gencode arch=compute_50,code=compute_50 -gencode arch=compute_50,code=sm_50  -x cu -o  "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '



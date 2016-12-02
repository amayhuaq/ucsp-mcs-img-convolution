#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>

#include "ImageHelper.h"

using namespace std;

__global__ void applySobelFilter(uchar *image, float *filter, uchar *out_image, int w, int h)
{
	int left, right, top, bottom, lefttop, righttop, leftbot, rightbot;

	int x = threadIdx.x + blockIdx.x * blockDim.x;
	int y = threadIdx.y + blockIdx.y * blockDim.y;
	int offset = x + y * blockDim.x * gridDim.x;

	left = offset - 1;
	right = offset + 1;
	if (x == 0) left++;
	if (x == w - 1) right--;
	top = offset - w;
	bottom = offset + w;
	if (y == 0) top += w;
	if (y == w - 1) bottom -= w;

	lefttop = top - 1;
	righttop = top + 1;
	leftbot = bottom - 1;
	rightbot = bottom + 1;

	if (x == 0)	{
		lefttop = top;
		leftbot = bottom;
	}
	if (x == w - 1) {
		righttop = top;
		rightbot = bottom;
	}
	if (y == 0) {
		lefttop = top;
		righttop = top;
	}
	if (y == h - 1) {
		leftbot = bottom;
		rightbot = bottom;
	}

	int sum_x = (image[lefttop] * filter[0] + image[top] * filter[1] + image[righttop] * filter[2])
			+ (image[left] * filter[3] + image[offset] * filter[4] + image[right] * filter[5])
			+ (image[leftbot] * filter[6] + image[bottom] * filter[7] + image[rightbot] * filter[8]);

	int sum_y = (image[lefttop] * filter[0] + image[top] * filter[3] + image[righttop] * filter[6])
			+ (image[left] * filter[1] + image[offset] * filter[4] + image[right] * filter[7])
			+ (image[leftbot] * filter[2] + image[bottom] * filter[5] + image[rightbot] * filter[8]);

	out_image[offset] = sqrtf((sum_x * sum_x) + (sum_y * sum_y));
}

__device__ int getOffsetPos(int w, int h, int i, int j)
{
	if (i < 0 || i >= h || j < 0 || j >= w)
		return -1;
	return i * w + j;
}

__device__ int getRowFromPos(int pos, int w)
{
	return pos / w;
}

__device__ int getColFromPos(int pos, int w)
{
	return pos % w;
}

__global__ void applyFilter2(uchar *image, float *filter, uchar *out_image, int w, int h, int wf, int hf)
{
	int x = threadIdx.x + blockIdx.x * blockDim.x;
	int y = threadIdx.y + blockIdx.y * blockDim.y;
	int offset = x + y * blockDim.x * gridDim.x;

	int i = getRowFromPos(offset, w);
	int j = getColFromPos(offset, w);

	if(i >= h || j >= w)
		return;

	float sumVals = 0;
	int cini, cfin, rini, rfin;

	cini = j - wf / 2;
	cfin = j + wf / 2;
	rini = i - hf / 2;
	rfin = i + hf / 2;
	cini = (cini < 0) ? 0 : cini;
	rini = (rini < 0) ? 0 : rini;
	cfin = (cfin >= w) ? w-1 : cfin;
	rfin = (rfin >= h) ? h-1 : rfin;

	for(int fi = 0; rini <= rfin && fi < hf; rini++, fi++) {
		for(int tj = cini, fj = 0; tj <= cfin && fj < wf; tj++, fj++) {
			sumVals += image[getOffsetPos(w, h, rini, tj)] * filter[getOffsetPos(wf, hf, fi, fj)];
		}
	}
	out_image[offset] = sumVals;
}

Mat applyFilter(Mat img, Filter *filter)
{
	int width, height;
	uchar *bitmap, *out_bitmap;
	uchar *dev_bitmap, *dev_out_bitmap;
	float *dev_filter;

	width = img.cols;
	height = img.rows;
	bitmap = convertMatToArray(img);
	out_bitmap = new uchar[height * width];

	cout << "Applying Filter: " << filter->h << " x " << filter->w << endl;
	cout << "Size image: " << width << " x " << height << endl;

	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	cudaEventRecord(start, 0);

	cudaMalloc((void**)&dev_filter, filter->w * filter->h * sizeof(float));
	cudaMalloc((void**)&dev_bitmap, width * height * sizeof(uchar));
	cudaMalloc((void**)&dev_out_bitmap, width * height * sizeof(uchar));

	cudaMemcpy(dev_filter, filter->values, filter->w * filter->h * sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(dev_bitmap, bitmap, width * height * sizeof(uchar), cudaMemcpyHostToDevice);

	int blocks = (width * height + MAX_THREADS - 1) / MAX_THREADS;
	int threads = MAX_THREADS;

	clock_t time = clock();
	switch (filter->type) {
		case SOBEL_FILTER:
			applySobelFilter << <blocks, threads >> >(dev_bitmap, dev_filter, dev_out_bitmap, width, height);
			break;
		default:
			applyFilter2 << <blocks, threads >> >(dev_bitmap, dev_filter, dev_out_bitmap, width, height, filter->w, filter->h);
			break;
	}
	cudaMemcpy(out_bitmap, dev_out_bitmap, width * height * sizeof(uchar), cudaMemcpyDeviceToHost);

	cudaFree(dev_filter);
	cudaFree(dev_out_bitmap);
	cudaFree(dev_bitmap);

	cudaEventRecord(stop, 0);
	cudaEventSynchronize(stop);

	float elapsedTime;
	cudaEventElapsedTime(&elapsedTime, start, stop);
	cout << "Elapsed time: " << elapsedTime / 1000.0 << " secs\n";

	return convertArrayToMat(out_bitmap, width, height);
}

int main(int argc, char **argv)
{
	Mat img = loadImage("data/persona04.jpg", GREY_MODE);
	//Mat out = applyFilter(img, createFilter(SOBEL_FILTER, 3));
	Mat out = applyFilter(img, createFilter(AVG_FILTER, 21));

	showImage(img, "Input image");
	showImage(out, "Filtered image");

	return 0;
}

# ucsp-mcs-img-convolution
Convolution in serial mode, using openmp and gpu

In this repository we have 3 projects:

- *Convolution_gpu*: an Nsight Eclipse Edition project that is based on Cuda and OpenCV.

- *Convolution_omp*: an Eclipse C++ project that is based on OpenMP and OpenCV.

- *Convolution_serial*: an Eclipse C++ project that is based on OpenCV and it does not use cores or gpu.


```c++
int main(int argc, char* argv[])
{
	Mat img = loadImage("data/persona04.jpg", GREY_MODE);   // input image
	Mat out = applyFilter(img, createFilter(AVG_FILTER, 21));   // type of filter and its size
  
  // Show images
	showImage(img, "Input image");
	showImage(out, "Filtered image");
	return 0;
}
```

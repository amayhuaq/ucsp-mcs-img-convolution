#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv/cv.h>
#include <iostream>

#include "Variables.h"

using namespace cv;
using namespace std;

typedef struct Filter {
	int w;
	int h;
	char type;
	float *values;
};

int getOffsetPos(int w, int h, int i, int j)
{
	if (i < 0 || i >= h || j < 0 || j >= w)
		return -1;
	return i * w + j;
}

Filter *createFilter(int type, int w, int h=0)
{
	Filter *filter = new Filter;
	filter->type = type;
	filter->w = w;
	filter->h = (h == 0) ? w : h;
	int len = filter->w * filter->h;
	filter->values = new float[len];

	switch (type) {
		case SOBEL_FILTER:
			filter->values[0] = -1; filter->values[1] = 0; filter->values[2] = 1;
			filter->values[3] = -2; filter->values[4] = 0; filter->values[5] = 2;
			filter->values[6] = -1; filter->values[7] = 0; filter->values[8] = 1;
			break;
		case AVG_FILTER:
			float val = 1.0 / len;
			for(int i=0; i<len; i++)
				filter->values[i] = val;
			break;
	}
	return filter;
}

void showImage(Mat image, string nameWindow)
{
	namedWindow(nameWindow, WINDOW_OPENGL);
	imshow(nameWindow, image);
	waitKey(0);
}

Mat loadImage(string imagePath, char type)
{
	Mat out;

	switch (type)
	{
		case GREY_MODE:
			out = imread(imagePath, CV_LOAD_IMAGE_GRAYSCALE);
			break;
		default:
			out = imread(imagePath);
			break;
	}

	if(out.empty())
	{
		cout << "Image does not exists" << endl;
		return out;
	}

	return out;
}

uchar *convertMatToArray(Mat img)
{
	uchar *out = img.data;
	return out;
}

Mat convertArrayToMat(uchar *data, int width, int height)
{
	Mat tmp(height, width, CV_8UC1, data);
	return tmp;
}

void printImageValues(unsigned char *image, int w, int h)
{
	for (int i = 0; i < 10; i++)
	{
		for (int j = 0; j < 10; j++)
		{
			cout << (int)image[i * w + j] << " ";
		}
		cout << "\n";
	}
	cout << endl;
}

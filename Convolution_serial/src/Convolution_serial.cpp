#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>

#include "ImageHelper.h"

using namespace std;

void applySobelFilter(uchar *image, Filter *filter, uchar *out_image, int w, int h)
{
	int offset, left, right, top, bottom, lefttop, righttop, leftbot, rightbot;

	for (int i = 0; i < h; i++) {
		for (int j = 0; j < w; j++) {
			offset = getOffsetPos(w,h,i,j);
			left = offset - 1;
			right = offset + 1;
			if (i == 0) left++;
			if (i == h - 1) right--;
			top = offset - w;
			bottom = offset + w;
			if (j == 0) top += w;
			if (j == w - 1) bottom -= w;

			lefttop = top - 1;
			righttop = top + 1;
			leftbot = bottom - 1;
			rightbot = bottom + 1;

			if (j == 0)	{
				lefttop = top;
				leftbot = bottom;
			}
			if (j == w - 1) {
				righttop = top;
				rightbot = bottom;
			}
			if (i == 0) {
				lefttop = top;
				righttop = top;
			}
			if (i == h - 1) {
				leftbot = bottom;
				rightbot = bottom;
			}

			int sum_x = (image[lefttop] * filter->values[0] + image[top] * filter->values[1] + image[righttop] * filter->values[2])
					+ (image[left] * filter->values[3] + image[offset] * filter->values[4] + image[right] * filter->values[5])
					+ (image[leftbot] * filter->values[6] + image[bottom] * filter->values[7] + image[rightbot] * filter->values[8]);

			int sum_y = (image[lefttop] * filter->values[0] + image[top] * filter->values[3] + image[righttop] * filter->values[6])
					+ (image[left] * filter->values[1] + image[offset] * filter->values[4] + image[right] * filter->values[7])
					+ (image[leftbot] * filter->values[2] + image[bottom] * filter->values[5] + image[rightbot] * filter->values[8]);

			out_image[offset] = sqrt((sum_x * sum_x) + (sum_y * sum_y));
		}
	}
}

void applyFilter2(uchar *image, Filter *filter, uchar *out_image, int w, int h)
{
	float sumVals;
	int cini, cfin, rini, rfin;

	for(int i = 0; i < h; i++) {
		for(int j = 0; j < w; j++) {
			sumVals = 0;
			cini = j - filter->w / 2;
			cfin = j + filter->w / 2;
			rini = i - filter->h / 2;
			rfin = i + filter->h / 2;
			cini = (cini < 0) ? 0 : cini;
			rini = (rini < 0) ? 0 : rini;
			cfin = (cfin >= w) ? w-1 : cfin;
			rfin = (rfin >= h) ? h-1 : rfin;

			for(int fi=0; rini <= rfin && fi < filter->h; rini++, fi++) {
				for(int tj = cini, fj = 0; tj <= cfin && fj < filter->w; tj++, fj++) {
					sumVals += image[getOffsetPos(w,h,rini,tj)] * filter->values[getOffsetPos(filter->w, filter->h, fi, fj)];
				}
			}
			out_image[getOffsetPos(w,h,i,j)] = sumVals;
		}
	}
}

Mat applyFilter(Mat img, Filter *filter)
{
	int width, height;
	uchar *bitmap, *out_bitmap;

	width = img.cols;
	height = img.rows;
	bitmap = convertMatToArray(img);
	out_bitmap = new uchar[height * width];

	cout << "Applying Filter: " << filter->h << " x " << filter->w << endl;
	cout << "Size image: " << width << " x " << height << endl;

	clock_t time = clock();
	switch (filter->type) {
		case SOBEL_FILTER:
			applySobelFilter(bitmap, filter, out_bitmap, width, height);
			break;
		default:
			applyFilter2(bitmap, filter, out_bitmap, width, height);
			break;
	}
	time = clock() - time;
	cout << "Elapsed time: " << ((float)(time)) / CLOCKS_PER_SEC << " secs\n";

	return convertArrayToMat(out_bitmap, width, height);
}

int main(int argc, char* argv[])
{
	Mat img = loadImage("data/persona04.jpg", GREY_MODE);
	//Mat out = applyFilter(img, createFilter(SOBEL_FILTER, 3));
	Mat out = applyFilter(img, createFilter(AVG_FILTER, 5));

	showImage(img, "Input image");
	showImage(out, "Filtered image");

	return 0;
}

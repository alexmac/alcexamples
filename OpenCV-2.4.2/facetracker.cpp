#include <Flash++.h>
using namespace AS3::ui;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <math.h>
#include <float.h>
#include <limits.h>
#include <time.h>
#include <ctype.h>
#include "cv.h"

extern "C" char *imageData;
char *imageData = NULL;

int main()
{
	printf("Face Tracker!\n");

	printf("-- Loading Data\n");
	CvHaarClassifierCascade *cascade = (CvHaarClassifierCascade*)cvLoad( "haarcascade_frontalface_alt.xml", 0, 0, 0 );

	if( !cascade ) {
        fprintf( stderr, "ERROR: Could not load classifier cascade\n" );
        return -1;
    }

    printf("-- Createing Mem Storage\n");
    CvMemStorage *storage = cvCreateMemStorage(0);

    printf("-- Creating Image Buffers\n");
    IplImage *frame = cvCreateImage( cvSize(640, 360), IPL_DEPTH_8U, 4 );
    imageData = frame->imageData;
    IplImage *gsframe = cvCreateImage( cvSize(640, 360), IPL_DEPTH_8U, 1 );

    flash::display::Stage stage = internal::get_Stage();
    flash::display::Shape canvas = flash::display::Shape::_new();
    stage->addChild(canvas);
    flash::display::Graphics graphics = canvas->graphics;

    printf("-- Starting Face Detection\n");
	while(true) {
		//printf("Attempting Face detection!\n");
		cvClearMemStorage( storage );
		cvCvtColor(frame, gsframe, CV_BGR2GRAY);
		CvSeq* faces = cvHaarDetectObjects( gsframe, cascade, storage,
                                            1.1, 2, 0,
                                            cvSize(40, 40) );

		graphics->clear();
        for( int i = 0; i < (faces ? faces->total : 0); i++ )
        {
            CvRect* r = (CvRect*)cvGetSeqElem( faces, i );
            graphics->beginFill(0xff0000, 0.5);
			graphics->drawRect(r->x, r->y, r->width, r->height);
			graphics->endFill();
        }
	}
}
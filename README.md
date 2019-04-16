# regionpropsford
Regionprops implementation for dlang

Region Properties, AKA regionprops is a famous routine for calculating region (blob) properties/statistics in image processing/computer vision. The library does not have any dependency except dlang standard library phobos. In theory, the library can be used with any image processing library allowing access to raw image data pointer. Although it has been tested with dlib, you can test it with other libraries such as dcv. Pull requests are welcome for improvements!

Example usage with dlib:
```
  import std.stdio;
  import std.format;
  import dlib.image;

  import measure.regionprops;
  import measure.types;


  void main(){
      auto img = loadImage("test.png");
      auto _imgbin = otsuBinarization(img);

      auto imgbin = Mat2D!ubyte(_imgbin.data, _imgbin.height, _imgbin.width);
      
      // input binary pixels must be 0 for background and 255 for regions
      /* 
      try RegionProps(imgbin, false) if your OS complains about max
      stack size limit. In this way labeling will be done using
      a non-recursive method.
      */
      auto rp = new RegionProps(imgbin);
      rp.calculateProps();
      /+
      now you can access blob properties like:
      rp.regions[0].orientation
      rp.regions[0].majorAxisLength
      rp.regions[3].area
      +/
      auto res = new Image!(PixelFormat.L8)(col_count, row_count);
      res.data[] = imgbin.data[];

      foreach(i, region; rp.regions){ // mark the centroids
          res[region.centroid.x, region.centroid.y] = Color4f(0, 0, 0, 255);
      }
      saveImage(res, "result.png");
  }
  ```
Example usage with [opencvd](https://github.com/aferust/opencvd):
```
import std.stdio;

import opencvd.cvcore;
import opencvd.highgui;
import opencvd.imgcodecs;
import opencvd.imgproc;

import measure.regionprops;
import measure.types;

int main()
{
    Mat img0 = imread("test.png", 0);
    
    Mat img1 = Mat();
    threshold(img0, img1, 200, 255, THRESH_BINARY);
    
    ubyte* rawdata = cast(ubyte*)img1.rawDataPtr();
    
    ubyte[] data = rawdata[0..img1.rows*img1.cols];
    
    auto imgbin = Mat2D!ubyte(data, img0.rows, img0.cols);
    
    auto rp = new RegionProps(imgbin);
    rp.calculateProps();
    
    foreach(region; rp.regions){
        region.orientation.writeln;
        region.majorAxisLength.writeln;
        region.area.writeln;
        region.convexHull.writeln;
    }
    
    waitKey(0);
    return 0;
}
  ```
  
# Currently supported properties:
    
    spatial raw moments:
    double m00, m10, m01, m20, m11, m02, m30, m21, m12, m03;
    
    ulong area;
    double areaFromContour;
    double perimeter;
    Point centroid;
    double aspect_Ratio;
    Rectangle bBox; // bounding box
    XYList convexHull;
    double convexArea;
    Ellipse ellipse;
    double extent;
    double solidity;
    double majorAxisLength;
    double minorAxisLength;
    double orientation;
    double eccentricity;
    double equivalentDiameter;
    XYList contourPixelList; // chain sorted!
    XYList pixelList;

# Python binding
The python binding is based on cython. I know that there is pyd out there.
But I thought it was not mature enough, and decided to do it using cython.

First, build the library using dub, then set the path and the name of 
d's standard library in source/python/setup.py and run:
    python setup.py build_ext --inplace
to build a shared python lib

usage with opencv:
```
    import numpy as np
    import cv2
    import rprops

    imrgb = cv2.imread('test.png');
    img_gray = cv2.cvtColor(imrgb, cv2.COLOR_BGR2GRAY)

    binary = img_gray > 200 # do your thresholding somehow

    # returns a list containing dicts:
    regions = rprops.regionpropsford(binary.astype(np.uint8)) 

    print(regions[0]["Perimeter"])
```
# An example result of the module (images from spyder)
![Alt text](/source/python/doc_images/regions.png?raw=true "regions")
![Alt text](/source/python/doc_images/aregion.png?raw=true "A region with properties")

# Avalable properties (keys of dictionary obj representing a region):

Perimeter
AreaFromContour
Orientation
ConvexHull
Area
Moments
MinorAxis
Solidity
ConvexArea
Eccentricity
ContourPixelList
Centroid
MajorAxis
PixelList
BoundingBox
AspectRatio
EquivalentDiameter
Ellipse


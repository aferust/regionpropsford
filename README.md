# regionpropsford
Regionprops implementation for dlang

The library does not have any dependency except dlang standard library. In theory, the library can be used with any image processing library allowing access to raw image data pointer. Although it has been tested with dlib, you can test it with other libraries such as dcv. Pull requests are welcomed for improvements!

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
Please refer to source/python/setup.py to build and use it with opencv

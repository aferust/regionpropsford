# regionpropsford
Regionprops implementation for dlang

The library does not have any dependency except dlang standard library. In theory, the library can be used with any image processing library allowing access to raw image data pointer. Although it has been tested with dlib, you can test it with other libraries such as dcv. Look at source/types.d -> Region class for supported binary region properties. Pull requests are welcomed for improvements!

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

      auto rp = new RegionProps(imgbin);
      rp.calculateProps();
      /+
      now you can access blob properties like:
      regions[0].orientation
      regions[0].majorAxisLength
      regions[3].area
      +/
      auto res = new Image!(PixelFormat.L8)(col_count, row_count);
      res.data[] = imgbin.data[];

      foreach(i, region; rp.regions){ // mark the centroids
          res[region.centroid.x, region.centroid.y] = Color4f(0, 0, 0, 255);
      }
      saveImage(res, "result.png");
  }
  ```

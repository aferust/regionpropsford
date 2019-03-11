module app;

import std.stdio;
import std.datetime.stopwatch;
import std.format;

import dlib.image;

import measure.regionprops;
import measure.types;

void main(){
    auto img = loadImage("test.png");
    auto _imgbin = otsuBinarization(img);
    
    auto imgbin = Mat2D!ubyte(_imgbin.data, _imgbin.height, _imgbin.width);
    
    auto sw = StopWatch(AutoStart.no);
    sw.start();
    
    auto rp = new RegionProps(imgbin);
    
    rp.calculateProps();
    
    sw.stop(); long msecs = sw.peek.total!"msecs"; float sec = msecs/1000.0f;
    writefln("%f", sec);
    
    auto res = new Image!(PixelFormat.L8)(_imgbin.width, _imgbin.height);
    res.data[] = imgbin.data[];
    foreach(i, region; rp.regions){
        res[region.centroid.x, region.centroid.y] = Color4f(0, 0, 0, 255);
        writeln(region.ellipse);
    }
    saveImage(res, "rrd.png");
    
}


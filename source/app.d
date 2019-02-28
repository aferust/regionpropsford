/*
Copyright (c) 2019- Ferhat Kurtulmuş
Boost Software License - Version 1.0 - August 17th, 2003
Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:
The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/
/*
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
    
    auto res = new Image!(PixelFormat.L8)(col_count, row_count);
    res.data[] = imgbin.data[];
    foreach(i, region; rp.regions){
        res[region.centroid.x, region.centroid.y] = Color4f(0, 0, 0, 255);
    }
    saveImage(res, "rrd.png");
    
    
}
*/

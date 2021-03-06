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

module measure.moments;

import std.math;
import std.typecons;

import measure.types;

void calculateMoments(Region region){
    auto imbin = region.image;

    const XYList xylist = region.pixelList;
    
    double m00 = 0, m10 = 0, m01 = 0, m20 = 0, m11 = 0, m02 = 0, m30 = 0, m21 = 0, m12 = 0, m03 = 0;
    
    m00 = xylist.xs.length;
    
    ulong yGrid;
    ulong xGrid;
    
    foreach(i; 0..imbin.height * imbin.width){
        
        yGrid = i % imbin.width;
        xGrid = i / imbin.width;
        
        m01 += xGrid*(imbin.data[i]/255);
        m10 += yGrid*(imbin.data[i]/255);
        m11 += yGrid*xGrid*(imbin.data[i]/255);
        m02 += (xGrid^^2)*(imbin.data[i]/255);
        m20 += (yGrid^^2)*(imbin.data[i]/255);
        m12 += xGrid*(yGrid^^2)*(imbin.data[i]/255);
        m21 += (xGrid^^2)*yGrid*(imbin.data[i]/255);
        m03 += (xGrid^^3)*(imbin.data[i]/255);
        m30 += (yGrid^^3)*(imbin.data[i]/255);
    }
    
    region.m00 = m00; region.m10 = m10; region.m01 = m01; region.m20 = m20;
    region.m11 = m11; region.m02 = m02; region.m30 = m30; region.m21 = m21;
    region.m12 = m12; region.m03 = m03; 
}

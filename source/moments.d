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

Tuple!(ulong[], ulong[]) grid(uint rows, uint cols){
    ulong[] xGrid; xGrid.length = cols * rows;
    xGrid[0..$] = 0;
    foreach(i; 0..rows)
        foreach(j; 0..cols){
            xGrid[i*cols + j] = i;
        }
    
    ulong[] yGrid; yGrid.length = cols * rows;
    yGrid[0..$] = 0;
    foreach(i; 0..rows)
        foreach(j; 0..cols){
            yGrid[i*cols + j] = j;
        }
    return tuple(xGrid, yGrid);
}

void calculateMoments(Region region){
    // based on: https://github.com/shackenberg/Image-Moments-in-Python
    
    auto imbin = region.image;
    
    XYList xylist = region.pixelList;
    auto mgrid = grid(cast(uint)imbin.height, cast(uint)imbin.width);
    auto xGrid = mgrid[0];
    auto yGrid = mgrid[1];
    
    double m00 = 0, m10 = 0, m01 = 0, m20 = 0, m11 = 0, m02 = 0, m30 = 0, m21 = 0, m12 = 0, m03 = 0;
    double mu20 = 0, mu11 = 0, mu02 = 0, mu30 = 0, mu21 = 0, mu12 = 0, mu03 = 0;
    double mean_x = 0, mean_y = 0;
    double nu20 = 0, nu11 = 0, nu02 = 0, nu30 = 0, nu21 = 0, nu12 = 0, nu03 = 0;
    
    // raw or spatial moments
    m00 = xylist.xs.length;
    
    foreach(i; 0..imbin.height * imbin.width){
        m01 += xGrid[i]*(imbin.data[i]/255);
        m10 += yGrid[i]*(imbin.data[i]/255);
        m11 += yGrid[i]*xGrid[i]*(imbin.data[i]/255);
        m02 += (xGrid[i]^^2)*(imbin.data[i]/255);
        m20 += (yGrid[i]^^2)*(imbin.data[i]/255);
        m12 += xGrid[i]*(yGrid[i]^^2)*(imbin.data[i]/255);
        m21 += (xGrid[i]^^2)*yGrid[i]*(imbin.data[i]/255);
        m03 += (xGrid[i]^^3)*(imbin.data[i]/255);
        m30 += (yGrid[i]^^3)*(imbin.data[i]/255);
    }
    
    // central moments
    mean_x = m01/m00;
    mean_y = m10/m00;
    
    foreach(i; 0..imbin.height * imbin.width){ // for now, an extra loop is required here
        mu11 += (xGrid[i] - mean_x) * (yGrid[i] - mean_y)*(imbin.data[i]/255);
        mu02 += ((yGrid[i] - mean_y)^^2)*(imbin.data[i]/255);
        mu20 += ((xGrid[i] - mean_x)^^2)*(imbin.data[i]/255);
        mu12 += (xGrid[i] - mean_x) * ((yGrid[i] - mean_y)^^2)*(imbin.data[i]/255);
        mu21 += ((xGrid[i] - mean_x)^^2) * (yGrid[i] - mean_y)*(imbin.data[i]/255);
        mu03 += ((yGrid[i] - mean_y)^^3)*(imbin.data[i]/255);
        mu30 += ((xGrid[i] - mean_x)^^3)*(imbin.data[i]/255);
    }
    
    // central standardized or normalized or scale invariant moments
    nu11 = mu11 / m00^^(2);
    nu12 = mu12 / m00^^(2.5);
    nu21 = mu21 / m00^^(2.5);
    nu20 = mu20 / m00^^(2);
    nu03 = mu03 / m00^^(2.5); // skewness
    nu30 = mu30 / m00^^(2.5); // skewness
    
    region.m00 = m00; region.m10 = m10; region.m01 = m01; region.m20 = m20;
    region.m11 = m11; region.m02 = m02; region.m30 = m30; region.m21 = m21;
    region.m12 = m12; region.m03 = m03; 
    
    region.mu20 = mu20; region.mu11 = mu11; region.mu02 = mu02;
    region.mu30 = mu30; region.mu21 = mu21; region.mu12 = mu12; region.mu03 = mu03;
    region.nu20 = nu20; region.nu11 = nu11; region.nu02 = nu02;
    region.nu30 = nu30; region.nu21 = nu21; region.nu12 = nu12; region.nu03 = nu03;
}

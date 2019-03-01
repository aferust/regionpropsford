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

module measure.regionprops;

import std.stdio;
import std.math;
import std.typecons;
import std.array;
import std.algorithm;

import measure.types;
import measure.chull;



private
{
    alias DfsFun = void function(size_t, size_t, ubyte, ubyte[], Mat2D!ubyte);
    size_t row_count;
    size_t col_count;
}


immutable int[4] dx4 = [1, 0, -1,  0];
immutable int[4] dy4 = [0, 1,  0, -1];

immutable int[8] dx8 = [1, -1, 1, 0, -1,  1,  0, -1];
immutable int[8] dy8 = [0,  0, 1, 1,  1, -1, -1, -1];

private void dfs4(size_t x, size_t y, ubyte current_label, ubyte[] label, Mat2D!ubyte img) @nogc
{
    if (x < 0 || x == row_count) return;
    if (y < 0 || y == col_count) return;
    if (label[x*col_count + y] || !img.data[x*col_count + y]) return;
    
    label[x*col_count + y] = current_label;
    
    foreach(direction; 0..4)
        dfs4(x + dx4[direction], y + dy4[direction], current_label, label, img);
}

private void dfs8(size_t x, size_t y, ubyte current_label, ubyte[] label, Mat2D!ubyte img) @nogc
{
    if (x < 0 || x == row_count) return;
    if (y < 0 || y == col_count) return;
    if (label[x*col_count + y] || !img.data[x*col_count + y]) return;
    
    label[x*col_count + y] = current_label;

    foreach(direction; 0..8)
        dfs8(x + dx8[direction], y + dy8[direction], current_label, label, img);
}

Mat2D!ubyte bwlabel(Mat2D!ubyte img, uint conn = 8)
{
    /* The algorithm is based on:
     * https://stackoverflow.com/questions/14465297/connected-component-labelling
     */
    
    row_count = img.height;
    col_count = img.width;
    
    auto label = uninitializedArray!(ubyte[])(row_count*col_count);
    auto res = Mat2D!ubyte(row_count, col_count);
    
    DfsFun dfs;
    
    if(conn == 4)
        dfs = &dfs4;
    else
        dfs = &dfs8;
    
    ubyte component = 0;
    foreach (i; 0..row_count) 
        foreach (j; 0..col_count)
            if (!label[i*col_count + j] && img.data[i*col_count + j]) dfs(i, j, ++component, label, img);
    
    // the number of blobs is "label.maxElement"
    
    res.data[] = label[];
    return res;     
}

XYList bin2coords(Mat2D!ubyte img)
{
    size_t rc = img.height;
    size_t cc = img.width;
    
    XYList coords;
    
    foreach (i; 0..rc) 
        foreach (j; 0..cc)
            if(img.data[i*cc + j] == 255)
            {
                    coords.xs ~= cast(int)j;
                    coords.ys ~= cast(int)i;
            }
    
    return coords;
}

Mat2D!ubyte coords2mat(XYList xylist, Rectangle rect)
{
    auto im = Mat2D!ubyte(rect.height, rect.width);
    
    auto n = xylist.xs.length;
    
    foreach(i; 0..n)
    {
        im[xylist.ys[i]-rect.y, xylist.xs[i]-rect.x] = 255;
    }
    return im;   
}

private void _setValAtIdx_with_padding(Mat2D!ubyte img, XYList xylist, int val, int pad = 2)@nogc
{
    foreach (i; 0..xylist.xs.length)
        img[xylist.ys[i]+pad/2, xylist.xs[i]+pad/2] = cast(ubyte)val;
}


XYList
getContinousBoundaryPoints( Mat2D!ubyte unpadded)
{
    // https://www.codeproject.com/Articles/1105045/Tracing-Boundary-in-D-Image-Using-Moore-Neighborho
    // https://www.codeproject.com/info/cpol10.aspx
    // author Udaya K Unnikrishnan
    auto _rows = unpadded.height;
    auto _cols = unpadded.width;
    int pad = 2;
    
    auto region = Mat2D!ubyte(_rows + pad, _cols + pad);
    XYList coords = bin2coords(unpadded);
    _setValAtIdx_with_padding(region, coords, 255);
    
    Point[] BoundaryPoints;
    int Width_i = cast(int)region.width;
    int Height_i = cast(int)region.height;
    ubyte[] InputImage = region.data;
    if( InputImage !is null)
    {
        
        
        int nImageSize = Width_i * Height_i;
        
        int[][] Offset = [
                            [ -1, -1 ],
                            [  0, -1 ], 
                            [  1, -1 ],  
                            [  1,  0 ], 
                            [  1,  1 ],
                            [  0,  1 ], 
                            [ -1,  1 ],
                            [ -1,  0 ]
        ];
        
        const int NEIGHBOR_COUNT = 8;
        auto BoundaryPixelCord = Point(0, 0);
        auto BoundaryStartingPixelCord = Point(0, 0);
        auto BacktrackedPixelCord = Point(0, 0);
        int[][] BackTrackedPixelOffset = [ [0,0] ];
        bool bIsBoundaryFound = false;
        bool bIsStartingBoundaryPixelFound = false;
        for(int Idx = 0; Idx < nImageSize; ++Idx ) // getting the starting pixel of boundary
        {
            if( 0 != InputImage[Idx] )
            {
                BoundaryPixelCord.x = Idx % Width_i;
                BoundaryPixelCord.y = Idx / Width_i;
                BoundaryStartingPixelCord = BoundaryPixelCord;
                BacktrackedPixelCord.x = ( Idx - 1 ) % Width_i;
                BacktrackedPixelCord.y = ( Idx - 1 ) / Width_i;
                BackTrackedPixelOffset[0][0] = BacktrackedPixelCord.x - BoundaryPixelCord.x;
                BackTrackedPixelOffset[0][1] = BacktrackedPixelCord.y - BoundaryPixelCord.y;
                BoundaryPoints ~= BoundaryPixelCord;
                bIsStartingBoundaryPixelFound = true;
                break;
            }            
        }
        auto CurrentBoundaryCheckingPixelCord = Point(0, 0);
        auto PrevBoundaryCheckingPixxelCord = Point(0, 0);
        if( !bIsStartingBoundaryPixelFound )
        {
            BoundaryPoints.length--;
        }
        while( true && bIsStartingBoundaryPixelFound )
        {
            int CurrentBackTrackedPixelOffsetInd = -1;
            foreach( int Ind; 0..NEIGHBOR_COUNT )
            {
                if( BackTrackedPixelOffset[0][0] == Offset[Ind][0] &&
                    BackTrackedPixelOffset[0][1] == Offset[Ind][1] )
                {
                    CurrentBackTrackedPixelOffsetInd = Ind;// Finding the bracktracked 
                                                           // pixel's offset index
                    break;
                }
            }
            int Loop = 0;
            while( Loop < ( NEIGHBOR_COUNT - 1 ) && CurrentBackTrackedPixelOffsetInd != -1 )
            {
                int OffsetIndex = ( CurrentBackTrackedPixelOffsetInd + 1 ) % NEIGHBOR_COUNT;
                CurrentBoundaryCheckingPixelCord.x = BoundaryPixelCord.x + Offset[OffsetIndex][0];
                CurrentBoundaryCheckingPixelCord.y = BoundaryPixelCord.y + Offset[OffsetIndex][1];
                int ImageIndex = CurrentBoundaryCheckingPixelCord.y * Width_i + 
                                    CurrentBoundaryCheckingPixelCord.x;
                
                if( 0 != InputImage[ImageIndex] )// finding the next boundary pixel
                {
                    BoundaryPixelCord = CurrentBoundaryCheckingPixelCord; 
                    BacktrackedPixelCord = PrevBoundaryCheckingPixxelCord;
                    BackTrackedPixelOffset[0][0] = BacktrackedPixelCord.x - BoundaryPixelCord.x;
                    BackTrackedPixelOffset[0][1] = BacktrackedPixelCord.y - BoundaryPixelCord.y;
                    BoundaryPoints ~= BoundaryPixelCord;
                    break;
                }
                PrevBoundaryCheckingPixxelCord = CurrentBoundaryCheckingPixelCord;
                CurrentBackTrackedPixelOffsetInd += 1;
                Loop++;
            }
            if( BoundaryPixelCord.x == BoundaryStartingPixelCord.x &&
                BoundaryPixelCord.y == BoundaryStartingPixelCord.y ) // if the current pixel = 
                                                                     // starting pixel
            {
                BoundaryPoints.length--;
                bIsBoundaryFound = true;
                break;
            }
        }
        if( !bIsBoundaryFound ) // If there is no connected boundary clear the list
        {
            BoundaryPoints.length=0;
        }
    }
    XYList xys;
    foreach(i; 0..BoundaryPoints.length){
        xys.xs ~= BoundaryPoints[i].x - pad/2;
        xys.ys ~= BoundaryPoints[i].y - pad/2;
    }
    return xys;
}

double contourArea(XYList xylist) @nogc
{
    auto npoints = xylist.xs.length;
    auto xx = xylist.xs;
    auto yy = xylist.ys;
    
    double area = 0.0;
    
    foreach(i; 0..npoints){
        auto j = (i + 1) % npoints;
        area += xx[i] * yy[j];
        area -= xx[j] * yy[i];
    }
    area = abs(area) / 2.0;
    return area;
}

double arcLength(XYList xylist) @nogc
{
    double perimeter = 0.0, xDiff = 0.0, yDiff = 0.0;
    for( auto k = 0; k < xylist.xs.length-1; k++ ) {
        xDiff = xylist.xs[k+1] - xylist.xs[k];
        yDiff = xylist.ys[k+1] - xylist.ys[k];
        perimeter += pow( xDiff*xDiff + yDiff*yDiff, 0.5 );
    }
    xDiff = xylist.xs[xylist.xs.length-1] - xylist.xs[0];
    yDiff = xylist.ys[xylist.xs.length-1] - xylist.ys[0];
    perimeter += pow( xDiff*xDiff + yDiff*yDiff, 0.5 );
    
    return perimeter;
}

Rectangle boundingBox(XYList xylist) @nogc
{
    int minx = xylist.xs.minElement;
    int miny = xylist.ys.minElement;
    int width = xylist.xs.maxElement - xylist.xs.minElement + 1;
    int height = xylist.ys.maxElement - xylist.ys.minElement + 1;
    
    Rectangle rect = {x: minx, y: miny, width: width, height: height};
    return rect;
}

Tuple!(Rectangle[], XYList[])
bboxesAndIdxFromLabelImage(Mat2D!ubyte labelIm)
{
    auto rc = labelIm.height;
    auto cc = labelIm.width;
    
    immutable int ncomps = labelIm.data.maxElement;
    
    XYList[] segmentedImgIdx;
    segmentedImgIdx.length = ncomps;
    
    foreach (i; 0..rc) 
        foreach (j; 0..cc)
            foreach(label; 0..ncomps){
                if(labelIm.data[i*cc + j] == label+1){
                    segmentedImgIdx[label].xs ~= cast(uint)j;
                    segmentedImgIdx[label].ys ~= cast(uint)i;
                }
            }
    Rectangle[] rects; rects.length = ncomps;
    foreach(i; 0..ncomps)
        rects[i] = boundingBox(segmentedImgIdx[i]);
    
    return tuple(rects, segmentedImgIdx);
}

Mat2D!ubyte idxListToSubImage(Rectangle rect, XYList idxlist)
{
    
    auto res = Mat2D!ubyte(rect.height, rect.width);
    
    int yOffset = rect.y;
    int xOffset = rect.x;
    
    foreach(i; 0..idxlist.xs.length)
        res[idxlist.ys[i]-yOffset, idxlist.xs[i]-xOffset] = 255;
    
    return res;
    
}

Mat2D!ubyte subImage(Mat2D!ubyte img, Rectangle ROI)
{
    //this copies vals for new image :(
    auto cc =img.width;
    auto subIm = Mat2D!ubyte(ROI.height, ROI.width);
    ubyte* ptr = subIm.data.ptr;
    
    foreach (int i; ROI.y..ROI.y+ROI.height) 
        foreach (int j; ROI.x..ROI.x+ROI.width)
        {
            *ptr = img.data[i*cc + j];
            ptr ++;
        }
    
    return subIm;
}

private void setValAtIdx(T)(Mat2D!T img, XYList xylist, T val) @nogc
{
    foreach (i; 0..xylist.xs.length)
        img[xylist.ys[i], xylist.xs[i]] = val;
}

void addXYOffset(ref XYList xylist, int xOffset, int yOffset) @nogc
{
    auto npoints = xylist.xs.length;
    foreach(i; 0..npoints)
    {
        xylist.xs[i] += xOffset;
        xylist.ys[i] += yOffset;
    }
}

import measure.chull;
import measure.ellipsefit;
import measure.moments;

class RegionProps
{
    /* test it like:
    auto img = loadImage("test.png");
    auto imgbin = otsuBinarization(img);
    
    auto rp = new RegionProps(imgbin);
    rp.calculateProps();
    
    foreach(i, region; rp.regions){
        imgbin[region.centroid.x, region.centroid.y] = Color4f(0, 0, 0, 255);
        
    }
    */
    Region[] regions;
    Mat2D!ubyte parentBin;
    Mat2D!ubyte labelIm;
    
    size_t parentHeight;
    size_t parentWidth;
    
    Rectangle[] bboxes;
    XYList[] coords;
    
    size_t count = 0;
    
    this(Mat2D!ubyte imbin)
    {
        parentHeight = imbin.height;
        parentWidth = imbin.width;
        
        parentBin = imbin;
        
        labelIm = bwlabel(parentBin);
        
        auto _tupBboxesAndIdx = bboxesAndIdxFromLabelImage(labelIm);
        bboxes = _tupBboxesAndIdx[0];
        coords = _tupBboxesAndIdx[1];
        
        count = bboxes.length;
        
        regions.length = count;
    }
    
    void calculateProps()
    {
        foreach(i; 0..count)
        {
            Region region = new Region();
            region.bBox = bboxes[i];
            Mat2D!ubyte imsub = idxListToSubImage(bboxes[i],coords[i]);
            
            auto contourIdx_sorted = getContinousBoundaryPoints(imsub);
            
            addXYOffset(contourIdx_sorted, region.bBox.x, region.bBox.y);
            
            region.image = imsub;
            
            region.aspect_Ratio = region.bBox.width / cast(double)region.bBox.height;
            region.extent = cast(double)region.area/(region.bBox.width*region.bBox.height);
            
            region.perimeter = arcLength(contourIdx_sorted); // holes are ignored
            region.areaFromContour = contourArea(contourIdx_sorted); // holes are ignored
            region.area = coords[i].xs.length;
            region.pixelList = coords[i];
            
            
            region.contourPixelList = contourIdx_sorted;
            
            calculateMoments(region);
            
            // centroid is computed correctly, so we ensure that raw moments are correct
            region.centroid = Point(cast(int)round(region.m10/region.m00) + region.bBox.x + 1,
                                    cast(int)round(region.m01/region.m00) + region.bBox.y + 1);
            /* or region.centroid = Point(cast(int)round(mean(coords[i].xs)) + 1,
                                    cast(int)round(mean(coords[i].ys)) + 1); */
            
            region.equivalentDiameter = sqrt(4*region.area/PI);
            
            region.ellipse = ellipseFit(region.pixelList);
            
            region.orientation = region.ellipse.angle;
            
            region.majorAxisLength = region.ellipse.maj;
            region.minorAxisLength = region.ellipse.min; 
            
            region.eccentricity = sqrt(1.0 - (region.minorAxisLength / region.majorAxisLength)^^2);
            
            region.convexHull = convexHull(region.contourPixelList);
            region.convexArea = contourArea(region.convexHull);
            region.solidity = region.area / region.convexArea;
            
            regions[i] = region;
            
        }
    }
}

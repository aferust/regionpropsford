module rpcinterface;

import std.stdio;

import measure.regionprops;
import measure.types;
import core.stdc.stdlib;

private {
    RegionProps rp;
}

extern (C) void _rprops(ubyte* _data, uint rows, uint cols, ulong *n) { 
    ubyte[] data = _data[0..rows*cols];
    
    auto imgbin = Mat2D!ubyte(data, rows, cols);
    rp = new RegionProps(imgbin);
    rp.calculateProps();
    *n = rp.regions.length;
}

extern (C) {
    ulong getArea(ulong i){ return rp.regions[i].area;}
    void getRawMoments(ulong i, double[10] m){
        m = [rp.regions[i].m00, 
            rp.regions[i].m10, 
            rp.regions[i].m01, 
            rp.regions[i].m20, 
            rp.regions[i].m11,
            rp.regions[i].m02,
            rp.regions[i].m30,
            rp.regions[i].m21,
            rp.regions[i].m12, 
            rp.regions[i].m03];
    }
    double getAreaFromContour(ulong i){return rp.regions[i].areaFromContour;}
    double getPerimeter(ulong i){return rp.regions[i].perimeter;}
    void getCentroid(ulong i, double[2] centroid){
        centroid = [rp.regions[i].centroid.x, rp.regions[i].centroid.y];
    }
    double getAspect_Ratio(ulong i){return rp.regions[i].aspect_Ratio;}
    void getBbox(ulong i, double[4] bBox){
        bBox = [rp.regions[i].bBox.x, rp.regions[i].bBox.y, rp.regions[i].bBox.width, rp.regions[i].bBox.height];
    }
    
    ulong getChLen(ulong i){return rp.regions[i].convexHull.xs.length;}
    void getConvh(ulong i, int *convhXs, int *convhYs){
        auto n = rp.regions[i].convexHull.xs.length;
        convhXs[0..n] = rp.regions[i].convexHull.xs[];
        convhYs[0..n] = rp.regions[i].convexHull.ys[];
    }
    
    double getConvexArea(ulong i) {return rp.regions[i].convexArea;}
    void getEllipse(ulong i, double[5] ellipse){
        ellipse = [rp.regions[i].ellipse.angle,
                rp.regions[i].ellipse.center_x,
                rp.regions[i].ellipse.center_y,
                rp.regions[i].ellipse.maj,
                rp.regions[i].ellipse.min];
    }
    double getExtent(ulong i){return rp.regions[i].extent; }
    double getSolidity(ulong i){return rp.regions[i].solidity; }
    double getMajorAxisLength(ulong i){return rp.regions[i].majorAxisLength; }
    double getMinorAxisLength(ulong i){return rp.regions[i].minorAxisLength; }
    double getOrientation(ulong i){return rp.regions[i].orientation; }
    double getEccentricity(ulong i){return rp.regions[i].eccentricity; }
    double getEquivalentDiameter(ulong i){return rp.regions[i].equivalentDiameter; }
    
    ulong getConPxLen(ulong i){return rp.regions[i].contourPixelList.xs.length;}
    void getContourPixelList(ulong i, int *contXs, int *contYs){
        auto n = rp.regions[i].contourPixelList.xs.length;
        contXs[0..n] = rp.regions[i].contourPixelList.xs[];
        contYs[0..n] = rp.regions[i].contourPixelList.ys[];
    }
    
    ulong getPxLen(ulong i){return rp.regions[i].pixelList.xs.length;}
    void getPixelList(ulong i, int *pixXs, int *pixYs){
        auto n = rp.regions[i].pixelList.xs.length;
        pixXs[0..n] = rp.regions[i].pixelList.xs[];
        pixYs[0..n] = rp.regions[i].pixelList.ys[];
    }
}

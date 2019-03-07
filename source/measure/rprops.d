module rprops;

import std.stdio;

import measure.regionprops;
import measure.types;

extern (C) void _rprops(ubyte* _data, uint rows, uint cols) { 
    ubyte[] data = _data[0..rows*cols];
    
    auto imgbin = Mat2D!ubyte(data, rows, cols);
    auto rp = new RegionProps(imgbin);
    
    rp.calculateProps();
    writeln("hello");
    writeln(rp.regions[0].centroid);
}

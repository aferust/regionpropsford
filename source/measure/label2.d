module measure.label2;
import measure.types;

import std.stdio;
import std.array;
import std.algorithm.iteration;
import std.algorithm;
import std.typecons;

/* The algorithm is based on:
 * https://stackoverflow.com/questions/14465297/connected-component-labelling
 */
private
{
    alias UnionFun4Conn = void function(int x, int y);
    Mat2D!ubyte input;
    size_t w, h;
    uint[] component;
}

private void doUnion(uint a, uint b)
{
    while (component[a] != a)
        a = component[a];
    while (component[b] != b)
        b = component[b];
    component[b] = a;
}

private void unionCoords(int x, int y, int x2, int y2)
{
    if (y2 < h && x2 < w && input[x, y] && input[x2, y2])
        doUnion(cast(uint)(x*h + y), cast(uint)(x2*h + y2));
}

private void conn8Fun(int x, int y)
{
    unionCoords(x, y, x+1, y);
    unionCoords(x, y, x, y+1);
    unionCoords(x, y, x+1, y+1);
}

private void conn4Fun(int x, int y)
{
    unionCoords(x, y, x+1, y);
    unionCoords(x, y, x, y+1);
}

XYList[] bwlabel2(Mat2D!ubyte img, bool conn8 = true)
{
    // gives coordinates of connected components
    XYList[] coords;
    
    input = img;
    
    h = img.width;
    w = img.height;
    
    component = new uint[w*h];
    
    UnionFun4Conn uFun;
    if(conn8)
        uFun = &conn8Fun;
    else
        uFun = &conn4Fun;
    
    for (int i = 0; i < w*h; i++)
        component[i] = i;
    for (int x = 0; x < w; x++)
    for (int y = 0; y < h; y++)
        uFun(x, y);
    
    XYList[uint] pmap;
    
    for (int x = 0; x < w; x++)
    {
        for (int y = 0; y < h; y++)
        {
            if (input[x, y] == 0)
            {
                continue;
            }
            uint c = cast(uint)(x*h + y);
            while (component[c] != c) c = component[c];
            
            if(c !in pmap)
            {
                XYList tmp;
                tmp.xs ~= y;
                tmp.ys ~= x;
                pmap[c] = tmp;
            }else{
                pmap[c].xs ~= y;
                pmap[c].ys ~= x;
            }

            
        }
    }
    
    foreach(key; pmap.keys)
    {
        coords ~= pmap[key];
    }
    
    return coords;
}

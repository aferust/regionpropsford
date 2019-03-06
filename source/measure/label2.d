module measure.label2;
import measure.types;

import std.stdio;
import std.array;
import std.algorithm.iteration;
import std.algorithm;
import std.typecons;

/* The algorithm is based on:
 * https://stackoverflow.com/questions/14465297/connected-component-labelling
 * 
 * this is not as efficient as bwlabel with its current implementation
 */

Mat2D!ubyte input;

size_t w, h;

uint[] component;

void doUnion(uint a, uint b)
{
    while (component[a] != a)
        a = component[a];
    while (component[b] != b)
        b = component[b];
    component[b] = a;
}

void unionCoords(int x, int y, int x2, int y2)
{
    if (y2 < h && x2 < w && input[x, y] && input[x2, y2])
        doUnion(cast(uint)(x*h + y), cast(uint)(x2*h + y2));
}

Mat2D!uint bwlabel2(Mat2D!ubyte img)
{
    Rectangle[] bboxes;
    XYList[] coords;
    
    input = img;
    
    h = img.width;
    w = img.height;
    
    component = new uint[w*h];
    
    for (int i = 0; i < w*h; i++)
        component[i] = i;
    for (int x = 0; x < w; x++)
    for (int y = 0; y < h; y++)
    {
        unionCoords(x, y, x+1, y);
        unionCoords(x, y, x, y+1);
        unionCoords(x, y, x+1, y+1);
        
    }
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
    auto res = Mat2D!uint(w, h);
    foreach(lbl, key; pmap.keys)
    {
        XYList points = pmap[key];
        foreach(i; 0..points.xs.length)
            res[points.ys[i], points.xs[i]] = cast(uint)(lbl + 1);
        
    }
    
    return res;
}

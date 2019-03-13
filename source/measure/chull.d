module measure.chull;

import std.algorithm;
import std.algorithm.sorting;
import std.stdio;
import std.math;

import measure.types;
import measure.regionprops;

/* https://rosettacode.org/wiki/Convex_hull 
   https://www.gnu.org/licenses/fdl-1.2.html
*/

XYList convexHull(XYList _p) {
    const auto n = _p.xs.length;
    assert( n >= 3, "Convex hull not possible");
    
    Point[] p; p.length = n; foreach(i; 0..n) p[i] = Point(_p.xs[i], _p.ys[i]);
    p.sort();
    Point[] h;
 
    // lower hull
    foreach (pt; p) {
        while (h.length >= 2 && !ccw(h[$-2], h[$-1], pt)) {
            h.length--;
        }
        h ~= pt;
    }
 
    // upper hull
    const auto t = h.length + 1;
    foreach_reverse (i; 0..(p.length - 1)) {
        auto pt = p[i];
        while (h.length >= t && !ccw(h[$-2], h[$-1], pt)) {
            h.length--;
        }
        h ~= pt;
    }
 
    h.length--;
    
    XYList xys;
    foreach(i; 0..h.length)
    {
        xys.xs ~= h[i].x;
        xys.ys ~= h[i].y;
    }
    return xys;
}
 
/* ccw returns true if the three points make a counter-clockwise turn */
auto ccw(Point a, Point b, Point c) @nogc {
    return ((b.x - a.x) * (c.y - a.y)) > ((b.y - a.y) * (c.x - a.x));
}


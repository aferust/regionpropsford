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

module measure.ellipsefit;

import std.stdio;
import std.math;
import std.range;
import std.algorithm;
import std.algorithm.searching;

import measure.types;
import measure.regionprops;
import measure.eigen;

Ellipse ellipseFit(XYList xylist)
{
    double meanX = xylist.xs.mean;
    double meanY = xylist.ys.mean;
    
    auto cov = covNx2(xylist.xs, xylist.ys);

    auto eigSolver = new Eig(cov);
    auto V = eigSolver.getV();
    auto lambda = eigSolver.getD();
    
    auto lambda_d = lambda.diag();
    foreach(ref val; lambda_d) val = 4*sqrt(val);
    
    double minorAxisLength = minElement(lambda_d);
    auto minor_idx = minIndex(lambda_d);
    double majorAxisLength = maxElement(lambda_d);
    auto major_idx = maxIndex(lambda_d);
    
    
    double[2] major_vec = [V[1, major_idx], V[0, major_idx]] ;
    
    double orientation;
    if (majorAxisLength == minorAxisLength)
      orientation = 0;
    else if (major_vec[1] == 0)
      orientation = 90;
    else
      orientation = -(180/PI) * atan (major_vec[0] / major_vec[1]);
    
    return Ellipse(orientation, meanX + 1, meanY + 1, majorAxisLength, minorAxisLength);
}

Mat2D!double covNx2(U)(U[] xs, U[] ys)
{
    int npoints = cast(int)xs.length;
    int _npoints = cast(int)ys.length;
    
    assert(npoints == _npoints, "array sizes are mismatch!");
    
    auto _cov = Mat2D!double(npoints, 2);
    
    double meanX = xs.mean;
    double meanY = ys.mean;
    
    foreach(i; 0..npoints)
    {
        _cov[i, 0] = xs[i] - meanX;
        _cov[i, 1] = ys[i] - meanY;
    }
    
    auto rescov = _cov.transpose() * _cov;
    double[] d; d.length = 2; d[0..$] = 1.0/12;
    
    auto covv = Mat2D!double.diagFromArray(d);
    
    for(size_t i = 0; i < covv.rows; i++)
        for(size_t j = 0; j < covv.cols; j++)
        {
            rescov[i, j] = rescov[i, j] * (1.0/cast(double)npoints);
            rescov[i, j] = rescov[i, j] + covv[i, j];
        }
    return rescov;
}
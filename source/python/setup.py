# setup.py
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
import numpy

"""
The python binding is based on cython. I know that there is pyd out there.
But I thought it was not mature enough, and decided to do it using cython.

First, build the library using dub, then set the path and the name of 
d's standard library and run:
    python setup.py build_ext --inplace
to build a shared python lib
"""
phobos_lib_dir = "D:/msys64/home/user/dlang/ldc2-d4858cfb-windows-x64/lib"
phobos_lib = "phobos2-ldc"
druntime_or_pthread_for_linux_lib = "druntime-ldc"

""" you need to set nothing below hopefully :) """
setup(
    name='rprops',
    ext_modules=[
        Extension(
            "rprops",
            ["rprops_.pyx", "rprops.c"],
            include_dirs=[numpy.get_include()],
            libraries=["regionpropsford", phobos_lib, druntime_or_pthread_for_linux_lib],
            library_dirs=["../../", phobos_lib_dir],
            extra_compile_args=["-O2", "-O3"],
        )
    ],
    cmdclass = {'build_ext': build_ext}
)

"""
usage with opencv:

import numpy as np
import cv2
import rprops

imrgb = cv2.imread('test.png');
img_gray = cv2.cvtColor(imrgb, cv2.COLOR_BGR2GRAY)

binary = img_gray > 200 # do your thresholding somehow

# returns a list containing dicts:
regions = rprops.regionpropsford(binary.astype(np.uint8)) 

print(regions[0]["Perimeter"])

avalable props (keys of dictionary obj representing a region):

Perimeter
AreaFromContour
Orientation
ConvexHull
Area
Moments
MinorAxis
Solidity
ConvexArea
Eccentricity
ContourPixelList
Centroid
MajorAxis
PixelList
BoundingBox
AspectRatio
EquivalentDiameter
Ellipse

"""

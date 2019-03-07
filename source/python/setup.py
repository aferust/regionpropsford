# setup.py
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
import numpy

"""
set below paths 
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

rprops.regionpropsford(binary.astype(np.uint8))

"""
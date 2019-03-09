import numpy as np
cimport numpy as np
import cython
import ctypes
from libc.stdlib cimport malloc, free

cdef extern from "rprops.h":
    void crprops(unsigned char* arrayPtr, unsigned int rows, unsigned int cols, unsigned long *n)
    void initRprops()
    void deinitRprops()
    long getArea(unsigned long i)
    void getRawMoments(unsigned long i, double m[10])
    double getAreaFromContour(unsigned long i)
    double getPerimeter(unsigned long i)
    void getCentroid(unsigned long i, double centroid[2])
    double getAspect_Ratio(unsigned long i)
    void getBbox(unsigned long i, double bBox[4])
    unsigned long getChLen(unsigned long i);
    void getConvh(unsigned long i, int *convhXs, int *convhYs)
    double getConvexArea(unsigned long i)
    void getEllipse(unsigned long i, double ellipse[5])
    double getExtent(unsigned long i)
    double getSolidity(unsigned long i)
    double getMajorAxisLength(unsigned long i)
    double getMinorAxisLength(unsigned long i)
    double getOrientation(unsigned long i)
    double getEccentricity(unsigned long i)
    double getEquivalentDiameter(unsigned long i)
    unsigned long getConPxLen(unsigned long i)
    void getContourPixelList(unsigned long i, int *contXs, int *contYs)
    unsigned long getPxLen(unsigned long i)
    void getPixelList(unsigned long i, int *pixXs, int *pixYs)
    #list arrayToList(int* array, unsigned long n)

@cython.boundscheck(False)
@cython.wraparound(False)
cdef np.ndarray[np.int_t, ndim=2, mode="c"] ptr2np(int *px, int *py, unsigned long n):
    cdef int i
    cdef np.ndarray[np.int_t, ndim=2, mode="c"] n2d = np.zeros((n, 2), dtype=np.int)
    with nogil:
        for i in range(n):
            n2d[i,0]= px[i]
            n2d[i,1]= py[i]
    return n2d

@cython.boundscheck(False)
@cython.wraparound(False)
cpdef regionpropsford(np.ndarray[np.uint8_t, ndim=2, mode="c"] nummat):
    #initRprops() # not sure if needed. life is good so far without this
    
    cdef double bBox[4]
    cdef double mom[10]
    cdef double ellipse[5]
    cdef double centroid[2]
    cdef unsigned int i
    cdef unsigned long n, nch, npx, cnpx
    cdef int* convhXs
    cdef int* convhYs
    cdef int* pixXs
    cdef int* pixYs
    cdef int* contXs
    cdef int* contYs
    
    crprops(&nummat[0,0], nummat.shape[0], nummat.shape[1], &n)
    
    regions = []
    
    for i in range(n):
        nch = getChLen(i)
        convhXs = <int*>malloc(nch * sizeof(int))
        convhYs = <int*>malloc(nch * sizeof(int))
        
        npx = getPxLen(i)
        pixXs = <int*>malloc(npx * sizeof(int))
        pixYs = <int*>malloc(npx * sizeof(int))
        
        cnpx = getConPxLen(i)
        contXs = <int*>malloc(cnpx * sizeof(int))
        contYs = <int*>malloc(cnpx * sizeof(int))
        
        getBbox(i, bBox)
        getRawMoments(i, mom)
        getEllipse(i, ellipse)
        getCentroid(i, centroid)
        getConvh(i, convhXs, convhYs)
        getPixelList(i, pixXs, pixYs)
        getContourPixelList(i, contXs, contYs)
        
        m_dict = {
            "Area": getArea(i),
            "Perimeter": getPerimeter(i),
            "BoundingBox": {"x":bBox[0], "y":bBox[1], "height":bBox[3], "width":bBox[2]},
            "Moments": {
                        "m00": mom[0],
                        "m10": mom[1],
                        "m01": mom[2],
                        "m20": mom[3],
                        "m11": mom[4],
                        "m02": mom[5],
                        "m30": mom[6],
                        "m21": mom[7],
                        "m12": mom[8],
                        "m03": mom[9]
            },
            "ConvexHull": ptr2np(convhXs, convhYs, nch),
            "ConvexArea": getConvexArea(i),
            "Ellipse": {"Angle": ellipse[0],
                        "Center_x": ellipse[1], 
                        "Center_y": ellipse[2],
                        "major": ellipse[3],
                        "minor": ellipse[4],
            },
            "Orientation": getOrientation(i),
            "MinorAxis": getMinorAxisLength(i),
            "MajorAxis": getMajorAxisLength(i),
            "Centroid": {"x": centroid[0], "y": centroid[1] },
            "AspectRatio": getAspect_Ratio(i),
            "EquivalentDiameter": getEquivalentDiameter(i),
            "Eccentricity": getEccentricity(i),
            "AreaFromContour": getAreaFromContour(i),
            "PixelList": ptr2np(pixXs, pixYs, npx),
            "ContourPixelList": ptr2np(contXs, contYs, cnpx),
            "Solidity": getSolidity(i)
        }
        
        regions.append(m_dict)
    free(convhXs)
    free(convhYs)
    free(pixXs)
    free(pixYs)
    free(contXs)
    free(contYs)
    #deinitRprops() # not sure if needed
    
    return regions

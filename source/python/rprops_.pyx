import numpy as np
cimport numpy as np
import cython
import ctypes

cdef extern from "rprops.h":
    void crprops(unsigned char* arrayPtr, unsigned int rows, unsigned int cols)

@cython.boundscheck(False)
@cython.wraparound(False)
def regionpropsford(np.ndarray[np.uint8_t, ndim=2, mode="c"] nummat):
    crprops(&nummat[0,0], nummat.shape[0], nummat.shape[1]) 
    return None
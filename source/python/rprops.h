
extern long getArea(unsigned long i);
extern void getRawMoments(unsigned long i, double m[10]);
extern double getAreaFromContour(unsigned long i);
extern double getPerimeter(unsigned long i);
extern void getCentroid(unsigned long i, double centroid[2]);
extern double getAspect_Ratio(unsigned long i);
extern void getBbox(unsigned long i, double bBox[4]);
extern unsigned long getChLen(unsigned long i);
extern void getConvh(unsigned long i, int *convhXs, int *convhYs);
extern double getConvexArea(unsigned long i);
extern void getEllipse(unsigned long i, double ellipse[5]);
extern double getExtent(unsigned long i);
extern double getSolidity(unsigned long i);
extern double getMajorAxisLength(unsigned long i);
extern double getMinorAxisLength(unsigned long i);
extern double getOrientation(unsigned long i);
extern double getEccentricity(unsigned long i);
extern double getEquivalentDiameter(unsigned long i);
extern unsigned long getConPxLen(unsigned long i);
extern void getContourPixelList(unsigned long i, int *contXs, int *contYs);
extern unsigned long getPxLen(unsigned long i);
extern void getPixelList(unsigned long i, int *pixXs, int *pixYs);

void initRprops();
void deinitRprops();
void crprops(unsigned char* arrayPtr, unsigned int rows, unsigned int cols, unsigned long *n);

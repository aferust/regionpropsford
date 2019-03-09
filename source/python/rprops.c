
extern void _rprops(unsigned char* _data, unsigned int rows, unsigned int cols, unsigned long *n);

void initRprops(){
    rt_init();
}

void crprops(unsigned char* arrayPtr, unsigned int rows, unsigned int cols, unsigned long *n)
{
    
    _rprops(arrayPtr, rows, cols, n);

}

void deinitRprops(){
    rt_term();
}

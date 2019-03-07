
extern int rt_init();
extern int rt_term();
extern void _rprops(unsigned char* _data, unsigned int rows, unsigned int cols);

void crprops(unsigned char* arrayPtr, unsigned int rows, unsigned int cols)
{
    rt_init();
    _rprops(arrayPtr, rows, cols);
    rt_term();
}
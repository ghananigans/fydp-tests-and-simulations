/* Factored discrete Fourier transform, or FFT, and its inverse iFFT */
/* http://www.math.wustl.edu/~victor/mfmm/fourier/fft.c */

#ifndef PI
# define PI	3.14159265358979323846264338327950288
#endif

typedef float real;
typedef struct{real Re; real Im;} complex;

void print_vector( const char *, complex *, int );
void fft( complex *, int, complex * );
void ifft( complex *, int, complex * );

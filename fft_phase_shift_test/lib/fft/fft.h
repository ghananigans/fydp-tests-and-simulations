/* Factored discrete Fourier transform, or FFT, and its inverse iFFT */
/* http://www.math.wustl.edu/~victor/mfmm/fourier/fft.c */

#ifndef __FFT_H__
#define __FFT_H__

#ifndef PI
# define PI	3.14159265358979323846264338327950288
#endif

typedef double real;
typedef struct{real Re; real Im;} complex;

void fft( complex *, int, complex * );
void ifft( complex *, int, complex * );

#endif // __FFT_H__

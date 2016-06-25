#ifndef __PHASE_SHIFT_H__
#define __PHASE_SHIFT_H__

#include <fft/fft.h>

void constant_phase_shift( complex *, int, double );
void print_matlab_vector( const char *, complex *, int );

#endif // __PHASE_SHIFT_H__

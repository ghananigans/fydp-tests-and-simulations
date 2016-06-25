#ifndef __PHASE_SHIFT_H__
#define __PHASE_SHIFT_H__

#include <fft/fft.h>

/*
 * NAME:          constant_phase_shift
 *
 * DESCRIPTION:   Do a constant phase shift in the frequency domain. The passed
 *                in complex-valued array will be modified in place with the
 *                new values which will be the phase shifted original values.
 *
 * PARAMETERS:
 *  complex *x
 *    - Frequency domain values.
 *  int n
 *    - Number of elements in the array.
 *  double phase
 *    - The phase to shift the signal by.
 *
 * RETURNS:
 *  N/A
 */
void constant_phase_shift( complex *, int, double );

/*
 * NAME:          print_matlab_vector
 *
 * DESCRIPTION:   Prints a complex-valued array into a vector form that can be
 *                put into matlab to do other processing (printing a plot).
 *
 * PARAMETERS:
 *  const char *title
 *    - Name for the variable that will be generated.
 *  complex *x
 *    - Array of complex values
 *  int n
 *    - Number of elements in the array.
 *
 * RETURNS:
 *  N/A
 */
void print_matlab_vector( const char *, complex *, int );

#endif // __PHASE_SHIFT_H__

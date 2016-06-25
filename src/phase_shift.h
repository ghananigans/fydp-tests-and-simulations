#ifndef __PHASE_SHIFT_H__
#define __PHASE_SHIFT_H__

#include <fft/fft.h>
/*
 * NAME:          complexify_real_signal
 *
 * DESCRIPTION:   Given a real-only signal (no imaginry parts), this function
 *                will compute the hilbert transform as outlined on MatLab's
 *                website http://www.mathworks.com/help/signal/ref/hilbert.html.
 *                1) Calculate fft of x
 *                2) Create a vector h whose elements h[i] has the values:
 *                  - 1 for i = 1, n/2
 *                  - 2 for i = 2, 3, ..., n/2-1
 *                  - 0 for i > n/2
 *                3) Calculate the element-wise product of x and h
 *                4) Calculate ifft of sequence from 3. Return first n elements
 *
 * PARAMETERS:
 *  complex *x
 *    - Real valued signal array. It will be modified in place.
 *  int n
 *    - Number of elements in the array.
 *  complex *scratch
 *    - A an array of atleast n complex elements. It is used to hold temp
 *      values.
 *
 * RETURNS:
 *  N/A
 */
void complexify_real_signal( complex *, int, complex * );

/*
 * NAME:          constant_phase_shift
 *
 * DESCRIPTION:   Do a constant phase shift in the frequency domain. The passed
 *                in complex-valued array will be modified in place with the
 *                new values which will be the phase shifted original values.
 *
 * PARAMETERS:
 *  complex *x
 *    - Frequency domain values. It will be modified in place.
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

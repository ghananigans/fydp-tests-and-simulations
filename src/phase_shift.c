#include "phase_shift.h"
#include <stdio.h> // printf
#include <math.h> // sin, cos, atan, sqrt, pow
#include <string.h> // memcpy


/* http://www.mathworks.com/help/signal/ref/hilbert.html */
void complexify_real_signal( complex *x, int n, complex *scratch )
{
  int i;
  real re;
  real im;
  complex h[n];

  if (n > 0)
  {
    fft(x, n, scratch);

    // set all values in h to be 0
    memset(h, 0, sizeof(complex) * n);
    h[0].Re = 1;
    h[n/2].Re = 1;

    for(i = 1; i < n/2; ++i)
    {
      h[i].Re = 2;
    }

    for (i = 0; i < n; ++i)
    {
      re = x[i].Re;
      im = x[i].Im;

      x[i].Re = re * h[i].Re - im * h[i].Im;
      x[i].Im = re * h[i].Im + im * h[i].Re;
    }

    ifft(x, n, scratch);
  }
}

/*
 * See phase_shift.h for comments.
 */
void constant_phase_shift( complex *x, int n, double phase)
{
  int i;
  double angle;
  double a;
  double x_abs;

  // http://stackoverflow.com/questions/25963607/change-phase-of-a-signal-in-frequency-domain-matlab
  // http://stackoverflow.com/questions/32584434/changing-the-phase-of-a-signal-in-frequency-domain
  // Y = abs(Y) .* exp(1i * (angle(Y) - phase)); # i is the imaginary number
  // Y = abs(Y) .* (cos(angle(Y) - phase) + i*sin(angle(Y) - phase)) # Using Euler's formula
  for (i = 0; i < n; ++i)
  {
    angle = atan(x[i].Im/x[i].Re);
    a = angle - phase;
    x_abs = sqrt(pow(x[i].Re, 2) + pow(x[i].Im, 2));

    x[i].Re = x_abs * cos(a);
    x[i].Im = x_abs * sin(a);
  }
}

/*
 * See phase_shift.h for comments.
 */
void print_matlab_vector( const char *title, complex *x, int n )
{
  int i;

  printf("%s = [", title);

  for(i=0; i<n; i++ )
  {
    printf("%f + %fi ", x[i].Re, x[i].Im);
  }

  printf("];\n");
}

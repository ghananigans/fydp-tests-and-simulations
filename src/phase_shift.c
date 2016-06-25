#include "phase_shift.h"
#include <stdio.h> // printf
#include <math.h> // sin, cos, atan, sqrt, pow

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

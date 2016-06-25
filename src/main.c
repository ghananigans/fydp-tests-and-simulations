#include <stdio.h>
#include <stdlib.h>
#include <fft/fft.h>
#include <math.h>
#include "phase_shift.h"

int main(void)
{
  int N = 1 << 6; // for 2^3 point (i)fft
  int k;
  complex v[N];
  //complex v1[N];
  complex scratch[N];

  /* Fill v[] with a function of known FFT: */
  for(k=0; k<N; k++) {
    v[k].Re = 0.125*cos(4*PI*k/(double)N); // 2 Hz signal
    v[k].Im = 0; //0.125*sin(4*PI*k/(double)N); // 2 Hz signal
    //v1[k].Re =  0.3*cos(2*PI*k/(double)N);
    //v1[k].Im = -0.3*sin(2*PI*k/(double)N);
  }

  /* FFT, iFFT of v[]: */
  print_matlab_vector("Orig", v, N);

  complexify_real_signal(v, N, scratch);

  fft( v, N, scratch );
  print_matlab_vector(" FFT", v, N);

  constant_phase_shift(v, N, PI/3);
  ifft( v, N, scratch );
  print_matlab_vector("iFFT", v, N);

  /* FFT, iFFT of v1[]:
  print_matlab_vector("Orig", v1, N);
  fft( v1, N, scratch );
  print_matlab_vector(" FFT", v1, N);
  ifft( v1, N, scratch );
  print_matlab_vector("iFFT", v1, N); */

  exit(EXIT_SUCCESS);
}

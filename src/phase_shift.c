#include "phase_shift.h"
#include <stdio.h>

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

#include "kremlib.h"
#include "kremstr.h"

/******************************************************************************/
/* Implementation of FStar.String and FStar.HyperIO                           */
/******************************************************************************/

/* FStar.h is generally kept for the program we wish to compile, meaning that
 * FStar.h contains extern declarations for the functions below. This provides
 * their implementation, and since the function prototypes are already in
 * FStar.h, we don't need to put these in the header, they will be resolved at
 * link-time. */

Prims_nat FStar_String_strlen(Prims_string s) {
  return strlen(s);
}

Prims_string FStar_String_strcat(Prims_string s0, Prims_string s1) {
  char *dest = calloc(strlen(s0) + strlen(s1) + 1, 1);
  strcat(dest, s0);
  strcat(dest, s1);
  return (Prims_string)dest;
}

Prims_string Prims_strcat(Prims_string s0, Prims_string s1) {
  return FStar_String_strcat(s0, s1);
}

void FStar_HyperStack_IO_print_string(Prims_string s) {
  printf("%s", s);
}
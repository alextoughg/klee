/*
 * First KLEE tutorial: testing a small function
 */

#include <klee/klee.h>

int get_sign(int x) {
  klee_make_symbolic(&x, sizeof(x), "x");
  if (x == 1)
     return 0;
  
  if (x < 0)
     return -1;
  else 
     return 1;
} 

/*int main() {
  int a;
  klee_make_symbolic(&a, sizeof(a), "a");
  return get_sign(a);
}*/ 

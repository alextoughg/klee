#include<klee/klee.h>
int lib(int x) {
  if (x <= 0)
     return -1;
  else
     return 1;
}

int client(int x){
  klee_make_symbolic(&x, sizeof(x), "x");
  if (x > 0) {
    return lib(x);
  }
  return x;
}

/*int main() {
	int x;
	return client(x);
}*/

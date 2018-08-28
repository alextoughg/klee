#include<klee/klee.h>
int foo(int a, int b);

int main(int x, char*argv[]) {
	klee_make_symbolic(&x, sizeof(x), "x");
	if (x>=9 && x<12)
		return foo(x,10);
	return 0;
}

int foo(int a, int b) {
	int c=0;
	for (int i=1;i<=a;++i)
		c+=b;
	
	return c;
}

#include<klee/klee.h>
int lib(int x) {
	return x % 6;
}

int client(int x){
        klee_make_symbolic(&x, sizeof(x), "x");
	x = x*5*6;
	if (lib(x)==0){
		return 1;
	}else{
		return 0;
	}
}

/*int main() {
	int x;//=3918991416;
	return client(x);
}*/

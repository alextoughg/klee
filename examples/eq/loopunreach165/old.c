int foo(int a, int b) {
	int c=0;
	if (a<0) {
		for (int i=1;i<=b;++i)
			c += a;
	}
	return c;

int main(int x, char*argv[]) {                
	if (x>=145 && x<185)                
		return foo(x,165);                
	return 0;

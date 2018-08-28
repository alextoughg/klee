#include<klee/klee.h>

int seven_plus(int x)
{
	klee_make_symbolic(&x,sizeof(x),"x");
        if(x>5){
                return x;
        }
        else{
                return 7+x;
        }
}


#include<klee/klee.h>

int seven_plus(int x)
{
	klee_make_symbolic(&x,sizeof(x),"x");
        if(x>10){
                return x;
        }
        else{
                return 7+x;
        }
}

/*int main()
{
        int a;
        klee_make_symbolic(&a,sizeof(a),"a");
        return seven_plus(a);
}*/

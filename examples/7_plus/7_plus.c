#include<klee/klee.h>

int lib(int x)
{
        if(x>10){
                return x;
        }
        else{
                return 7+x;
        }
}

int client(int x)
{
    
    klee_make_symbolic(&x,sizeof(x),"x");
    if(x > 5){
        return lib(x);
    } 
    else {
        return x;
    }
}

/*int main()
{
        int a;
        klee_make_symbolic(&a,sizeof(a),"a");
        return seven_plus(a);
}*/

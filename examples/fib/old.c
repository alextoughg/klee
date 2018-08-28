#include<klee/klee.h> 
int lib(int n){
    if(n == 1){
        return 1;
    }else if(n < 1){
        return 0;
    }else{
        return lib(n - 1) + lib(n - 2);
    }
}

int fib(int x){
    klee_make_symbolic(&x, sizeof(x), "x");
    if(x<5){
        return lib(x);
    }else{
        return 0;
    }
}

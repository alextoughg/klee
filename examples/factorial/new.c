#include <klee/klee.h>

int lib(int n){
    if(n <= 0){
        return 0;
    }else if(n ==1){
        return 1;
    }else{
        return n * lib(n-1);
    }
}

int factorial(int x){
    klee_make_symbolic(&x, sizeof(x), "x");
    if(x<5){
        return lib(x);
    }else{
        return 0;
    }
}

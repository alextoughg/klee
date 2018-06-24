#include <klee/klee.h>

int sum(int x, int y){
    int a;
    a = x;
    x = 10;
    if(y>0){
        if(y < x){
	    return 3*x;
        }
        y = a+1;
        x = a+1;
    } else{
        if(a < y){
	    return 4*x + x*y + y;
	}
        y = 0;
        x = 0;
    }
    return x+y;
}

int main(){
    int x;
    int y;
    klee_make_symbolic(&x, sizeof(x), "x");
    klee_make_symbolic(&y, sizeof(y), "y");
    return sum(x,y);    
}

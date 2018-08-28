#include <klee/klee.h>

int sum(int x, int y){
    int a;
    a = x;
    //x = 10;
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
        //y = 0;
        //x = 0;
    }
    return x+y;
}

int wrapper(){
    int x1 = 3;
    int y1 = 4;
    klee_make_symbolic(&x1, sizeof(x1), "x");
    klee_make_symbolic(&y1, sizeof(y1), "y");
    return sum(x1,y1);
}

/*int main(){
    int x = 3;
    int y = 4;
    //klee_make_symbolic(&x, sizeof(x), "x");
    //klee_make_symbolic(&y, sizeof(y), "y");
    return sum(x,y);    
}*/

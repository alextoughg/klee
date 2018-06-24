// C++ code for linearly search x in arr[].  If x 
// is present  then return its  location,  otherwise
// return -1

#include <stdio.h>
#include <klee/klee.h>

int linearSearch(int arr[], int n, int x)
{
    int i;
    for (i = 0; i < n; i++)
        if (arr[i] == x)
         return x+i;
    return -1;
}

int main(){
   int arr[] = {2, 3, 4, 10, 40, 50, -3};
   int n = sizeof(arr)/ sizeof(arr[0]);
   int x;
   klee_make_symbolic(&x, sizeof(x), "x");
   return linearSearch(arr, n, x);
}

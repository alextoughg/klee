// C program to implement recursive Binary Search
#include <stdio.h>
#include <klee/klee.h>

// A recursive binary search function. It returns
// location of x in given array arr[l..r] is present,
// otherwise -1
int binarySearchHelper(int arr[], int l, int r, int x)
{
   //klee_make_symbolic(&x,sizeof(x),"x");
   if (r >= l)
   {
        int mid = l + (r - l)/2;

        // If the element is present at the middle
        // itself
        if (arr[mid] == x)
            return mid;

        // If element is smaller than mid, then
        // it can only be present in left subarray
        if (arr[mid] > x)
            return binarySearchHelper(arr, l, mid-1, x);

        // Else the element can only be present
        // in right subarray
        return binarySearchHelper(arr, mid+1, r, x);
   }

   // We reach here when element is not
   // present in array
   return -1;
}

// Arguments to wrapper functions can only be symbolic vars!
int wrapper(int x){
   int arr[] = {2, 3, 4, 10, 40};
   int n = sizeof(arr)/ sizeof(arr[0]);
   klee_make_symbolic(&x,sizeof(x),"x");
   return binarySearchHelper(arr, 0, n-1, x);
}

/*int main()
{
   int arr[] = {2, 3, 4, 10, 40};
   int n = sizeof(arr)/ sizeof(arr[0]);
   int x = 2;
   klee_make_symbolic(&x,sizeof(x),"x");
   return binarySearch(arr, 0, n-1, x);
}*/

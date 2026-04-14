#include <stdio.h>
#include <dlfcn.h>

int main() {
    char op[6];
    int a, b;

    while (1) {
        int ret = scanf("%5s %d %d", op, &a, &b);
        if (ret == EOF) {
            break;                                      //terminate on EOF
        }
        if (ret != 3) {
            continue;                                   //skip invalid input
        }
        char libname[20];
        sprintf(libname, "./lib%s.so", op);
        void *handle = dlopen(libname, RTLD_LAZY);      //dynamic loading
        if (!handle) {
            continue;
        }
        int (*func)(int, int);
        func = (int (*)(int,int)) dlsym(handle, op);
        if (!func) {
            dlclose(handle);
            continue;
        }
        int result = func(a, b);
        printf("%d\n", result);
        dlclose(handle);                                //free memory
    }
    return 0;
}

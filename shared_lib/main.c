#include "clib.h"

int main() {
    int z = f(5 + 3);
    return z;
}

// -nostdlib
int _start() {
    long long exit_code = main();
    // I failed to make it work if the first two statements go in the other order
    __asm__("movq $60, %%rax\n"
            "movq %0, %%rdi\n"
            "syscall"
            :
            :"r"(exit_code)
            :"rax","rdi");
}

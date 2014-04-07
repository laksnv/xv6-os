#include "types.h"
#include "user.h"

void custom_sighandler(int signum)
{
    printf(1, "User-defined handler called!\n");
    exit();
}

int main(void)
{
    int i = signal(SIGSEGV, custom_sighandler);
    int *ptr = &i;
    
    ptr += 50000;
    printf(1, "%d\n", *ptr);

    exit();
}
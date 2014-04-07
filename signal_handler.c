#include "types.h"
#include "user.h"

void custom_sighandler(int signum)
{
    printf(1, "User-defined handler called!\n");
    static int i = 0;
    int *ret = &i;
    i++;
    
    if(i == 100)
    {
        ret += 55;
        (*ret) = (*ret) + 8;
        printf(1, "%x", *ret);
    }
}

int main(void)
{
    int i = signal(SIGSEGV, custom_sighandler);
    int *ptr = &i;

    ptr += 50000;

    int t = uptime();
    printf(1, "%d\n", *ptr);
    printf(1, "Crossed Exception\n");
    printf(1, "%d\n", (t - uptime())/100);

    exit();
}
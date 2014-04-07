#include "types.h"
#include "user.h"
//#include "syscall.h"
#include "traps.h"

int main(void)
{
    printf(1, "# of Keyboard Interrupts: %d\n", icount());
        
    exit();
}
#include "types.h"
#include "user.h"

int main(void)
{
    int ChildPid = fork();
    
    if(ChildPid < 0)
        printf(1, "Fork failed %d\n", ChildPid);
                
    else if(ChildPid > 0)
    {
        printf(1, "This is the parent. My Pid is %d, my child Pid is %d\n", getpid(), ChildPid);
        wait();
    }
    
    else
        printf(1, "This is the child. My Pid is %d, my parent Pid is %d\n", getpid(), getppid());
        
    exit();
}
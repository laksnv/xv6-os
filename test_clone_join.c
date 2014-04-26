#include "types.h"
#include "user.h"

void clone_test()
{
	printf(1, "Inside close_test()\nChild Process PID: %d\nExiting\n", getpid());
	
	exit();
}


int main(void)
{
	int num = 8, ret = 10;
	char *stack = malloc(4096);

	ret = clone(clone_test, (void *) num, stack);
	free(stack);

	printf(2, "\nWaiting for clone_test() to exit\nRet: %d\n", ret);
	
	printf(2, "\nJoin ret: %d\n", join());

	listprocesses();

	exit();
}
#include "types.h"
#include "user.h"

void clone_test()
{
	int x = 5, *p = &x;
	p += 2;
	
	printf(1, "\nInside clone_test()");
	printf(2, "\nReturn address [from clone_test()]: %x\n", p);
	
	exit();
}


int main(void)
{
	int num = 8, ret = 10;
	char *stack = malloc(4096);
	//printf(2, "Address of malloc: %x\n", stack);

	ret = clone(clone_test, (void *) num, stack);
	free(stack);

	printf(2, "\nWaiting for clone_test() to exit\nClone returned %d\n", ret);
	
	printf(2, "\nJoin returned %d\n", join());

	//listprocesses();

	exit();
}
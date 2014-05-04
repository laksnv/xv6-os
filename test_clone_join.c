#include "types.h"
#include "user.h"
#include "spinlock.h"




int mypthread_create(void (*start_routine) (void *), void *arg)
{
	int pid;
	void *stack = malloc(4096);

	pid = clone(start_routine, arg, stack);

	if(!pid)
		(*start_routine)(arg);

	free(stack);

	return pid;
}


int mypthread_join()
{
	void **stack = malloc(4096);

	return join(stack);
}
/*
void mypthread_yield()
{
	sleep();

	return ;
}
*/
/*
void clone_test()
{
	int x = 5, *p = &x;
	p += 2;
	
	printf(1, "\nInside clone_test()");
	//printf(2, "\nReturn address [from clone_test()]: %x\n", p);
	//printf(2, "\n%d\n", getpid());
	
	exit();
}


int main(void)
{
	int num = 8, ret = 10;
	char *stack = malloc(4096);
	char *stack3 = malloc(4096);
	char *stack2 = malloc(4096);
	char **ptr_stack2 = &stack2;

	ret = clone(clone_test, (void *) num, (void *) stack);
	ret = clone(clone_test, (void *) num, (void *) stack3);

	printf(2, "\nWaiting for clone_test() to exit\nClone returned %d\n", ret);
	printf(2, "\nJoin returned %d\n", join((void **) ptr_stack2));
	printf(2, "\nJoin returned %d\n", join((void **) ptr_stack2));

	//listprocesses();
	free(stack);

	exit();
}
*/




void WTF(void *p) // work time fun
{
  
  printf(2, "Thread %d, in WTF\n", getpid());
  
  printf(2, "Thread %d exiting\n", getpid());
  
  exit();
}


int main(void)
{
  int a, b;

  printf(2, "Thread %d, in main\n", getpid());
  
  a = mypthread_create(WTF, &a);
  mypthread_join();
  
  b = mypthread_create(WTF, &b);
  mypthread_join();

  printf(2, "Thread %d exiting\n", getpid());
  
  exit();
}




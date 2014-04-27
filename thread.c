



int mypthread_create(void * (start_routine) (void *), void *arg)
{
	int pid;
	void *stack = malloc(4096);

	pid = clone(start_routine, arg, stack);

	return pid;
}

int mypthread_join()
{
	join();
}

int mypthread_yield()
{
	yield();
}
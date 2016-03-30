#include "stdio.h"
#include "signal.h"
#include "pthread.h"

void signal_handler_fun(int signal_num) {
	printf("catch signal %d\n", signal_num);
}

int g = 0;

// void* worker(void *param) {
// 	printf("worker 1. num %d\n", g);
// 	__sync_fetch_and_add(g, )
// }

int main(int argc, char const *argv[])
{
	/* code */
	for (int i = 0; i < argc; ++i)
	{
		/* code */
		printf("%s\n", argv[i]);
	}
	signal(SIGINT, signal_handler_fun);
	for (;;);
	return 0;
}

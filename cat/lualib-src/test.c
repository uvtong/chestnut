#include "stdio.h"
#include "signal.h"
#include "pthread.h"
#include <stdint.h>

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
	// signal(SIGINT, signal_handler_fun);
	// for (;;);
	int i = 8;
	printf("the is an int %d" + i, 100);
	uint32_t mask = ((1 << 8) - 1 );
	printf("%d\n", mask);
	if ((450 | mask) == (467 | mask)) {
		printf("%d\n", 450 | mask);
		printf("%d\n", 467 | mask);
		printf("%s\n", "yes");
	}
	return 0;
}

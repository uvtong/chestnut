#include "stdio.h"
#include "signal.h"

void signal_handler_fun(int signal_num) {
	printf("catch signal %d\n", signal_num);
}

int main(int argc, char const *argv[])
{
	/* code */
	signal(SIGINT, signal_handler_fun);
	for (;;);
	;return 0;
}

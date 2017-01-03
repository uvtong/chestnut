#include <co_routine.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>

struct xx {
	int a;
};

static void * routine(void *arg) {
	struct xx *x = (struct xx *)arg;
	printf("%d\n", x->a);
	stCoRoutine_t *co = co_self();
	co_yield(co);
	printf("%d\n", x->a);
	return NULL;
}

int main() {
	printf("%s\n", "crete");
	struct xx x = {1};
	stCoRoutine_t *co = NULL;
	co_create(&co, NULL, routine, &x);
	stCoRoutine_t *co1 = NULL;
	co_create(&co1, NULL, routine, &x);
	printf("%s\n", "resume");
	co_resume(co);
	co_resume(co1);
	printf("%s\n", "yield");
	x.a = 3;
	co_resume(co);
	printf("%s\n", "exit");
	return 0;
}
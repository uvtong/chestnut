#ifndef __SERVICE_ROOM_H_
#define __SERVICE_ROOM_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

struct battle {
	int dummy;
};

struct battle * 
battle_alloc();

void 
battle_free(struct room *self);

#ifdef __cplusplus
}
#endif
#endif
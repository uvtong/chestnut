#ifndef __SERVICE_ROOM_H_
#define __SERVICE_ROOM_H_
#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

class RoomContext;
struct room {
	RoomContext *room;
};

struct room* room_alloc();
void room_free(struct room *r);

void room_send(struct room *r, uint32_t dst, int type, int session);

#ifdef __cplusplus
}
#endif
#endif
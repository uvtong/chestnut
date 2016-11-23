#ifndef __ROOMCONTEXT_H_
#define __ROOMCONTEXT_H_

#include "service_room.h"
#include "App.h"
#include <map>

class RoomContext {
public:
	// typedef void (timeout*)(void);

	RoomContext();
	~RoomContext();

	void send();
	
private:
	App _app;
	// std::map<int, timeout> _dic;

};

#endif
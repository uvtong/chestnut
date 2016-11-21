#ifndef __ROOMCONTEXT_H_
#define __ROOMCONTEXT_H_

#include "App.h"
#include <map>

class RoomContext {
public:
	typedef void (timeout*)(void);

	RoomContext();
	~RoomContext();
	
private:
	App _app;
	std::map<int, timeout> _dic;
};

#endif
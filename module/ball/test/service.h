#ifndef SERVICE_H
#define SERVICE_H

#include <cstdint>

class Service
{
public:
	Service();
	~Service();
	
private:
	static uint32_t _count;
};

#endif
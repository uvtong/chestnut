#ifndef TASKCONF_H
#define TASKCONF_H

#ifdef SK
#include <skynet.h>
#include <skynet_malloc.h>
#define MALLOC skynet_malloc
#define REALLOC skynet_malloc
#define FREE skynet_free
#else
#include <stdio.h>
#include <stdlib.h>
#define MALLOC malloc
#define REALLOC realloc
#define FREE free
#endif

#endif
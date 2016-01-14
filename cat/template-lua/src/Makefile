ALL_O := automem.o lua-json.o lua-lmu.o lua-tpl.o
RM := rm -fr
CC := gcc
SHARED = -shared

SRC := automen.c lua-json.c lua-lmu.c lua-tpl.c
HEADER := automen.h lauxlib.h lua.h lua-json.h lua-tpl.h

LIB_SO := lmu.so

CFLAGS = -g -O2 -Wall

#all: $(LIB_SO)

$(LIB_SO): $(ALL_O)
	$(CC) $(ALL_O) $(SHARED) $(CFLAGS) -o $@

automem.o: automem.c automem.h
	$(CC) -c $(CFLAGS) automem.c -o $@

lua-json.o: lua-json.c lua.h lauxlib.h lua-json.h luaconf.h
	$(CC) -c $(CFLAGS) lua-json.c -o $@	

lua-lmu.o: lua-lmu.c lua.h lauxlib.h lua-json.h
	$(CC) -c $(CFLAGS) lua-lmu.c -o $@		

lua-tpl.o: lua-tpl.c automem.h lua.h lauxlib.h
	$(CC) -c $(CFLAGS) lua-tpl.c -o $@			

.PHONY: all clean cleanall

clean: 
	$(RM) $(ALL_O)

cleanall:
	$(RM) $(ALL_O) $(LIB_SO)
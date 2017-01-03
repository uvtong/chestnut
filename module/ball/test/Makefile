hpaths := -I. -I./../libco
lpaths := -L. -L./../libco/lib
libraries := -lcolib -lpthread -ldl -lm
shared := -fPIC -shared

test: test.cpp | libtask.so
	g++ -std=c++11 -g -Wall -pthread -o $@ $^ -L. -ltask -lpthread

libtask.so: task.cpp taskpool.cpp
	g++ -std=c++11 -g -Wall $(shared) $(hpaths) $^ -o $@ $(lpaths) $(libraries)


test1: main.c
	g++ -std=c++11 -g -Wall $(hpaths) $^ -o $@ $(lpaths) $(libraries)

clean:
	rm -f libtask.so test
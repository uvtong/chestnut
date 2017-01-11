hpaths := -I. -I./../libco
lpaths := -L. -L./../libco/lib
libraries := -lcolib -lpthread -ldl -lm
shared := -fPIC -shared

CPPFLAGS := -std=c++11 -g -Wall -pthread

test: test.cpp | libtask.so
	g++ $(CPPFLAGS) -o $@ $^ -L. -ltask -lpthread

libtask.so: task.cpp taskpool.cpp taskpools.cpp
	g++ $(CPPFLAGS) $(shared) $(hpaths) $^ -o $@ $(lpaths) $(libraries)

clean:
	rm -f libtask.so test
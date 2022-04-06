
INCLUDE = -I src -I src/tools/include
SRC  = src/main.cpp 
LIBS = -lpthread -lwiringPi -lwiringPiBME280rpi -lNeoPixelRPi -ljsoncpp -llog4pi
SLIB = /usr/local/lib/libwiringPiUDDrpi.a
OBJS = obj/Settings.o obj/ClockClient.o obj/StringUtil.o obj/tcpclient.o obj/threads.o obj/HttpRequest.o obj/tcplistener.o obj/ClockListener.o


piClock: ${SRC} ${OBJS}
	@echo Compiling piClock...
	@mkdir -p bin 
	g++ -o bin/piClock  ${INCLUDE} ${OBJS} ${SRC} ${LIBS} ${SLIB}


obj/Settings.o: src/Settings.h
	@mkdir -p obj
	g++ -c ${INCLUDE} src/Settings.cpp -o obj/Settings.o

obj/ClockClient.o: src/ClockClient.h
	@mkdir -p obj
	g++ -c ${INCLUDE} src/ClockClient.cpp -o obj/ClockClient.o

obj/StringUtil.o: src/tools/include/StringUtil.h
	@mkdir -p obj
	g++ -c ${INCLUDE} src/tools/util/StringUtil.cpp -o obj/StringUtil.o

obj/tcpclient.o: src/tools/include/tcpclient.h
	@mkdir -p obj
	g++ -c ${INCLUDE} src/tools/util/tcpclient.cpp -o obj/tcpclient.o

obj/threads.o: src/tools/include/threads.h
	@mkdir -p obj
	g++ -c ${INCLUDE} src/tools/util/threads.cpp -o obj/threads.o

obj/HttpRequest.o: src/tools/include/HttpRequest.h
	@mkdir -p obj
	g++ -c ${INCLUDE} src/tools/util/HttpRequest.cpp -o obj/HttpRequest.o

obj/tcplistener.o: src/tools/include/tcplistener.h
	@mkdir -p obj
	g++ -c ${INCLUDE} src/tools/util/tcplistener.cpp -o obj/tcplistener.o

obj/ClockListener.o: src/ClockListener.h
	@mkdir -p obj
	g++ -c ${INCLUDE} src/ClockListener.cpp -o obj/ClockListener.o



clean:
	@rm -rf bin obj

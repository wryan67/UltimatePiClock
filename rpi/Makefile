
SRC = src/tools/util/threads.cpp src/main.cpp 
LIBS = -lpthread -lwiringPi -lwiringPiBME280rpi -lNeoPixelRPi -ljsoncpp
SLIB = /usr/local/lib/libwiringPiUDDrpi.a

piClock: ${SRC}
	@echo Compiling piClock...
	@mkdir -p bin
	@g++ -o bin/piClock ${SRC} ${LIBS} ${SLIB}


clean:
	@rm -rf bin

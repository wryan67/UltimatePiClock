
SRC = src/tools/util/threads.cpp src/main.cpp 
LIBS = -lpthread -lwiringPi -lwiringPiUDDrpi -lwiringPiBME280rpi -lNeoPixelRPi

piClock: ${SRC}
	g++ -o piClock ${SRC} ${LIBS}


clean:
	@rm -f piClock

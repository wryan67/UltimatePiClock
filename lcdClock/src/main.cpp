/*
 * Author: wryan
 * Date:2018/12/27
 * Compiling :gcc -Wall name.c -lwiringPi -lwiringPiDev
 */
#include <wiringPi.h>
#include <pcf8574.h>
#include <lcd.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>
#include <unistd.h>
#include <pthread.h>
#include <sys/types.h>

#include <chrono>
#include <ctime>  

#include "./tools/include/dht22.h"
#include "./tools/include/threads.h"
#include "./tools/include/pcf8574io.h"
#include "./tools/include/lcd.h"

static volatile int dhtPin = 29;


 // Global Variables
static unsigned int lcdAddress;
static int          tries = 5;
static char         dateFormat = '1';
static volatile int lcdHandle;
static volatile int marqueeSpeed = 400;

static volatile bool daemonMode = false;
static volatile float humidity = -9999;
static volatile float temperature = -9999;

int marquee = 0;
char msg[1024];


bool usage() {
	fprintf(stderr, "usage: lcdClock [-d] [-a 00-FF] [-p 0-40] [-f n] [-s speed] [-m motd]\n");
	fprintf(stderr, "d = daemon mode\n");
	fprintf(stderr, "a = hexadecimal i2c address ($gpio i2cd)\n");
	fprintf(stderr, "p = dht wiringPi pin number\n");
	fprintf(stderr, "m = message of the day, max 14 characters\n");
	fprintf(stderr, "s = marquee speed (ms)\n");
	fprintf(stderr, "f = clock format\n");
	fprintf(stderr, "    1 - Weekday Month Date HH24:SS\n");
	fprintf(stderr, "    2 - Weekday Date  HH:SS AM/PM\n");

	return false;
}




bool setup() {
	printf("Program initialization\n");


	if (int ret = wiringPiSetup()) {
		fprintf(stderr, "Wiring Pi setup failed, ret=%d\n", ret);
		return false;
	}

	int seed;
	FILE *fp;
	fp = fopen("/dev/urandom", "r");
	fread(&seed, sizeof(seed), 1, fp);
	fclose(fp);
	srand(seed);

	//  the following statements setup the proper input or output for their respective 
	//  inputs or outputs
	pinMode(dhtPin, INPUT);

	lcdHandle=lcdSetup(lcdAddress);
	if (lcdHandle < 0) {
		fprintf(stderr, "lcdInit failed\n");
		return false;
	}
	return true;
}


bool commandLineOptions(int argc, char **argv) {
	int c, index;

	if (argc < 2) {
		return usage();
	}

	while ((c = getopt(argc, argv, "da:p:f:m:s:")) != -1)
		switch (c) {
		case 'd':
			daemonMode = true;
			break;
		case 'a':
			sscanf(optarg, "%x", &lcdAddress);
			break;
		case 'm':
			strncpy(msg, optarg, sizeof(msg));
			if (strlen(msg) > 14) {
				fprintf(stderr, "message is too long, max size is 14 characters.\n");
				return usage();
			}
			break;
		case 'p':
			sscanf(optarg, "%d", &dhtPin);
			break;
		case 's':
			sscanf(optarg, "%d", &marqueeSpeed);
			break;
		case 'f':
			dateFormat = optarg[0];
			break;
		case '?':
			if (optopt == 'a' || optopt == 'p' || optopt == 'f' || optopt == 'm' || optopt == 's')
				fprintf(stderr, "Option -%c requires an argument.\n", optopt);
			else if (isprint(optopt))
				fprintf(stderr, "Unknown option `-%c'.\n", optopt);
			else
				fprintf(stderr, "Unknown option character \\x%x.\n", optopt);

			return usage();

		default:
			abort();
		}


	//	for (index = optind; index < argc; index++)
	//		printf("Non-option argument %s\n", argv[index]);
	return true;
}


static uint8_t sizecvt(const int read)
{
	/* digitalRead() and friends from wiringpi are defined as returning a value
	< 256. However, they are returned as int() types. This is a safety function */

	if (read > 255 || read < 0)
	{
		printf("Invalid data from wiringPi library\n");
		exit(EXIT_FAILURE);
	}
	return (uint8_t)read;
}




void *readDHT22Loop(void *) {
	float h;
	float t;

	while (true) {
		if (readDHT22Data(dhtPin, &h, &t)) {
			humidity = h;
			temperature = t;
			delay(5000);
		} else {
			delay(1500);
		}
	}
}

void updateClock() {
	auto now = std::chrono::system_clock::now();
	std::time_t end_time = std::chrono::system_clock::to_time_t(now);
	char vtime[64];

	switch (dateFormat) {
	case '2':	std::strftime(vtime, 64, "%a %e  %I:%M %p", std::localtime(&end_time));
		break;
	default:
		if (std::localtime(&end_time)->tm_mday < 10) {
			char xtime[64];
			std::strftime(xtime, 64, "%a %b %%d  %H:%M", std::localtime(&end_time));
			sprintf(vtime, xtime, std::localtime(&end_time)->tm_mday);
		}
		else {
			std::strftime(vtime, 64, "%a %b %e %H:%M", std::localtime(&end_time));
		}
	}



	lcdPosition(lcdHandle, 0, 0);           //Position cursor on the first line in the first column
	if (strlen(vtime) > 16) {
		vtime[16] = 0;
	}
	lcdPuts(lcdHandle, vtime);  //Print the text on the LCD at the current cursor postion

	if (!daemonMode) {
		printf("%s\n", vtime);
	}

	piLock(0);

	if (temperature > -999) {
		lcdPosition(lcdHandle, 0, 1);
		char humi[32];
		char temp[32];
		char tmpstr1[64];
		char tmpstr2[128];
		sprintf(humi, "H:%.0f%%", humidity);
		sprintf(temp, "T:%.0f%cF", temperature, 0xdf);

		if (strlen(msg) > 0) {

			sprintf(tmpstr2, "%16s", "");
			sprintf(&tmpstr2[(16 - strlen(msg)) / 2], "%s", msg);
			sprintf(tmpstr1, "%-6.6s  %-6.6s  %-16.16s", humi, temp, tmpstr2);
			sprintf(tmpstr2, "%s%s", tmpstr1, tmpstr1);
			if (!daemonMode) {
				printf("%s\n", tmpstr1);
			}
			tmpstr2[marquee + 16] = 0;
			lcdPuts(lcdHandle, &tmpstr2[marquee++]);
			if (marquee > strlen(tmpstr1) - 1) {
				marquee = 0;
			}
		}
		else {
			lcdPrintf(lcdHandle, "%-8.8s%8.8s", humi, temp);
		}
	}

	piUnlock(0);
}

void *updateClockLoop(void *) {
	while (true) {
		updateClock();
		delay(marqueeSpeed);
	}
}

int main(int argc, char **argv)
{
	int i;

	if (!commandLineOptions(argc, argv)) {
		return 1;
	}

	if (!setup()) {
		printf("setup failed\n");
		return 1;
	}



	threadCreate(readDHT22Loop, "read dht sensor");
	printf("updating clock... speed=%dms\n", marqueeSpeed);

	if (daemonMode) {
		threadCreate(updateClockLoop, "update clock loop");
		while (true) {
			delay(4294967295U);   // 3.27 years
		}
	}
	else {
		while (temperature < 999 && tries--) {
			delay(1000);
		}
		updateClock();
	}


	return 0;
}

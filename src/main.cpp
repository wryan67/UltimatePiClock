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


#include <udd.h>
#include <bme280rpi.h>

#include "./tools/include/threads.h"
#include "./tools/include/pcf8574io.h"

// Display vars
using namespace udd;

DisplayConfigruation d1Config;

DisplayST7789R d1 = DisplayST7789R();


// bme280 info
int bme280_address = 0x76;
bme280_calib_data cal;
int bme280_fd;



// Global Variables
static char         dateFormat = '1';
static volatile int marqueeSpeed = 400;

static volatile bool daemonMode = false;
static volatile float humidity = -9999;
static volatile float temperature = -9999;
int marquee = 0;




#define lcdWidth 16
#define maxMessageSize 128
char msg[1024];


bool usage() {
	fprintf(stderr, "usage: lcdClock [-d] [-b 00-FF] [-p 0-40] [-f n] [-s speed] [-m motd]\n");
	fprintf(stderr, "d = daemon mode\n");
	fprintf(stderr, "b = bme280 address (hex)\n");
	fprintf(stderr, "m = message of the day, max %d characters\n", maxMessageSize);
	fprintf(stderr, "s = marquee speed (ms)\n");
	fprintf(stderr, "f = clock format\n");
	fprintf(stderr, "    1 - Weekday Month Date HH24:SS\n");
	fprintf(stderr, "    2 - Weekday Date  HH:SS AM/PM\n");

	return false;
}


void configureDisplay1() {
    d1Config.width = 240;
    d1Config.height = 320;
    d1Config.spiSpeed = 90000000;

    d1Config.CS = 21;
    d1Config.DC = 22;
    d1Config.RST = 23;
    d1Config.BLK = 7;

    d1.openDisplay(d1Config);
    d1.printConfiguration();
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

    bme280_fd=bme280_standardSetup(bme280_address, &cal);

    configureDisplay1();

	return true;
}



bool commandLineOptions(int argc, char **argv) {
	int c, index;

	if (argc < 2) {
		return usage();
	}

	while ((c = getopt(argc, argv, "db:f:m:s:")) != -1)
		switch (c) {
		case 'd':
			daemonMode = true;
			break;
		case 'm':
			strncpy(msg, optarg, sizeof(msg));
			if (strlen(msg) > maxMessageSize) {
				fprintf(stderr, "message is too long, max size is 14 characters.\n");
				return usage();
			}
			break;
		case 'b':
			sscanf(optarg, "%x", &bme280_address);
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




void *readBME280Loop(void *) {
	float h;
	float t;
    bme280_raw_data raw;

	while (true) {
        bme280_getRawData(bme280_fd, &raw);

        int32_t t_fine = bme280_getTemperatureCalibration(&cal, raw.temperature);
        float t = bme280_compensateTemperature(t_fine); // C
        float p = bme280_compensatePressure(raw.pressure, &cal, t_fine) / 100; // hPa
        float h = bme280_compensateHumidity(raw.humidity, &cal, t_fine);       // %
        float a = bme280_getAltitude(p);                         // meters

        if (t > 0 && t < 100) {
            humidity = h;
            temperature = t * 9 / 5 + 32;
        }

//        printf("temperature=%f humidity=%f\n", temperature,humidity);

		delay(1000);
	}
}

void updateClock(Image *image) {

    auto now = std::chrono::system_clock::now();
    std::time_t end_time = std::chrono::system_clock::to_time_t(now);
    char vtime[64];

    int saveMarquee;

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


	if (strlen(vtime) > 16) {
		vtime[16] = 0;
	}

	if (!daemonMode) {
		printf("%s\n", vtime);
	}

    char humi[32];
    char temp[32];
    char tmpstr1[1024];
    char tmpstr2[2048];

    if (temperature > -999) {
        sprintf(humi, "H:%.0f%%", humidity);
        sprintf(temp, "T:%.0ff", temperature);

        int maxMessageLength = lcdWidth - 4;

        memset(tmpstr1, 0, sizeof(tmpstr1));

        if (strlen(msg) > 0 && strlen(msg) <= maxMessageLength) {

            sprintf(tmpstr2, "%*s", lcdWidth, "");
            sprintf(&tmpstr2[(lcdWidth - strlen(msg)) / 2], "%s", msg);
            sprintf(tmpstr1, "%-6.6s  %-6.6s  %-*.*s", humi, temp, lcdWidth, lcdWidth, tmpstr2);
            sprintf(tmpstr2, "%s  %s  ", tmpstr1, tmpstr1);
            if (!daemonMode) {
                printf("%s\n", tmpstr1);
            }
            tmpstr2[marquee + lcdWidth] = 0;

            saveMarquee = marquee++;
            //			lcdPuts(lcdHandle, &tmpstr2[marquee++]);

            if (marquee > strlen(tmpstr1) + 1) {
                marquee = 0;
            }
        }
        else if (strlen(msg) > 0) {
            sprintf(tmpstr1, "%-6.6s  %-6.6s  %s  ", humi, temp, msg);
            sprintf(tmpstr2, "%s  %s  ", tmpstr1, tmpstr1);
            if (!daemonMode) {
                printf("%s\n", tmpstr1);
            }
            tmpstr2[marquee + lcdWidth] = 0;

            saveMarquee = marquee++;
            //lcdPuts(lcdHandle, &tmpstr2[marquee++]);
            if (marquee > strlen(tmpstr1) + 1) {
                marquee = 0;
            }
        }
        else {


            //lcdPrintf(lcdHandle, "%-8.8s%8.8s", humi, temp);
            if (!daemonMode) {
                printf("%-8.8s %-8.8s", humi, temp);
            }
        }




        image->clear(BLACK);
        image->loadBMP("images/BlueAngle4-320x240.bmp", 0, 0);


        int imageWidth = d1Config.height;
        int imageHeight = d1Config.width;
        int minX = 0, minY = 0;
        int maxX = imageWidth - 1;
        int maxY = imageHeight - 1;
        int midY = minY + (maxY - minY) / 2;
        int midX = minX + (maxX - minX) / 2;

        char message[64];


        strcpy(message, vtime);

        int charHeight = 23;
        int charWidth = 17;

        int startText = midX - (8 * charWidth);

        image->drawLine(startText + (16 * charWidth), minY, startText + (16 * charWidth), minY + charHeight, WHITE, SOLID, 1);
        image->drawLine(startText - 1, minY, startText - 1, minY + charHeight, WHITE, SOLID, 1);
        image->drawLine(startText - 1, minY + charHeight + 1, startText + (16 * charWidth), minY + charHeight + 1, WHITE, SOLID, 1);
        image->drawText(startText, minY, message, &Font24, DARK_GRAY_BLUE, WHITE);

        memset(message, 0, sizeof(message));
            strcpy(message, &tmpstr2[saveMarquee]);
        //sprintf(message, "%-8.8s %-8.8s", humi, temp);
//        strcpy(message, "hello");

        //printf("%s||%s - %d %d \n", tmpstr1, message, strlen(tmpstr1), saveMarquee);
        image->drawText(startText, maxY - charHeight, message, &Font24, DARK_GRAY_BLUE, WHITE);


        d1.showImage(*image, DEGREE_270);


    }
}

void *updateClockLoop(void *) {
    Image img = Image(320, 240, BLACK);

	while (true) {
		updateClock(&img);
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
    d1.clear(BLACK);

    printf("bme280_address=%02x\n", bme280_address);

	threadCreate(readBME280Loop, "read bme280 sensor");
	printf("updating clock... speed=%dms\n", marqueeSpeed);

    int tries = 5;
    while (temperature < -999 && tries--) {
        delay(1000);
    }

    if (temperature < -999) {
        printf("cannot read bme280\n");
        return 9;
    }


	if (daemonMode) {
		threadCreate(updateClockLoop, "update clock loop");
		while (true) {
			delay(4294967295U);   // 3.27 years
		}
	} else {
        Image img = Image(320, 240, BLACK);
        updateClock(&img);
	}


	return 0;
}

/*
 * Author: wryan
 * Date:2018/12/27
 * Compiling :gcc -Wall name.c -lwiringPi -lwiringPiDev
 */
#include <wiringPi.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>
#include <unistd.h>
#include <pthread.h>
#include <sys/types.h>
#include <sys/time.h>
#include <dirent.h>

#include <chrono>
#include <ctime>  

#include <udd.h>
#include <bme280rpi.h>

#include "./tools/include/threads.h"

int marquee = 0;
int innerStep = 16;
int marqueeSpeed = 100;

char lastTopMessage[128] = { 0 };
const char* pictureFolderName = "~/Pictures/clock/";
 


enum ProcessLocks {
    IMAGE_LOCK
};

 // Display vars
using namespace udd;

DisplayConfigruation d1Config;
DisplayST7789R d1 = DisplayST7789R();

Rotation clockRotation = DEGREE_0;


#ifndef NULL
#define NULL 0
#endif

// bme280 info
int bme280_address = 0x76;
bme280_calib_data cal;
int bme280_fd;



// Global Variables
static long         spiSpeed = 90000000;
static char         dateFormat = '1';

static volatile bool daemonMode = false;
static volatile float humidity = -9999;
static volatile float temperature = -9999;



#define marqueeVisableChars 16
#define maxMessageSize 128
char msg[1024];

Image clockImage = Image(320, 240, BLACK);
char* imageBuffer;
long  imageBufferSize;
int   imagePipes[2];



unsigned long long currentTimeMillis() {
    struct timeval currentTime;
    gettimeofday(&currentTime, NULL);

    return
        (unsigned long long)(currentTime.tv_sec) * 1000 +
        (unsigned long long)(currentTime.tv_usec) / 1000;
}


bool usage() {
    fprintf(stderr, "usage: lcdClock [-d] [-b 00-FF] [-p 0-40] [-f n] [-s speed] [-m motd]\n");
    fprintf(stderr, "d = daemon mode\n");
    fprintf(stderr, "i = spi speed (default=90000000)\n");
    fprintf(stderr, "b = bme280 address (hex)\n");
    fprintf(stderr, "m = message of the day, max %d characters\n", maxMessageSize);
    fprintf(stderr, "r = clock rotation (default=0)\n");
    fprintf(stderr, "s = marquee speed (ms)\n");
    fprintf(stderr, "f = clock format\n");
    fprintf(stderr, "p = picture filename\n");
    fprintf(stderr, "    Date formats:\n");
    fprintf(stderr, "    1 - Weekday Date  HH:MM AM/PM\n");
    fprintf(stderr, "    2 - Weekday Month Date HH24:MM\n");

    return false;
}


void configureDisplay1() {
    d1Config.width = 240;
    d1Config.height = 320;
    d1Config.spiSpeed = spiSpeed;

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
    FILE* fp;
    fp = fopen("/dev/urandom", "r");
    fread(&seed, sizeof(seed), 1, fp);
    fclose(fp);
    srand(seed);

    bme280_fd = bme280_standardSetup(bme280_address, &cal);

    configureDisplay1();

    return true;
}




bool commandLineOptions(int argc, char **argv) {
	int c, index;

	if (argc < 2) {
		return usage();
	}

	while ((c = getopt(argc, argv, "db:f:i:m:p:r:s:")) != -1)
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
        case 'i':
            sscanf(optarg, "%ld", &spiSpeed);
            break;
        case 's':
			sscanf(optarg, "%d", &marqueeSpeed);
			break;
		case 'f':
			dateFormat = optarg[0];
			break;
        case 'p':
            pictureFolderName = optarg;
            break;
        case 'r':
            clockRotation = validateRotation(optarg);
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

void imageCopy(Image& destinationImage, int destinationX, int destinationY, Image& sourceImage, int sourceX, int sourceY, int windowWidth, int windowHeight) {

    for (int x = 0; x < windowWidth; ++x) {
        for (int y = 0; y < windowHeight; ++y) {
            ColorType* clr = sourceImage.getPixel(x + sourceX, y + sourceY, DEGREE_0);
            destinationImage.drawPixel(x + destinationX, y + destinationY, Color(*clr));
        }
    }
}



void updateClock(Image &image) {

    auto now = std::chrono::system_clock::now();
    std::time_t end_time = std::chrono::system_clock::to_time_t(now);
    char vtime[64];

    switch (dateFormat) {
    case '1':	std::strftime(vtime, 64, "%a %e  %I:%M %p", std::localtime(&end_time));
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

	if (strlen(vtime) > marqueeVisableChars) {
		vtime[marqueeVisableChars] = 0;
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

        memset(tmpstr1, 0, sizeof(tmpstr1));

        sprintf(tmpstr2, "%*s", marqueeVisableChars, "");

        if (strlen(msg) < 1) {
            marquee = -1;
            memset(tmpstr2, 0, sizeof(tmpstr2));
        }  else if (strlen(msg) < (marqueeVisableChars - 4)) {
            strcpy(&tmpstr2[(marqueeVisableChars - strlen(msg)) / 2], msg);
        } else {
            strcpy(tmpstr2, msg);
        }

        sprintf(tmpstr1, "%-6.6s  %-6.6s  %-*.*s", humi, temp, marqueeVisableChars, marqueeVisableChars, tmpstr2);
        sprintf(tmpstr2, "%s  %s  ", tmpstr1, tmpstr1);

        if (!daemonMode) {
            printf("%s\n", tmpstr1);
        }



        int imageWidth = d1Config.height;
        int imageHeight = d1Config.width;
        int minX = 0, minY = 0;
        int maxX = imageWidth - 1;
        int maxY = imageHeight - 1;
        int midY = minY + (maxY - minY) / 2;
        int midX = minX + (maxX - minX) / 2;

        char message[128];
        strcpy(message, vtime);

        int charHeight = 24;
        int charWidth  = 17;

        int startText = midX - ((marqueeVisableChars/2) * charWidth)  - 3;
        int endText   = startText + (marqueeVisableChars * charWidth) + 4;

        int   tmpWidth = marqueeVisableChars * charWidth + 5;
        int   tmpHeight = charHeight + 1;
        Image tmpimg = Image(tmpWidth, tmpHeight, DARK_GRAY_BLUE);

        if (strcmp(message, lastTopMessage)) {

            // top text
            tmpimg.drawText(3, 1, message, &Font24, DARK_GRAY_BLUE, WHITE);

            tmpimg.drawLine(0, tmpHeight - 1, tmpWidth - 1, tmpHeight - 1, WHITE, SOLID, 1);  // top line
            tmpimg.drawLine(0, 0, 0, tmpHeight - 1, WHITE, SOLID, 1);  // left line
            tmpimg.drawLine(tmpWidth - 1, 0, tmpWidth - 1, tmpHeight - 1, WHITE, SOLID, 1);  // right line

            piLock(IMAGE_LOCK);
            strcpy(lastTopMessage, message);
            d1.showImage(tmpimg, Point(startText, 0), Point(endText, tmpimg.getHeight() - 1), clockRotation);
            piUnlock(IMAGE_LOCK);
        }

// bottom text
        ++marquee;
        Image textBlock = Image(charWidth * (strlen(tmpstr2) + 2), charHeight * 2, DARK_GRAY_BLUE);
        textBlock.clear(DARK_GRAY_BLUE);
        textBlock.drawText(0, 0, tmpstr2, &Font24, DARK_GRAY_BLUE, WHITE);

        int   messageWidth = (strlen(tmpstr1) + 2) * charWidth;

        tmpimg.drawLine(         0, 0,  tmpWidth-1,           0,  WHITE, SOLID, 1);  // top line
        tmpimg.drawLine(         0, 0,           0, tmpHeight-1,  WHITE, SOLID, 1);  // left line
        tmpimg.drawLine(tmpWidth-1, 0,  tmpWidth-1, tmpHeight-1,  WHITE, SOLID, 1);  // right line


        imageCopy(tmpimg, 1, 1, textBlock, marquee % (messageWidth), 0, tmpWidth-2, charHeight);


        piLock(IMAGE_LOCK);
        d1.showImage(tmpimg, Point(startText,maxY-charHeight), Point(endText, maxY), clockRotation);
        piUnlock(IMAGE_LOCK);

        tmpimg.close();
        textBlock.close();

       // exit(0);
    }
}

#include <vector>
using namespace std;
vector<char *> pictureFiles;

void updateFileList() {
    char tmpstr[PATH_MAX+1024];

    for (char* s : pictureFiles) {
        free(s);
    }
    pictureFiles.clear();

    sprintf(tmpstr, "find %s -type f -exec file {} \\; | sed -ne 's/^\\(.*\\): PC bitmap.*/\\1/p' -e 's/\\(.*\\): [[:alnum:]]* image.*/\\1/p'", pictureFolderName);
    FILE* listing = popen(tmpstr, "r");
    
    if (listing == NULL) {
        fprintf(stderr, "could not open %s folder\b ", pictureFolderName); fflush(stderr);
        exit(EXIT_FAILURE);
    }

    while (fgets(tmpstr, PATH_MAX, listing) != NULL) {
        char* path = (char*)malloc(strlen(tmpstr) + 8);
        strcpy(path, tmpstr);
        if (path[strlen(path) - 1] == 10) {
            path[strlen(path) - 1] = 0;
        }
        pictureFiles.push_back(path);
    }
    pclose(listing);

    if (pictureFiles.size() < 1) {
        fprintf(stderr, "no images found in %s folder\n", pictureFolderName); fflush(stderr);
        exit(EXIT_FAILURE);
    }
}

int random(int low, int high) {
    double r = (double)rand() / RAND_MAX;

    return low + (r * (1 + high - low));
}


void* pushBuffer(void *) {
    write(imagePipes[1], imageBuffer, imageBufferSize);
    close(imagePipes[1]);
    return NULL;
}

void loadImage(Image& image) {
    char tmpstr[8192];
    char screenSize[64];
    long bytesRead = 0;


    const char* imageFile = "";
    int count = 10;
    int lastPicture=0;
    while (strlen(imageFile) < 1) {
        if (count-- < 10) {
            delay(5000);
        }
        if (count < 0) {
            fprintf(stderr, "pictureFiles.size()=%d\n", pictureFiles.size());
            fprintf(stderr, "lastPicture=%d\n", lastPicture);
            fprintf(stderr, "cannot locate any image files in image folder:  %s\n", pictureFolderName);
            exit(EXIT_FAILURE);
        }
        updateFileList();
        lastPicture = random(0, pictureFiles.size() - 1);
        imageFile = pictureFiles[lastPicture];
    }


    sprintf(screenSize, "%dx%d", d1.config.height, d1.config.width);
    sprintf(tmpstr,     "convert %s -resize %s -background black -gravity center -extent %s -type truecolor bmp:-",
                        imageFile, screenSize, screenSize);

    fprintf(stderr, "imagemagick conversion cmd: %s\n", tmpstr); fflush(stderr);

    FILE* imageConversionPipe = popen(tmpstr, "r");
    if (imageConversionPipe == NULL) {
        fprintf(stderr, "conversion pipe did not open\n"); fflush(stderr);
        exit(EXIT_FAILURE);
    }

    imageBuffer = (char *) malloc(1024 * 1024);
    imageBufferSize = 0;

    while (1) {
        bytesRead = fread(&imageBuffer[imageBufferSize], 1, 1024 * 1024, imageConversionPipe);
        imageBufferSize += bytesRead;
        if (bytesRead < 1024 * 1024) {
            fclose(imageConversionPipe);
            break;
        }
        imageBuffer = (char *) realloc(imageBuffer, imageBufferSize + 1024 * 1024);
    }
        
    pipe(imagePipes);
    threadCreate(pushBuffer, "pushBuffer");

    piLock(IMAGE_LOCK);
    lastTopMessage[0] = 0;
    image.loadBMP(fdopen(imagePipes[0],"r"), 0, 0);

    d1.showImage(image, clockRotation);

    piUnlock(IMAGE_LOCK);
    close(imagePipes[0]);
    free(imageBuffer);
    // loadBMP closes the pipe
}



void *updateImageLoop(void *) {
    clockImage.clear(BLACK);

    loadImage(clockImage);

    long long start = currentTimeMillis();
	while (true) {
        long long now = currentTimeMillis();
        long long elapsed = now - start;
        if (elapsed > 30 * 1000) {
            loadImage(clockImage);
            start = now;
        }
	}
}

void* updateClockLoop(void*) {

    while (true) {
        updateClock(clockImage);
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
    d1.clearScreen(DARK_BLUE);

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
        threadCreate(updateImageLoop, "update clock loop");
        while (true) {
			delay(4294967295U);   // 3.27 years
		}
	} else {
        Image img = Image(320, 240, BLACK);
        updateClock(img);
	}


	return 0;
}

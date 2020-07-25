#pragma once


pthread_t threadCreate(void *(*method)(void *), const char *description);

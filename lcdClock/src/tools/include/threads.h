#pragma once


pthread_t threadCreate(void *(*method)(void *), char *description);
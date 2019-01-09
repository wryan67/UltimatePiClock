
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>
#include <unistd.h>
#include <pthread.h>

pthread_t threadCreate(void *(*method)(void *), char *description) {
	pthread_t threadId;
	int status= pthread_create(&threadId, NULL, method, NULL);
	if (status != 0) {
		printf("%s::thread create failed %d--%s\n", description, status, strerror(errno));
		exit(9);
	}
	pthread_detach(threadId);
	return threadId;
}

#ifndef __SWIFT_GLIBC_MODULE_GLIBC_H__
#define __SWIFT_GLIBC_MODULE_GLIBC_H__

#ifdef __ANDROID__
#define _GNU_SOURCE
#endif

#include <time.h>
#include <complex.h>
#include <math.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <stdio.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fts.h>
#include <fcntl.h>
#include <pthread.h>
#include <semaphore.h>
#include <signal.h>
#include <dirent.h>
#include <pwd.h>
#include <grp.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/mman.h>
#include <sys/socket.h>
#include <netdb.h>
#include <sys/wait.h>
#include <net/if.h>

#ifndef __ANDROID__
#include <ifaddrs.h>
#endif

#include <netdb.h>

#ifndef __ANDROID__
#include <spawn.h>
#include <sys/statvfs.h>
#endif // !__ANDROID__

#ifdef __ANDROID__
#include <linux/in.h>
#include <linux/in6.h>
#endif // __ANDROID__

#ifdef __ANDROID__
#include <android/log.h>
#endif // __ANDROID__


#endif // __SWIFT_GLIBC_MODULE_GLIBC_H__

